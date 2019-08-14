/*
 * Copyright 2013 Christian Muehlhaeuser
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 2.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Christian Muehlhaeuser <muesli@gmail.com>
 */

#ifndef GROUP_H
#define GROUP_H

#include <QObject>
#include <QPointF>
#include <QColor>

#include "lightinterface.h"

class Group: public LightInterface
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(int lightsCount READ lightsCount NOTIFY lightsChanged)

public:
    Group(int id, const QString &name, QObject *parent = 0);

    int id() const;

    QString name() const;
    void setName(const QString &name);

    // LightInterface implementation
    bool on() const;
    quint8 bri() const;
    quint16 hue() const;
    quint8 sat() const;
    QColor color() const;
    QPointF xy() const;
    quint16 ct() const;
    QString alert() const;
    QString effect() const;
    ColorMode colorMode() const;
    bool reachable() const;

    QList<int> lightIds() const;
    void setLightIds(QList<int> lights);

    bool isGroup() const;
    int lightsCount() const;
    Q_INVOKABLE int light(int index) const;

    void setOnLocal(bool on);

public slots:
    void refresh();
    void setOn(bool on);
    void setBri(quint8 bri);
    void setHue(quint16 hue);
    void setSat(quint8 sat);
    void setColor(const QColor &color);
    void setXy(const QPointF &xy);
    void setCt(quint16 ct);
    void setAlert(const QString &alert);
    void setEffect(const QString &effect);

public:
    Q_INVOKABLE void setOnTimed(bool on, uint transitiontime);
    Q_INVOKABLE void setBriTimed(quint8 bri, uint transitiontime);
    Q_INVOKABLE void setColorTimed(const QColor &color, uint transitiontime);
    Q_INVOKABLE void setCtTimed(quint16 ct, uint transitiontime);

    Q_INVOKABLE void setOnImmediate(bool on);
    Q_INVOKABLE void setBriImmediate(quint8 bri);
    Q_INVOKABLE void setColorImmediate(const QColor &color);
    Q_INVOKABLE void setCtImmediate(quint16 ct);

signals:
    void nameChanged();
    void lightsChanged();

private slots:
    void responseReceived(int id, const QVariant &response);
    void setDescriptionFinished(int id, const QVariant &response);

    void setStateFinished(int id, const QVariant &response);

    void timeout();
private:
    int m_id;
    QString m_name;
    QList<int> m_lightIds;

    bool m_on;
    quint8 m_bri;
    quint16 m_hue;
    quint8 m_sat;
    QPointF m_xy;
    quint16 m_ct;
    QString m_alert;
    QString m_effect;
    ColorMode m_colormode;
    bool m_reachable;

    int m_busyStateChangeId;
    bool m_hueDirty;
    quint16 m_dirtyHue;
    bool m_satDirty;
    quint8 m_dirtySat;
    bool m_briDirty;
    quint8 m_dirtyBri;
    bool m_ctDirty;
    quint16 m_dirtyCt;
    bool m_xyDirty;
    QPointF m_dirtyXy;

    QTimer m_timeout;

    friend class Groups;
};

#endif
