#!/bin/sh
cd src
nim c --out:../tbk ng2tbk.nim
#rm -rf nimcache
cd ..

