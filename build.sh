#!/bin/sh
cd src
nim c --out:../tbk -d:release --opt:speed ng2tbk.nim
rm -rf nimcache
cd ..

