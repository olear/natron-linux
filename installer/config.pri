boost: LIBS += -lboost_serialization
expat: LIBS += -lexpat
expat: PKGCONFIG -= expat
INCLUDEPATH+=/opt/Natron-1.0/include
LIBS+="-L/opt/Natron-1.0/lib"
