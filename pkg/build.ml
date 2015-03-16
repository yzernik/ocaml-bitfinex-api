#!/usr/bin/env ocaml
#directory "pkg"
#use "topkg.ml"

let () =
  Pkg.describe "bitfinex" ~builder:`OCamlbuild [
    Pkg.lib "pkg/META";
    Pkg.lib ~exts:Exts.module_library "lib/bitfinex";
    Pkg.lib ~exts:Exts.library "top/bitfinex_top";
  ]
