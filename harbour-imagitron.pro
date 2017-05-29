TARGET = harbour-imagitron

CONFIG += sailfishapp

QT += network gui # gui for QImageReader

HEADERS += \
    src/filedownloader.h \
    src/imagitronlistmodel.h \
    src/imagitronobject.h

SOURCES += src/harbour-imagitron.cpp \
    src/filedownloader.cpp \
    src/imagitronlistmodel.cpp \
    src/imagitronobject.cpp

OTHER_FILES += qml/harbour-imagitron.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/MenuPage.qml \
    qml/pages/ImagePage.qml \
    qml/pages/AboutSimon.qml \
    qml/pages/About.qml \
    qml/pages/IconTextButton.qml \
    # qml/pages/ImageViewPage.qml \
    # qml/pages/FlickableImageView.qml \
    rpm/harbour-imagitron.spec \
    rpm/harbour-imagitron.changes \
    rpm/harbour-imagitron.yaml \
    translations/*.ts \
    harbour-imagitron.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/harbour-imagitron-ru.ts

DISTFILES += \
    qml/res/amazon.svg \
    qml/res/tumblr.svg \
    qml/res/soundcloud.svg \
    qml/res/redbubble.jpg \
    qml/res/imagitron.png \
    qml/res/simon.jpg \
    qml/res/flattr.svg \
    qml/res/paypal.svg \
    qml/res/rocketbank.svg \
    qml/res/git.svg \
    qml/res/le_me.jpeg \
    qml/res/aa13q.jpeg \
