@echo off
cls
color 06
echo Building "miyuki-c"
cd miyuki-c
dub build
cd ..
echo Building "silvergarden-frontend-compiler"
cd silvergarden-frontend-compiler
dub build
cd ..
color 0f
echo Build Finished! Running... "silverc"
silverc Example.silver