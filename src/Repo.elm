module Repo exposing (Data, External(..), Model, Msg, Repo, fetchActiveRepos, init, update, view)

import API
import Commit exposing (Commit)
import Credentials exposing (Credentials)
import Dict exposing (Dict)
import Dict.Extra
import Element exposing (Element)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (required, requiredAt)
import List.Extra
import Process
import Task exposing (Task)


type alias Repo =
    { id : Int
    , name : String
    , commitUrl : String
    }


type alias Data =
    List ( Commit.Status, Repo )


decode : Json.Decode.Decoder Repo
decode =
    Json.Decode.succeed Repo
        |> required "id" Json.Decode.int
        |> required "title" Json.Decode.string
        |> requiredAt [ "source", "commit", "links", "self", "href" ] Json.Decode.string


decodeRepoList : Json.Decode.Decoder (List Repo)
decodeRepoList =
    Json.Decode.field "values" <| Json.Decode.list decode


traverse : List (Task a b) -> Task a (List b)
traverse tasks =
    case tasks of
        [] ->
            Task.succeed []

        [ x ] ->
            Task.map List.singleton x

        x :: xs ->
            Task.map2 (\x_ xs_ -> x_ :: xs_) x (traverse xs)


fetchActiveRepos : Credentials -> Task Http.Error Data
fetchActiveRepos credentials =
    API.get
        { url = API.baseUrl ++ "/pullrequests/" ++ Tuple.first credentials
        , creds = credentials
        , decoder = decodeRepoList
        }
        |> Task.andThen (fetchCommits credentials)


fetchCommits : Credentials -> List Repo -> Task Http.Error Data
fetchCommits credentials prs =
    let
        commits =
            traverse <| List.map (.commitUrl >> Commit.fetch credentials) prs
    in
    Task.map (\cs_ -> List.Extra.zip cs_ prs) commits


refetch : Credentials -> Cmd Msg
refetch credentials =
    Process.sleep 2000
        |> Task.andThen (always (fetchActiveRepos credentials))
        |> Task.attempt PRDataFetched


type alias Model =
    Data


init : { credentials : Credentials, data : Data } -> ( Model, Cmd Msg )
init { credentials, data } =
    ( data, refetch credentials )


type Msg
    = PRDataFetched (Result Http.Error Data)


type External
    = Logout
    | PRDataChanged String


diff : Data -> Data -> Maybe String
diff old new =
    let
        dictNew =
            index new

        dictOld : Dict Int String
        dictOld =
            index old

        oldPRSThatExistInNewData =
            Dict.intersect dictNew dictOld

        statusChanged =
            Dict.Extra.find (\id status -> found status (Dict.get id dictOld)) oldPRSThatExistInNewData
    in
    Maybe.map Tuple.second statusChanged


found : Commit.Status -> Maybe Commit.Status -> Bool
found status maybe =
    case maybe of
        Just statusOld ->
            status /= statusOld

        Nothing ->
            False


index : Data -> Dict Int String
index data =
    Dict.fromList (List.map (\( status, repo ) -> ( repo.id, status )) data)


update : Credentials -> Model -> Msg -> ( Model, Cmd Msg, Maybe External )
update credentials model msg =
    case msg of
        PRDataFetched (Ok data) ->
            let
                stats =
                    diff model data

                external =
                    Maybe.map PRDataChanged stats
            in
            ( data, refetch credentials, external )

        PRDataFetched (Err error) ->
            case error of
                Http.BadUrl _ ->
                    ( model, refetch credentials, Nothing )

                Http.Timeout ->
                    ( model, refetch credentials, Nothing )

                Http.NetworkError ->
                    ( model, refetch credentials, Nothing )

                Http.BadStatus status ->
                    case status of
                        401 ->
                            ( model, Cmd.none, Just Logout )

                        403 ->
                            ( model, Cmd.none, Just Logout )

                        _ ->
                            ( model, refetch credentials, Nothing )

                Http.BadBody _ ->
                    ( model, refetch credentials, Nothing )


view : Model -> Element Msg
view model =
    Element.column
        []
        (List.map viewPR model)


viewPR : ( Commit.Status, Repo ) -> Element Msg
viewPR ( status, repo ) =
    Element.column
        []
        [ Element.text repo.name
        , Element.text status
        ]
