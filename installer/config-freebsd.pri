boost: LIBS += -lboost_serialization
expat: LIBS += -lexpat
expat: PKGCONFIG -= expat
INCLUDEPATH+=/usr/local/include
LIBS+="-L/usr/local/lib"
LIBS+="-L/usr/lib"
LIBS+="-L/lib"
INCLUDEPATH+=/usr/local/include/PySide
INCLUDEPATH+=/usr/local/include/PySide/QtCore
INCLUDEPATH+=/usr/local/include/PySide/QtGui
INCLUDEPATH+=/usr/local/include/qt4
INCLUDEPATH+=/usr/local/include/qt4/QtCore
INCLUDEPATH+=/usr/local/include/qt4/QtGui

