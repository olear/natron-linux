64bit {

boost { INCLUDEPATH += $$quote(C:\local\boost_1_55_0) LIBS += -L$$quote(C:\local\boost_1_55_0\lib64-msvc-10.0) -lboost_serialization-vc100-mt-1_55 }

glew{ INCLUDEPATH += $$quote(C:\local\glew\include) LIBS += -L$$quote(C:\local\glew\lib\Release\x64) -lglew32 }

expat{ INCLUDEPATH += $$quote(C:\local\expat-2.0.1\lib) LIBS += -L$$quote(C:\local\expat-2.0.1\win64\bin\Release) -llibexpatMT LIBS += shell32.lib }

cairo { INCLUDEPATH += $$quote(C:\local\cairo1.12_static_MT_release\include) LIBS += -L$$quote(C:\local\cairo1.12_static_MT_release\lib\x64) -lcairo }

}

32bit {

boost { INCLUDEPATH += $$quote(C:\local\boost_1_55_0) LIBS += -L$$quote(C:\local\boost_1_55_0\lib32-msvc-10.0) -lboost_serialization-vc100-mt-1_55 }

glew{ INCLUDEPATH += $$quote(C:\local\glew-1.11.0\include) LIBS += -L$$quote(C:\local\glew-1.11.0\lib\Release\Win32) -lglew32 }

expat{ INCLUDEPATH += $$quote(C:\local\expat-2.0.1\lib) LIBS += -L$$quote(C:\local\expat-2.0.1\win32\bin\Release) -llibexpatMT LIBS += shell32.lib }

cairo { INCLUDEPATH += $$quote(C:\local\cairo-1.12\include) LIBS += -L$$quote(C:\local\cairo-1.12\lib\x86) -lcairo }

}
