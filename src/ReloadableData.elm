module ReloadableData exposing (..)


type ReloadableData e t
    = Loading
    | Loaded t
    | Failed e
    | Reloading t
    | ReloadingFailed e t


isLoading : ReloadableData e t -> Bool
isLoading reloadableData =
    case reloadableData of
        Loading ->
            True

        Loaded _ ->
            False

        Failed _ ->
            False

        Reloading _ ->
            True

        ReloadingFailed _ _ ->
            False


fromResult : ReloadableData e x -> Result e x -> ReloadableData e x
fromResult reloadableData result =
    case ( reloadableData, result ) of
        ( Loading, Ok value ) ->
            Loaded value

        ( Loaded _, Ok value ) ->
            Loaded value

        ( Failed _, Ok value ) ->
            Loaded value

        ( Reloading _, Ok value ) ->
            Loaded value

        ( ReloadingFailed _ _, Ok value ) ->
            Loaded value

        ( Loading, Err err ) ->
            Failed err

        ( Loaded old, Err value ) ->
            ReloadingFailed value old

        ( Failed _, Err value ) ->
            Failed value

        ( Reloading old, Err value ) ->
            ReloadingFailed value old

        ( ReloadingFailed _ t, Err value ) ->
            ReloadingFailed value t


fromError : ReloadableData e t -> e -> ReloadableData e t
fromError reloadableData e =
    case reloadableData of
        Loading ->
            Failed e

        Loaded t ->
            ReloadingFailed e t

        Failed _ ->
            Failed e

        Reloading t ->
            ReloadingFailed e t

        ReloadingFailed _ t ->
            ReloadingFailed e t


toLoading : ReloadableData e t -> ReloadableData e t
toLoading reloadableData =
    case reloadableData of
        Loading ->
            Loading

        Loaded t ->
            Reloading t

        Failed _ ->
            Loading

        Reloading t ->
            Reloading t

        ReloadingFailed _ t ->
            Reloading t


map : (t -> t) -> ReloadableData e t -> ReloadableData e t
map mapper reloadableData =
    case reloadableData of
        Loading ->
            Loading

        Loaded t ->
            Loaded <| mapper t

        Failed e ->
            Failed e

        Reloading t ->
            Reloading <| mapper t

        ReloadingFailed e t ->
            ReloadingFailed e <| mapper t


withDefault : a -> ReloadableData e a -> a
withDefault a reloadableData =
    case reloadableData of
        Loading ->
            a

        Loaded t ->
            t

        Failed e ->
            a

        Reloading t ->
            t

        ReloadingFailed e t ->
            t
