/*
 * Copyright 2015 Michael Zanetti
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

#include "schedule.h"
#include "huebridgeconnection.h"

#include <QColor>
#include <QDebug>
#include <qabstractitemmodel.h>

Schedule::Schedule(const QString &id, const QString &name, QObject *parent)
    : QObject(parent)
    , m_id(id)
    , m_name(name)
    , m_type(TypeAlarm)
    , m_enabled(true)
    , m_autodelete(true)
    , m_recurring(false)
{
//    refresh();
}

QString Schedule::id() const
{
    return m_id;
}

QString Schedule::name() const
{
    return m_name;
}

void Schedule::setNameLocal(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        qDebug() << "setNameLocal name changed to " << name;
        emit nameChanged();
    }
}

void Schedule::setName(const QString &name)
{
    qDebug() << "setName: " << name;
    setNameLocal(name);
    if (m_name != name) {
        QVariantMap params;
        params.insert("name", name);
        qDebug() << "Requesting to set alarm name to " << name;
        HueBridgeConnection::instance()->put("schedules/" + m_id, params, this, "setNameFinished");
    }
}

void Schedule::setNameFinished(int id, const QVariant &response)
{
    Q_UNUSED(id)
    qDebug() << "setName finished" << response;
    QVariantMap result = response.toList().first().toMap();

    if (result.contains("success")) {
        QVariantMap successMap = result.value("success").toMap();
        if (successMap.contains("/schedules/" + m_id + "/name")) {
            QString name = successMap.value("/schedules/" + m_id + "/name").toString();
            qDebug() << "setNameFinished name changed to " << name;
            setNameLocal(name);
        }
    }
}

Schedule::Type Schedule::type() const
{
    return m_type;
}

void Schedule::setTypeLocal(Schedule::Type type)
{
    if (m_type != type) {
        qDebug() << "setTypeLocal type changed to: " << type;
        m_type = type;
        emit typeChanged();
    }
}

void Schedule::setType(Schedule::Type type)
{
    qDebug() << "setType: " << type;
    setTypeLocal(type);
    if (m_type != type) {
        sendDateTime(type, m_dateTime, m_weekdays, m_recurring);
    }
}

QDateTime Schedule::dateTime() const
{
    return m_dateTime;
}

void Schedule::sendDateTime(Type type, const QDateTime &dateTime, const QString &weekdays, bool recurring)
{
    QVariantMap params;

    QString timeString;
    if (type == TypeAlarm) {
        if (recurring) {
            timeString = "W" + QString::number(weekdays.toInt(0, 2)) + "/T" + dateTime.time().toString();
        }
        else {
            timeString = dateTime.toString(Qt::ISODate);
        }
    }
    else {
        timeString = "PT" + dateTime.toString("hh:mm:ss");
    }
    params.insert("localtime", timeString);
    HueBridgeConnection::instance()->put("schedules/" + m_id, params, this, "setDateTimeFinished");
}

void Schedule::setDateTimeRecurring(Type type, const QDateTime &dateTime, const QString &weekdays, bool recurring)
{
    setTypeLocal(type);
    setDateTimeLocal(dateTime);
    setRecurringLocal(recurring);
    setWeekdaysLocal(weekdays);
    sendDateTime(type, dateTime, weekdays, recurring);
}

void Schedule::setDateTime(const QDateTime &dateTime)
{
    qDebug() << "setDateTime: " << dateTime;
    setDateTimeLocal(dateTime);
    if (m_dateTime != dateTime) {
        sendDateTime(m_type, dateTime, m_weekdays, m_recurring);
    }
}

void Schedule::setDateTimeLocal(const QDateTime &dateTime)
{
    if (m_dateTime != dateTime) {
        m_dateTime = dateTime;
        qDebug() << "setDateTimeLocal set dateTime to: " << m_dateTime.toString();
        emit dateTimeChanged();
    }
}

void Schedule::setDateTimeFinished(int id, const QVariant &response)
{
    Q_UNUSED(id)
    qDebug() << "setDateTime finished" << response;
    QVariantMap result = response.toList().first().toMap();

    if (result.contains("success")) {
        QVariantMap successMap = result.value("success").toMap();
        if (successMap.contains("/schedules/" + m_id + "/localtime")) {
            QString timeString = successMap.value("/schedules/" + m_id + "/localtime").toString();
            qDebug() << "setDateTimeFinished date changed to " << timeString;
            applyTimeStringLocal(timeString);
        }

        if (successMap.contains("/schedules/" + m_id + "/starttime")) {
            QDateTime dateTime = successMap.value("/schedules/" + m_id + "/starttime").toDateTime();
            dateTime.setTimeSpec(Qt::TimeSpec::UTC);
            qDebug() << "setDateTimeFinished starttime converted to: " << dateTime.toString();
            setStartTime(dateTime);
        }
    }
}

QDateTime Schedule::startTime() const
{
    return m_startTime;
}

void Schedule::setStartTime(const QDateTime &startTime)
{
    if (m_startTime != startTime) {
        m_startTime = startTime;
        qDebug() << "setStartTime set startTime to: " << m_startTime.toString();
        emit startTimeChanged();
    }
}

QDateTime Schedule::remaining() const
{
    if (!m_dateTime.isValid()) {
        QDateTime dateTime;
        dateTime.setMSecsSinceEpoch(0);
        return dateTime;
    }
    QDateTime remaining;
    qint64 remainingMsecs;
    QDateTime now = QDateTime::currentDateTimeUtc();
    QDateTime dateTime = m_dateTime;
    dateTime.setTimeSpec(Qt::TimeSpec::UTC);

    if (m_startTime.isValid()) {
        qint64 totalMsecs = dateTime.toMSecsSinceEpoch();
        remainingMsecs = totalMsecs + m_startTime.toMSecsSinceEpoch() - now.toMSecsSinceEpoch();
    }
    else {
        if (m_recurring) {
            // Find which is the next day
            remainingMsecs = -1;
            QDateTime alarm = now.toLocalTime();
            alarm.setTime(m_dateTime.time());
            int count = 0;
            while (count < 9 && remainingMsecs < 0) {
                int dayOfWeek = alarm.date().dayOfWeek();
                if (m_weekdays[dayOfWeek] != '0') {
                    remainingMsecs = now.toLocalTime().msecsTo(alarm);
                }
                count++;
                alarm.setDate(alarm.addDays(1).date());
            }
        }
        else {
            remainingMsecs = now.msecsTo(m_dateTime.toUTC());
        }
    }
    remaining.setTimeSpec(Qt::TimeSpec::UTC);
    remaining.setMSecsSinceEpoch(remainingMsecs);
    remaining.setTimeSpec(Qt::TimeSpec::LocalTime);
    return remaining;
}

void Schedule::applyTimeStringLocal(QString &timeString)
{
    qDebug() << "Applying time string locally: " << timeString;
    if (timeString.startsWith("W")) {
        setTypeLocal(Schedule::TypeAlarm);
        setRecurringLocal(true);
        timeString = timeString.right(timeString.length() - 1);
        QString weekdaysNum = timeString.left(timeString.indexOf("/"));
        qDebug() << "setDateTimeFinished weekdaysNum: " << weekdaysNum;
        qDebug() << "setDateTimeFinished recurring weekdays: " << QString("0%1").arg(weekdaysNum.toInt(), 7, 2, QChar('0'));
        setWeekdaysLocal(QString("0%1").arg(weekdaysNum.toInt(), 7, 2, QChar('0')));
        timeString = timeString.right(timeString.length() - (weekdaysNum.length() + 2));
        qDebug() << "setDateTimeFinished time string: " << timeString;
        QDateTime dateTime = QDateTime::fromMSecsSinceEpoch(0);
        dateTime.setTime(QTime::fromString(timeString));
        qDebug() << "setDateTimeFinished recurring dateTime: " << dateTime;
        setDateTimeLocal(dateTime);
    } else if (timeString.contains("PT")){
        setTypeLocal(Schedule::TypeTimer);
        QDateTime dateTime = QDateTime::fromMSecsSinceEpoch(0);
        dateTime.setTime(QTime::fromString(timeString.remove("PT")));
        qDebug() << "setDateTimeFinished countdown: " << dateTime;
        setDateTimeLocal(dateTime);
    } else {
        setTypeLocal(Schedule::TypeAlarm);
        QDateTime dateTime = QDateTime::fromString(timeString, "yyyy-MM-ddTHH:mm:ss");
        qDebug() << "setDateTimeFinished absolute string: " << dateTime.toString();
        setDateTimeLocal(dateTime);
    }
}

QString Schedule::weekdays() const
{
    return m_weekdays;
}

void Schedule::setWeekdaysLocal(const QString &weekdays)
{
    if (m_weekdays != weekdays) {
        qDebug() << "setWeedaysLocal weekdays changed to: " << weekdays;
        m_weekdays = weekdays;
        emit weekdaysChanged();
    }
}

void Schedule::setWeekdays(const QString &weekdays)
{
    qDebug() << "setWeekdays: " << weekdays;
    setWeekdaysLocal(weekdays);
    if (m_weekdays != weekdays) {
        if ((m_type == TypeAlarm) && (m_recurring)) {
            sendDateTime(m_type, m_dateTime, weekdays, m_recurring);
        }
        else {
            setWeekdaysLocal(weekdays);
        }
    }
}

bool Schedule::enabled() const
{
    return m_enabled;
}

void Schedule::setEnabled(bool enabled)
{
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged();
    }
}

bool Schedule::autodelete() const
{
    return m_autodelete;
}

void Schedule::setAutoDelete(bool autodelete)
{
    if (m_autodelete != autodelete) {
        m_autodelete = autodelete;
        emit autodeleteChanged();
    }
}

bool Schedule::recurring() const
{
    return m_recurring;
}

void Schedule::setRecurringLocal(bool recurring)
{
    if (m_recurring != recurring) {
        qDebug() << "setRecurringLocal recurring changed to: " << recurring;
        m_recurring = recurring;
        emit recurringChanged();
    }
}

void Schedule::setRecurring(bool recurring)
{
    qDebug() << "setRecurring: " << recurring;
    setRecurringLocal(recurring);
    if (m_recurring != recurring) {
        sendDateTime(m_type, m_dateTime, m_weekdays, recurring);
    }
}

void Schedule::refresh()
{
//    HueBridgeConnection::instance()->get("groups/" + QString::number(m_id), this, "responseReceived");
}

//void Scene::responseReceived(int id, const QVariant &response)
//{
//    Q_UNUSED(id)

//    m_lightIds.clear();

//    QVariantMap attributes = response.toMap();
//    QVariantList lightsMap = attributes.value("lights").toList();
//    foreach (const QVariant &lightId, lightsMap) {
//        m_lightIds << lightId.toUInt();
//    }

//    emit lightsChanged();

//    QVariantMap action = attributes.value("action").toMap();
//    m_on = action.value("on").toBool();
//    emit stateChanged();
//}

//void Group::setDescriptionFinished(int id, const QVariant &response)
//{
//    Q_UNUSED(id)
//    qDebug() << "setDescription finished" << response;
//    QVariantMap result = response.toList().first().toMap();

//    if (result.contains("success")) {
//        QVariantMap successMap = result.value("success").toMap();
//        if (successMap.contains("/groups/" + QString::number(m_id) + "/name")) {
//            m_name = successMap.value("/groups/" + QString::number(m_id) + "/name").toString();
//            emit nameChanged();
//        }
//    }
//}

//void Group::setStateFinished(int id, const QVariant &response)
//{
//    foreach (const QVariant &resultVariant, response.toList()) {
//        QVariantMap result = resultVariant.toMap();
//        if (result.contains("success")) {
//            QVariantMap successMap = result.value("success").toMap();
//            if (successMap.contains("/groups/" + QString::number(m_id) + "/state/on")) {
//                m_on = successMap.value("/groups/" + QString::number(m_id) + "/state/on").toBool();
//            }
//        }
//    }
//    emit stateChanged();
//}
