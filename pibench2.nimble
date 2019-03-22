#~~
# Package
#~~

version       = "0.1.0"
author        = "liquid600pgm"
description   = "A multi-threaded performance benchmark."
license       = "MIT"
srcDir        = "src"
bin           = @["pibench2"]

#~~
# Dependencies
#~~

requires "nim >= 0.19.4"

#~~
# Taska
#~~

task release, "Build release binary":
  exec "nim c -d:release --opt:speed -o:pibench2 src/pibench2.nim"
