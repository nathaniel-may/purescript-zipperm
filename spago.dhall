{ name = "purescript-zipperm"
, dependencies =
  [ "arrays"
  , "console"
  , "control"
  , "effect"
  , "foldable-traversable"
  , "identity"
  , "lists"
  , "maybe"
  , "prelude"
  , "quickcheck"
  , "transformers"
  , "tuples"
  , "unfoldable"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
