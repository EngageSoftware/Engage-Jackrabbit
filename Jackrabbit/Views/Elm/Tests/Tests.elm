module Views.Elm.Tests.Tests exposing (all)

import Test exposing (..)
import Views.Elm.Tests.JsonTests as JsonTests


all : Test
all =
    describe "ViewJackrabbit Tests"
        [ describe "JSON Tests" JsonTests.tests
        ]
