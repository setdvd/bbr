module PR.Page exposing (External(..), Model, Msg, init, notification, update, view)

import Commit exposing (Commit)
import Commit.Build exposing (Build, Status(..))
import Credentials exposing (Credentials)
import Dict exposing (Dict)
import Element exposing (Element)
import Element.Events
import Element.Font
import Element.Input
import Global exposing (Global)
import Http
import LazyLoadableData
import List.Extra
import Maybe.Extra
import PR exposing (PR)
import PR.DiffStat exposing (PRDiffStat)
import PR.Merge
import PR.Participant exposing (Participant)
import Process
import ReloadableData
import Set exposing (Set)
import Settings exposing (Settings)
import Task exposing (Task)
import Task.Extra
import UI
import UI.Card
import UI.Color
import UI.Font
import UI.Icons
import UI.Input
import UI.Layout


type alias PRItem =
    { pr : PR
    , lastCommit : Commit
    , build : Build
    , diffStat : PRDiffStat
    }


type alias Model =
    { autoMerging : Set Int
    , prItems : ReloadableData.ReloadableData Http.Error (List PRItem)
    , mergeStatus : Dict Int (LazyLoadableData.LazyLoadableData Http.Error ())
    , hovered : Dict Int StatusIcon
    }


type StatusIcon
    = BuildStatus
    | ApproveStatus
    | ConflictStatus


fetch : Credentials -> Cmd Msg
fetch credentials =
    let
        fetchCommit : PR -> Task Http.Error Commit
        fetchCommit =
            .commitUrl >> Commit.fetch credentials

        fetchBuildStatus : Commit -> Task Http.Error Build
        fetchBuildStatus =
            .statusUrl >> Commit.Build.fetch credentials

        fetchDiffStat : PR -> Task Http.Error PR.DiffStat.PRDiffStat
        fetchDiffStat =
            PR.DiffStat.fetch credentials
    in
    credentials
        |> PR.fetchOpenPRs
        |> Task.andThen
            (\prs ->
                let
                    fetchCommits =
                        prs
                            |> List.map fetchCommit
                            |> Task.Extra.traverse

                    fetchDiffStats =
                        prs
                            |> List.map fetchDiffStat
                            |> Task.Extra.traverse
                in
                Task.map2 (\commits conflicts -> ( prs, commits, conflicts )) fetchCommits fetchDiffStats
            )
        |> Task.andThen
            (\( prs, commits, conflicts ) ->
                commits
                    |> List.map fetchBuildStatus
                    |> Task.Extra.traverse
                    |> Task.map (\builds -> List.map4 PRItem prs commits builds conflicts)
            )
        |> Task.attempt PRsFetched


intersect : List PRItem -> List PRItem -> List ( PRItem, PRItem )
intersect pRItemsOld pRItemsNew =
    pRItemsNew
        |> List.map
            (\new ->
                List.Extra.find (\old -> old.pr.id == new.pr.id) pRItemsOld
                    |> Maybe.map (\old -> ( old, new ))
            )
        |> Maybe.Extra.values


filterAutoMerge : Settings -> Set Int -> List ( PRItem, PRItem ) -> ( List ( PRItem, PRItem ), List ( PRItem, PRItem ) )
filterAutoMerge settings autoMerge list =
    List.partition (\( _, new ) -> Set.member new.pr.id autoMerge && isPRItemPassMergeRule settings.mergeRule new) list


filterReadyToMerge : Settings -> List ( PRItem, PRItem ) -> ( List ( PRItem, PRItem ), List ( PRItem, PRItem ) )
filterReadyToMerge settings list =
    List.partition (isReadyToMerge settings) list


isReadyToMerge : Settings -> ( PRItem, PRItem ) -> Bool
isReadyToMerge settings ( old, new ) =
    let
        ready =
            isPRItemPassMergeRule settings.mergeRule
    in
    not (ready old) && ready new


filterConflicts : List ( PRItem, PRItem ) -> ( List ( PRItem, PRItem ), List ( PRItem, PRItem ) )
filterConflicts list =
    List.partition (\( old, new ) -> not old.diffStat.hasConflict && new.diffStat.hasConflict) list


filterBuildFailed : List ( PRItem, PRItem ) -> ( List ( PRItem, PRItem ), List ( PRItem, PRItem ) )
filterBuildFailed list =
    List.partition (Tuple.mapBoth .build .build >> Commit.Build.isNewFailed) list


requestReFetch : Settings -> Cmd Msg
requestReFetch settings =
    settings.myPRPollInterval
        |> toFloat
        |> Process.sleep
        |> Task.perform (always RequestToReFetch)


init : Credentials -> ( Model, Cmd Msg )
init credentials =
    ( Model Set.empty ReloadableData.Loading Dict.empty Dict.empty, fetch credentials )


type Msg
    = PRsFetched (Result Http.Error (List PRItem))
    | RequestToReFetch
    | MergeClick PRItem
    | MergeResult PRItem (Result Http.Error ())
    | AutoMergeClick PRItem
    | CancelAutoMergeClick PRItem
    | StatusIconMouseEntered StatusIcon PRItem
    | StatusIconMouseLeave StatusIcon PRItem
    | RefreshClick


type External
    = PRItemUpdated UpdateInfo


type alias UpdateInfo =
    { readyToMerge : List ( PRItem, PRItem )
    , conflicts : List ( PRItem, PRItem )
    , buildFailed : List ( PRItem, PRItem )
    }


notification : UpdateInfo -> List { title : String, description : String }
notification updateInfo =
    let
        readyToMerge =
            List.map (\( _, new ) -> { title = new.pr.name, description = "is ready to merge" }) updateInfo.readyToMerge

        conflict =
            List.map (\( _, new ) -> { title = new.pr.name, description = "has conflicts" }) updateInfo.conflicts

        buildFailed =
            List.map (\( _, new ) -> { title = new.pr.name, description = "build failed" }) updateInfo.buildFailed
    in
    readyToMerge ++ conflict ++ buildFailed


update : Global -> Model -> Msg -> ( Model, Cmd Msg, Maybe External )
update global model msg =
    case msg of
        PRsFetched result ->
            let
                data =
                    ReloadableData.fromResult model.prItems result

                old =
                    ReloadableData.withDefault [] model.prItems

                new =
                    ReloadableData.withDefault [] data

                diff : List ( PRItem, PRItem )
                diff =
                    intersect old new

                ( forAutoMerge, other ) =
                    filterAutoMerge global.settings model.autoMerging diff

                cmds =
                    forAutoMerge
                        |> List.map (\( _, newPrForAutoMerge ) -> MergeClick newPrForAutoMerge)
                        |> List.map (\mergeMsg -> Process.sleep 0 |> Task.perform (always mergeMsg))

                ( readyToMerge, other2 ) =
                    filterReadyToMerge global.settings other

                ( buildFailed, other3 ) =
                    filterBuildFailed other2

                ( conflicts, _ ) =
                    filterConflicts other3
            in
            ( { model | prItems = data }
            , Cmd.batch (requestReFetch global.settings :: cmds)
            , Just <|
                PRItemUpdated
                    { readyToMerge = readyToMerge
                    , conflicts = conflicts
                    , buildFailed = buildFailed
                    }
            )

        RequestToReFetch ->
            ( { model | prItems = ReloadableData.toLoading model.prItems }, fetch global.credentials, Nothing )

        MergeClick pRItem ->
            let
                merge =
                    Dict.insert pRItem.pr.id LazyLoadableData.Loading model.mergeStatus

                cmd =
                    pRItem.pr
                        |> PR.Merge.merge global.credentials
                        |> Task.attempt (MergeResult pRItem)
            in
            ( { model | mergeStatus = merge }, cmd, Nothing )

        AutoMergeClick pRItem ->
            ( { model | autoMerging = Set.insert pRItem.pr.id model.autoMerging }, Cmd.none, Nothing )

        CancelAutoMergeClick pRItem ->
            ( { model | autoMerging = Set.remove pRItem.pr.id model.autoMerging }, Cmd.none, Nothing )

        MergeResult prItem result ->
            ( { model
                | mergeStatus =
                    Dict.insert prItem.pr.id (LazyLoadableData.Loaded result) model.mergeStatus
              }
            , Cmd.none
            , Nothing
            )

        StatusIconMouseEntered icon pRItem ->
            ( { model | hovered = Dict.insert pRItem.pr.id icon model.hovered }, Cmd.none, Nothing )

        StatusIconMouseLeave _ pRItem ->
            ( { model | hovered = Dict.remove pRItem.pr.id model.hovered }, Cmd.none, Nothing )

        RefreshClick ->
            let
                prItems =
                    ReloadableData.toLoading model.prItems
            in
            ( { model | prItems = prItems }, fetch global.credentials, Nothing )


view : Global -> Model -> Element Msg
view global model =
    let
        content =
            case model.prItems of
                ReloadableData.Loading ->
                    UI.column [ [ Element.width Element.fill ] ]
                        (List.range 1 3
                            |> List.map (always UI.Card.skeleton)
                        )

                ReloadableData.Loaded list ->
                    viewPRItems global model list

                -- TODO add generic bb error handling
                --      labels: P1
                ReloadableData.Failed e ->
                    case e of
                        Http.BadUrl string ->
                            Element.text "bad url"

                        Http.Timeout ->
                            Element.text "timeout"

                        Http.NetworkError ->
                            Element.text "network down"

                        Http.BadStatus int ->
                            Element.text <| "bad status" ++ String.fromInt int

                        Http.BadBody string ->
                            Element.text string

                ReloadableData.Reloading list ->
                    viewPRItems global model list

                ReloadableData.ReloadingFailed _ list ->
                    viewPRItems global model list
    in
    UI.Layout.page
        []
        [ UI.row [ [ Element.width Element.fill ] ]
            [ UI.Layout.header [] "PRs List"
            , viewReloadingButton model
            ]
        , UI.el [ UI.container ] content
        ]


viewReloadingButton : Model -> Element Msg
viewReloadingButton model =
    let
        isLoading =
            ReloadableData.isLoading model.prItems

        onClick =
            if isLoading then
                Nothing

            else
                Just RefreshClick

        style =
            [ Element.alignRight ]

        ( stateAttr, color ) =
            case model.prItems of
                ReloadableData.Loading ->
                    ( [ Element.alpha 0.3 ], UI.Color.black )

                ReloadableData.Loaded _ ->
                    ( [], UI.Color.black )

                ReloadableData.Failed _ ->
                    ( [], UI.Color.error )

                ReloadableData.Reloading _ ->
                    ( [ Element.alpha 0.3 ], UI.Color.black )

                ReloadableData.ReloadingFailed _ _ ->
                    ( [], UI.Color.error )
    in
    UI.Input.iconButton [ style, stateAttr ]
        { onClick = onClick
        , icon = UI.Icons.refresh color
        }


viewPRItems : Global -> Model -> List PRItem -> Element Msg
viewPRItems global model pRItems =
    UI.column
        [ [ Element.width Element.fill
          ]
        ]
        (List.map (viewItem global model) pRItems)


isPRItemPassMergeRule : PR.Merge.MergeRule -> PRItem -> Bool
isPRItemPassMergeRule mergeRule pRItem =
    let
        hasNeedApproves =
            PR.Participant.approveCount pRItem.pr.participants >= mergeRule.numberOfApproves

        hasBuilds =
            if mergeRule.allBuildPass then
                Commit.Build.isPass pRItem.build

            else
                True

        tasks =
            if mergeRule.openTasks then
                pRItem.pr.openTaskCount == 0

            else
                True
    in
    hasNeedApproves && hasBuilds && not pRItem.diffStat.hasConflict && tasks


statusIcon : Element msg -> Element msg
statusIcon =
    UI.Icons.icon 14


viewBuildStateIcon : Model -> PRItem -> Element Msg
viewBuildStateIcon model prItem =
    let
        build : Build
        build =
            prItem.build

        wrapper : Element msg -> Element msg
        wrapper =
            case build of
                Commit.Build.Empty ->
                    identity

                Commit.Build.Started [ buildInfos ] ->
                    let
                        wrapperInternal : Element msg -> Element msg
                        wrapperInternal c =
                            Element.newTabLink [] { url = buildInfos.buildURL, label = c }
                    in
                    wrapperInternal

                Commit.Build.Started _ ->
                    identity

        color =
            case Commit.Build.transverse build of
                InProgress ->
                    UI.Color.grey50

                Success ->
                    UI.Color.green70

                Failed ->
                    UI.Color.error

                Stopped ->
                    UI.Color.error

        icon =
            UI.Icons.tools color
    in
    wrapper <|
        viewStatusIcon model
            prItem
            { status = BuildStatus
            , icon = icon
            , tooltipText = "build " ++ Commit.Build.statusToString build
            }


viewApproveStateIcon : Model -> PRItem -> Element Msg
viewApproveStateIcon model prItem =
    let
        color =
            if PR.Participant.approveCount prItem.pr.participants > 0 then
                UI.Color.green70

            else
                UI.Color.grey50

        icon =
            UI.Icons.review color
    in
    viewStatusIcon model prItem { status = ApproveStatus, icon = icon, tooltipText = PR.Participant.toString prItem.pr.participants }


viewItem : Global -> Model -> PRItem -> Element Msg
viewItem global model pRItem =
    UI.row
        [ UI.Card.box ]
        [ UI.column
            [ [ Element.width Element.fill
              , Element.spacing 8
              ]
            ]
            [ UI.paragraph [] [ Element.newTabLink [ Element.Font.underline ] { url = pRItem.pr.htmlLink, label = Element.text pRItem.pr.name } ]
            , viewStatusRow model pRItem
            ]
        , UI.el [] <| viewMergeButton global model pRItem
        ]


viewStatusIcon : Model -> PRItem -> { status : StatusIcon, icon : Element Msg, tooltipText : String } -> Element Msg
viewStatusIcon model prItem { status, icon, tooltipText } =
    let
        hovered =
            Dict.get prItem.pr.id model.hovered
                |> Maybe.map (\s -> s == status)
                |> Maybe.withDefault False

        toolTip : Element Msg
        toolTip =
            if hovered then
                UI.el [ [ Element.centerX, Element.moveUp 4 ] ]
                    (UI.el
                        [ UI.tooltip ]
                        (UI.text tooltipText)
                    )

            else
                Element.none
    in
    UI.el
        [ [ Element.above toolTip
          , Element.Events.onMouseEnter (StatusIconMouseEntered status prItem)
          , Element.Events.onMouseLeave (StatusIconMouseLeave status prItem)
          ]
        ]
        (statusIcon icon)


viewConflictStatusIcon : Model -> PRItem -> Element Msg
viewConflictStatusIcon model prItem =
    let
        ( color, txt ) =
            if prItem.diffStat.hasConflict then
                ( UI.Color.error, "pr has conflicts" )

            else
                ( UI.Color.green70, "no conflicts" )

        icon =
            UI.Icons.conflict color
    in
    viewStatusIcon model prItem { status = ConflictStatus, icon = icon, tooltipText = txt }


viewMergeButton : Global -> Model -> PRItem -> Element Msg
viewMergeButton global model prItem =
    let
        button =
            UI.Input.smallButton []

        state =
            calculateMergeState global model prItem
    in
    case state of
        NotReady ->
            UI.Input.checkBox []
                { onChange = always <| AutoMergeClick prItem
                , checked = False
                , label = "Auto merge"
                }

        ReadyToMerge lazyLoadableData ->
            case lazyLoadableData of
                LazyLoadableData.NotAsked ->
                    button { label = Element.text "Merge", onClick = Just <| MergeClick prItem }

                LazyLoadableData.Loading ->
                    button { label = UI.Icons.icon 12 (UI.Icons.circularProgress UI.Color.white), onClick = Nothing }

                LazyLoadableData.Loaded result ->
                    case result of
                        Ok () ->
                            button { label = Element.text "Merged", onClick = Nothing }

                        Err error ->
                            case error of
                                Http.BadUrl string ->
                                    Element.text "bad url"

                                Http.Timeout ->
                                    Element.text "timeout"

                                Http.NetworkError ->
                                    Element.text "network down"

                                Http.BadStatus int ->
                                    Element.text <| "BE down " ++ String.fromInt int

                                Http.BadBody string ->
                                    Element.text <| "Bad body: " ++ string

        AutoMerge ->
            UI.Input.checkBox []
                { onChange = always <| CancelAutoMergeClick prItem
                , checked = True
                , label = "Auto merge"
                }


viewStatusRow : Model -> PRItem -> Element Msg
viewStatusRow model pRItem =
    UI.wrappedRow
        [ [ Element.width Element.fill
          , Element.spacing 8
          ]
        ]
        [ viewBuildStateIcon model pRItem
        , viewApproveStateIcon model pRItem
        , viewConflictStatusIcon model pRItem
        , viewComplexityIcon model pRItem
        ]


viewComplexityIcon : Model -> PRItem -> Element Msg
viewComplexityIcon _ pRItem =
    if pRItem.diffStat.linesAdded < 100 then
        UI.el [ UI.Font.caption, [ Element.Font.color UI.Color.success ] ] <| UI.text "S"

    else if pRItem.diffStat.linesAdded < 400 then
        UI.el [ UI.Font.caption, [ Element.Font.color UI.Color.warning ] ] <| UI.text "M"

    else
        UI.el [ UI.Font.caption, [ Element.Font.color UI.Color.error ] ] <| UI.text "XL: 400+ LOC"


type MergeButtonState
    = NotReady
    | AutoMerge
    | ReadyToMerge (LazyLoadableData.LazyLoadableData Http.Error ())


calculateMergeState : Global -> Model -> PRItem -> MergeButtonState
calculateMergeState { settings } { mergeStatus, autoMerging } pRItem =
    let
        loadableState =
            Dict.get pRItem.pr.id mergeStatus
                |> Maybe.withDefault LazyLoadableData.NotAsked
    in
    if not (isPRItemPassMergeRule settings.mergeRule pRItem) then
        if Set.member pRItem.pr.id autoMerging then
            AutoMerge

        else
            NotReady

    else
        ReadyToMerge loadableState
