/*
 * Copyright 2013 Michael Zanetti
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
 *      Michael Zanetti <michael_zanetti@gmx.net>
 */

#include "configuration.h"
#include "huebridgeconnection.h"

#include <QNetworkAccessManager>
#include <QDebug>

Configuration::Configuration(QObject *parent):
    HueObject(parent),
    m_connectedToPortal(false),
    m_timezone("unknown")
{
}

void Configuration::refresh()
{
    HueBridgeConnection::instance()->get("config", this, "responseReceived");
}

void Configuration::checkForUpdate()
{
    QVariantMap swupdateMap;
    swupdateMap.insert("checkforupdate", true);
    QVariantMap params;
    params.insert("swupdate", swupdateMap);

    HueBridgeConnection::instance()->put("config", params, this, "checkForUpdateReply");
}

void Configuration::performUpdate()
{
    if (m_updateState != UpdateStateReadyToUpdate) {
        qWarning() << "UpdateState is not \"UpdateStateReadyToUpdate\". Cannot perform update.";
        return;
    }
    QVariantMap swupdateMap;
    swupdateMap.insert("updatestate", (int)UpdateStateUpdating);
    QVariantMap params;
    params.insert("swupdate", swupdateMap);
    HueBridgeConnection::instance()->put("config", params, this, "performUpdateReply");
}

void Configuration::pressLinkButton()
{
    QVariantMap params;
    params.insert("linkbutton", true);
    HueBridgeConnection::instance()->put("config", params, this, "");
}

QString Configuration::name()
{
    return m_name;
}

void Configuration::setName(const QString &name)
{
    if (m_name == name) {
        return;
    }
}

void Configuration::setTimezone(const QString &timezone)
{
    if (m_timezone == timezone) {
        return;
    }

    QVariantMap params;
    params.insert("timezone", timezone);
    HueBridgeConnection::instance()->put("config", params, this, "setTimezoneReply");
}

bool Configuration::connectedToPortal() const
{
    return m_connectedToPortal;
}

QString Configuration::swVersion() const
{
    return m_swVersion;
}

Configuration::UpdateState Configuration::updateState() const
{
    return m_updateState;
}

QString Configuration::swUpdateReleaseNotes() const
{
    return m_url;
}

QString Configuration::timezone() const
{
    return m_timezone;
}

void Configuration::responseReceived(int id, const QVariant &data)
{
    Q_UNUSED(id)
    qDebug() << "got config response" << data;

    QVariantMap resultMap = data.toMap();
    m_name = resultMap.value("name").toString();
    m_swVersion = resultMap.value("swversion").toString();
    m_updateState = (Configuration::UpdateState)resultMap.value("swupdate").toMap().value("updatestate").toInt();
    m_url = resultMap.value("swupdate").toMap().value("url").toString();
    m_connectedToPortal = resultMap.value("portalstate").toMap().value("signedon").toBool();
    QString timezone = resultMap.value("timezone").toString();
    if (m_timezone != timezone) {
        m_timezone = timezone;
        emit timezoneChanged();
    }
    qDebug() << "TIMEZONE " << timezone;
    emit changed();
}

void Configuration::checkForUpdateReply(int id, const QVariant &data)
{
    Q_UNUSED(id)
    qDebug() << "check for update called:" << data;
}

void Configuration::performUpdateReply(int id, const QVariant &data)
{
    Q_UNUSED(id)
    qDebug() << "Update started:" << data;

    refresh();
}

void Configuration::setTimezoneReply(int id, const QVariant &response)
{
    Q_UNUSED(id)
    qDebug() << "got setTimezone result" << response;

    QVariantMap result = response.toList().first().toMap();

    if (result.contains("success")) {
        QVariantMap successMap = result.value("success").toMap();
        if (successMap.contains("/config/timezone")) {
            QString timezone = successMap.value("/config/timezone").toString();
            if (m_timezone != timezone) {
                m_timezone = timezone;
                emit timezoneChanged();
            }

            //refresh();
        }
    }
}
