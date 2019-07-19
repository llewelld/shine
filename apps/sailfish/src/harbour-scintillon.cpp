#include <QtQuick>
#ifdef QT_QML_DEBUG
#include <QDebug>
#endif

#include <sailfishapp.h>

#include "settings.h"
#include "imageprovider.h"

#include "harbour-scintillon.h"

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/harbour-scintillon.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //   - SailfishApp::pathToMainQml() to get a QUrl to the main QML file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    // These values are used by QSettings to access the config file in
    // /home/nemo/.local/share/flypig/harbour-scintillon.conf
    //QCoreApplication::setOrganizationName("flypig");
    QCoreApplication::setOrganizationDomain("www.flypig.co.uk");
    QCoreApplication::setApplicationName(APP_NAME);

    Settings::instantiate();
    qmlRegisterSingletonType<Settings>("harbour.scintillon.settings", 1, 0, "Settings", Settings::provider);

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->engine()->addImageProvider(QLatin1String("scintillon"), new ImageProvider(Settings::getInstance()));
    view->setSource(SailfishApp::pathTo("qml/harbour-scintillon.qml"));

    QQmlContext *ctxt = view->rootContext();
    ctxt->setContextProperty("version", VERSION);
    qDebug() << "harbour-scintillon VERSION string: " << VERSION;
    qDebug() << "VERSION_MAJOR: " << VERSION_MAJOR;
    qDebug() << "VERSION_MINOR: " << VERSION_MINOR;
    qDebug() << "VERSION_BUILD: " << VERSION_BUILD;

    view->show();
    int result = app->exec();

    return result;
}
