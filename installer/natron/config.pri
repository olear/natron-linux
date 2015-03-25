boost: LIBS += -lboost_serialization
expat: LIBS += -lexpat
expat: PKGCONFIG -= expat
INCLUDEPATH+=/opt/Natron-2.0/include
#INCLUDEPATH+=/opt/Natron-2.0/include/PySide
#INCLUDEPATH+=/opt/Natron-2.0/include/PySide/QtCore
#INCLUDEPATH+=/opt/Natron-2.0/include/PySide/QtGui
#INCLUDEPATH+=/opt/Natron-2.0/include/Qt
#INCLUDEPATH+=/opt/Natron-2.0/include/QtCore
#INCLUDEPATH+=/opt/Natron-2.0/include/QtGui
LIBS+="-L/opt/Natron-2.0/lib"

pyside {
PKGCONFG -= pyside
INCLUDEPATH += $$system(pkg-config --variable=includedir pyside)
INCLUDEPATH += $$system(pkg-config --variable=includedir pyside)/QtCore
INCLUDEPATH += $$system(pkg-config --variable=includedir pyside)/QtGui
INCLUDEPATH += $$system(pkg-config --variable=includedir QtGui)
LIBS += -lpyside.cpython-34m
}
shiboken {
PKGCONFIG -= shiboken
INCLUDEPATH += $$system(pkg-config --variable=includedir shiboken)
LIBS += -lshiboken.cpython-34m
}

QMAKE_LFLAGS += -Wl,-rpath,\\\$\$ORIGIN/../lib
