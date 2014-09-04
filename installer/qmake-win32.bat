@echo off
set PATH=C:\Qt\Qt5.3.1\5.3\msvc2010_opengl\bin;%PATH%
qmake -r -tp vc -spec win32-msvc2010 CONFIG+=32bit Project.pro -o Project32.sln
