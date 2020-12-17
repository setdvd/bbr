module PR.Page exposing (External(..), Model, Msg, init, update, view)

import Commit exposing (Commit)
import Commit.Build exposing (Build)
import Credentials exposing (Credentials)
import Element exposing (Element)
import Http
import List.Extra
import Maybe.Extra
import PR exposing (PR)
import Process
import ReloadableData exposing (ReloadableData(..))
import Task exposing (Task)
import Task.Extra
import UI
import UI.Card
import UI.Font
import UI.Layout


type alias PRItem =
    { pr : PR
    , lastCommit : Commit
    , build : Build
    }


type alias Model =
    ReloadableData Http.Error (List PRItem)


fetch : Credentials -> Cmd Msg
fetch credentials =
    let
        fetchCommit : PR -> Task Http.Error Commit
        fetchCommit =
            .commitUrl >> Commit.fetch credentials

        fetchBuildStatus : Commit -> Task Http.Error Build
        fetchBuildStatus =
            .statusUrl >> Commit.Build.fetch credentials
    in
    credentials
        |> PR.fetchOpenPRs
        |> Task.andThen
            (\prs ->
                prs
                    |> List.map fetchCommit
                    |> Task.Extra.traverse
                    |> Task.map (\commits -> ( prs, commits ))
            )
        |> Task.andThen
            (\( prs, commits ) ->
                commits
                    |> List.map fetchBuildStatus
                    |> Task.Extra.traverse
                    |> Task.map (\builds -> List.map3 PRItem prs commits builds)
            )
        |> Task.attempt PRsFetched


reFetchIntervalMS : Float
reFetchIntervalMS =
    1000 * 2


diff : List PRItem -> List PRItem -> Maybe External
diff pRItemsOld pRItemsNew =
    pRItemsNew
        |> List.map
            (\new ->
                List.Extra.find (\old -> old.pr.id == new.pr.id) pRItemsOld
                    |> Maybe.map (\old -> ( old, new ))
            )
        |> Maybe.Extra.values
        |> List.head
        |> Maybe.andThen
            (\( old, new ) ->
                if Commit.Build.shouldNotify old.build new.build then
                    Just ( old, new )

                else
                    Nothing
            )
        |> Maybe.map (\( old, new ) -> PRBuildStatusChangedFromTo new.pr old.build new.build)


requestReFetch : Cmd Msg
requestReFetch =
    reFetchIntervalMS
        |> Process.sleep
        |> Task.perform (always RequestToReFetch)


init : Credentials -> ( Model, Cmd Msg )
init credentials =
    ( ReloadableData.Loading, fetch credentials )


type Msg
    = PRsFetched (Result Http.Error (List PRItem))
    | RequestToReFetch


type External
    = PRBuildStatusChangedFromTo PR Build Build


update : Credentials -> Model -> Msg -> ( Model, Cmd Msg, Maybe External )
update credentials model msg =
    case msg of
        PRsFetched result ->
            let
                data =
                    ReloadableData.fromResult model result

                old =
                    ReloadableData.withDefault [] model

                new =
                    ReloadableData.withDefault [] data
            in
            ( data, requestReFetch, diff old new )

        RequestToReFetch ->
            ( ReloadableData.toLoading model, fetch credentials, Nothing )


view : Model -> Element Msg
view model =
    let
        content =
            case model of
                Loading ->
                    Element.column [ Element.width Element.fill ]
                        (List.range 1 3
                            |> List.map (always UI.Card.skeleton)
                        )

                Loaded list ->
                    viewPRItems list

                -- TODO: [P3] [S] use generic error
                Failed e ->
                    Element.text "Loading Error ..."

                Reloading list ->
                    viewPRItems list

                ReloadingFailed _ list ->
                    viewPRItems list
    in
    UI.Layout.page
        []
        [ UI.Layout.header [] "PRs List"
        , UI.container [] content
        ]


viewPRItems : List PRItem -> Element Msg
viewPRItems pRItems =
    Element.column
        [ Element.width Element.fill
        ]
        (List.map viewItem pRItems)


viewItem : PRItem -> Element Msg
viewItem pRItem =
    -- TODO: [Focus] [L] add reviewer status
    UI.Card.box
        []
        [ UI.Card.avatar [] (Commit.Build.viewStateIcon pRItem.build [ UI.center ])
        , Element.column
            [ Element.width Element.fill
            , Element.spacing 8
            ]
            [ Element.paragraph [] [ Element.text pRItem.pr.name ]
            , Element.paragraph UI.Font.caption [ Element.text <| Commit.Build.statusToString pRItem.build ]
            ]
        ]
