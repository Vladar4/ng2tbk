#!/bin/sh
cd src
nim c --out:../ng2tbk tbk.nim
#rm -rf nimcache
cd ..

