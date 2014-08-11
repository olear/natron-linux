boost: LIBS += -lboost_serialization
expat: LIBS += -lexpat
expat: PKGCONFIG -= expat
INCLUDEPATH+=/usr/local/include
LIBS+="-L/usr/local/lib"
LIBS+="-L/usr/lib"
LIBS+="-L/lib"
