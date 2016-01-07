QT = core bluetooth quick
SOURCES += btcontrol.cpp

TARGET = btcontrol
TEMPLATE = app

RESOURCES += \
    btcontrol.qrc

OTHER_FILES += \
    btcontrol.qml \
    Button.qml \
    DisButton.qml \
    default.png

#DEFINES += QMLJSDEBUGGER

target.path = /home/chris/android/BTcontrol
INSTALLS += target
