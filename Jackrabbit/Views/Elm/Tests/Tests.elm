module Views.Elm.Tests.Tests exposing (all)

import Test exposing (..)
import Views.Elm.Tests.JsonTests as JsonTests
import Views.Elm.Tests.FileUpdateTests as FileUpdateTests
import Views.Elm.Tests.MainUpdateTests as MainUpdateTests
import Views.Elm.Tests.MiscTests as MiscTests


all : Test
all =
    describe "ViewJackrabbit Tests"
        [ describe "JSON Tests" JsonTests.tests
        , describe "File Update Tests" FileUpdateTests.tests
        , describe "Main Update Tests" MainUpdateTests.tests
        , describe "Miscellaneous Tests" MiscTests.tests
        ]
