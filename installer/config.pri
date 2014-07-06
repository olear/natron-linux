boost: LIBS += -lboost_serialization
expat: LIBS += -lexpat
expat: PKGCONFIG -= expat
INCLUDEPATH+=/opt/Natron-0.9/include
LIBS+="-L/opt/Natron-0.9/lib"
