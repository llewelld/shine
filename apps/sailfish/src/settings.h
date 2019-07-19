#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QQmlEngine>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString apiKey READ getApiKey WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(bool hideScenesByOtherApps READ getHideScenesByOtherApps WRITE setHideScenesByOtherApps NOTIFY hideScenesByOtherAppsChanged)

public:
    explicit Settings(QObject *parent = nullptr);
    ~Settings();

    static void instantiate(QObject *parent = nullptr);
    static Settings & getInstance();
    static QObject * provider(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE static QString getConfigDir();
    Q_INVOKABLE QString getImageDir() const;
    Q_INVOKABLE QString getImageUrl(const QString &id) const;

    QString getApiKey() const;
    void setApiKey(const QString &apiKey);
    bool getHideScenesByOtherApps() const;
    void setHideScenesByOtherApps(bool hideScenesByOtherApps);

    void loadSettings();
    void saveSettings();

signals:
    void apiKeyChanged();
    void hideScenesByOtherAppsChanged();

public slots:

private:
    static Settings * instance;
    QSettings settings;
    double pixelRatio;
    QString imageDir;

    // Configurable values
    QString apiKey;
    bool hideScenesByOtherApps;
};

#endif // SETTINGS_H
