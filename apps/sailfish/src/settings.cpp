#include <QDesktopServices>
#include <QDateTime>
#include <QDebug>
#include <sailfishapp.h>
#include <mlite5/MGConfItem>

#include "settings.h"

Settings * Settings::instance = nullptr;

Settings::Settings(QObject *parent) : QObject(parent),
    settings(this),
    apiKey(QStringLiteral(""))
{
    QScopedPointer<MGConfItem> ratioItem(new MGConfItem("/desktop/sailfish/silica/theme_pixel_ratio"));
    pixelRatio = ratioItem->value(1.0).toDouble();
    QString dir;
    if (pixelRatio > 1.75) {
        dir = "2.0";
    }
    else if (pixelRatio > 1.5) {
        dir = "1.75";
    }
    else if (pixelRatio > 1.25) {
        dir = "1.5";
    }
    else if (pixelRatio > 1.0) {
        dir = "1.25";
    }
    else {
        dir = "1.0";
    }

    imageDir = SailfishApp::pathTo("qml/images/z" + dir).toString(QUrl::RemoveScheme) + "/";
    qDebug() << "Image folder: " << imageDir;

    loadSettings();
}

Settings::~Settings() {
    saveSettings();
}

void Settings::instantiate(QObject *parent) {
    if (instance == nullptr) {
        instance = new Settings(parent);
    }
}

Settings & Settings::getInstance() {
    return *instance;
}

QObject * Settings::provider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return instance;
}

QString Settings::getConfigDir() {
    return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
}

QString Settings::getImageDir() const {
    return imageDir;
}
QString Settings::getImageUrl(const QString &id) const {
    return imageDir + id + ".png";
}

void Settings::loadSettings() {
    setApiKey(settings.value("main/apiKey", "").toString());
    setHideScenesByOtherApps(settings.value("main/hideScenesByOtherApps").toBool());
}

void Settings::saveSettings() {
    settings.setValue("main/apiKey", apiKey);
    settings.setValue("main/hideScenesByOtherApps", hideScenesByOtherApps);
    settings.sync();
}

QString Settings::getApiKey() const
{
    return apiKey;
}

void Settings::setApiKey(const QString &apiKey)
{
    if (this->apiKey != apiKey) {
        this->apiKey = apiKey;
        emit apiKeyChanged();
    }
}

bool Settings::getHideScenesByOtherApps() const {
    return hideScenesByOtherApps;
}

void Settings::setHideScenesByOtherApps(bool hideScenesByOtherApps) {
    if (this->hideScenesByOtherApps != hideScenesByOtherApps) {
        this->hideScenesByOtherApps = hideScenesByOtherApps;
        emit hideScenesByOtherAppsChanged();
    }
}
