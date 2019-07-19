#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <sailfishapp.h>
#include "settings.h"

class ImageProvider : public QQuickImageProvider {
public:
    explicit ImageProvider(Settings const & settings);

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
private:
    QString imageDir;
};

#endif // IMAGEPROVIDER_H
