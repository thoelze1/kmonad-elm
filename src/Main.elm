port module Main exposing (main)

{-|  A simple Platform.worker program with
a simple command-line interface:

   `$ sh make.sh `                      -- (1)
   `$ chmod u+x cli; alias cli='./cli'` -- (2)
   `$ cli 77`                           -- (3)
     `232`

1) Compile Main.elm to `./run/main.js` and
copy `src/cli.js` to `./run/cli.js`

2) Make `cli` executable and make an alias for it
to avoid awkward typing.

3) Try it out.  The program `cli.js` communicates
with runtime for the `Platform.worker` program.
The worker accepts input, computes some output,
and send the output back through ports.

To do something more interesting, replace
the `transform` function in `Main.elm`.

-}

import Platform exposing (Program)


type alias InputType = Int
type alias OutputType = Maybe Int

port get : (InputType -> msg) -> Sub msg

port put : OutputType -> Cmd msg


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }

type alias Model =
    { layer : Int -> Int
    }


type Msg
    = Input Int


type alias Flags =
    ()

foo : Int -> Int
foo _ = 3

init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { layer = identity } , Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        transform : InputType -> OutputType
        transform k = Just (model.layer k)
    in
    case msg of
        Input 9 -> ( { layer = foo }, Cmd.none )
        Input input -> ( model, put (transform input))


subscriptions : Model -> Sub Msg
subscriptions _ =
    get Input
