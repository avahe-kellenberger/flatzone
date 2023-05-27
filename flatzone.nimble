# Package

version       = "0.1.0"
author        = "Avahe Kellenberger"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 1.6.12"
requires "karax >= 1.2.2"
requires "markdown >= 0.8.7"

task release, "Builds the website":
  exec "karun src/flatzone.nim"

