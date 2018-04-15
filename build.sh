#!/bin/sh
cd src
nim c --out:../ng2tbk -d:release --opt:speed tbk.nim
rm -rf nimcache
cd ..

