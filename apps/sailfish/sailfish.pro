# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-scintillon

VERSION_MAJOR = 0
VERSION_MINOR = 1
VERSION_BUILD = 1

#Target version
VERSION = $${VERSION_MAJOR}.$${VERSION_MINOR}-$${VERSION_BUILD}

DEFINES += "VERSION_MAJOR=$$VERSION_MAJOR" \
    "VERSION_MINOR=$$VERSION_MINOR" \
    "VERSION_BUILD=$$VERSION_BUILD" \
    "VERSION=\\\"$$VERSION\\\""

CONFIG += sailfishapp
PKGCONFIG += mlite5
QT += network
LIBS += -L ../../libhue -lhue

SOURCES += \
    src/settings.cpp \
    src/imageprovider.cpp \
    src/harbour-scintillon.cpp

DISTFILES += \
    ../../rpm/harbour-scintillon.spec \
    ../../rpm/harbour-scintillon.yaml \
    ../../rpm/harbour-scintillon.changes.run.in \
    ../../rpm/harbour-scintillon.changes \
    translations/*.ts \
    harbour-scintillon.desktop \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/About.qml \
    qml/components/InfoRow.qml \
    qml/components/BarButton.qml \
    qml/components/IconSwitch.qml \
    qml/components/IconPressable.qml \
    qml/components/LightsAndGroupsList.qml \
    qml/components/SwitchOnOffList.qml \
    qml/components/ScenesList.qml \
    qml/components/SensorBridge.qml \
    qml/components/SensorTap.qml \
    qml/components/SensorDimmer.qml \
    qml/components/SensorGeneric.qml \
    qml/utils/SensorUtils.js \
    qml/utils/ColourUtils.js \
    qml/cover/LargeItem.qml \
    qml/harbour-scintillon.qml \
    qml/pages/BridgeInfoPage.qml \
    qml/pages/LightsPage.qml \
    qml/pages/LightsDetailsPage.qml \
    qml/pages/LightEdit.qml \
    qml/pages/ScenesPage.qml \
    qml/pages/GroupsPage.qml \
    qml/pages/AlarmsPage.qml \
    qml/pages/RulesPage.qml \
    qml/pages/SensorsPage.qml \
    qml/pages/SensorPage.qml \
    qml/pages/ScenesSettings.qml \
    qml/pages/ScenesAdd.qml \
    qml/pages/GroupsAdd.qml \
    qml/pages/AlarmAdd.qml \
    qml/pages/CountdownAdd.qml \
    qml/pages/RulePage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/ErrorPage.qml \
    qml/pages/BusyPage.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 256x256

# to disable building translations every time, comment out the
# following CONFIG lines
CONFIG += sailfishapp_i18n
CONFIG += sailfishapp_i18n_idbased
CONFIG += sailfishapp_i18n_unfinished

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-scintillon.ts
TRANSLATIONS += translations/harbour-scintillon-de.ts
TRANSLATIONS += translations/harbour-scintillon-en.ts
TRANSLATIONS += translations/harbour-scintillon-zh_CN.ts

HEADERS += \
    src/settings.h \
    src/imageprovider.h \
    src/harbour-scintillon.h

modules.files += ../../plugin/Hue/libhueplugin.so \
    ../../plugin/Hue/*.qml \
    ../../plugin/Hue/qmldir
modules.path = /usr/share/harbour-scintillon/Hue/

INSTALLS += modules

OTHER_FILES += README.md
