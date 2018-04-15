cd src
nim c --out:..\tbk.exe -d:release --opt:speed --app:gui ng2tbk.nim
rmdir /s /q nimcache
cd ..

