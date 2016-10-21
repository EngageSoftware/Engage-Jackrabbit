module Views.Elm.Tests.HtmlTestRunner exposing (main)

import Test.Runner.Html exposing (run)
import Views.Elm.Tests.Tests as Tests


main : Program Never
main =
    run Tests.all
