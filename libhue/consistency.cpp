#include <qdebug.h>

#include "group.h"
#include "light.h"
#include "lights.h"
#include "groups.h"

#include "consistency.h"

Consistency::Consistency(QObject *parent)
    : QObject(parent)
    , m_lights(nullptr)
    , m_groups(nullptr)
    , m_noPropagate(false)
    , m_groupChecking(-1)
{

}

Lights *Consistency::lights() const
{
    return m_lights;
}

void Consistency::setLights(Lights *lights)
{
    if (m_lights != lights) {
        m_lights = lights;
        emit lightsChanged();
    }
}

Groups *Consistency::groups() const
{
    return m_groups;
}

void Consistency::setGroups(Groups *groups)
{
    if (m_groups != groups) {
        m_groups = groups;
        emit groupsChanged();
    }
}

void Consistency::propagateLight(int idLightChanged)
{
    qDebug() << "Consistency: propagating change for light: " << idLightChanged;
    if (m_groups && m_lights) {
        m_noPropagate = true;
        int count = m_groups->count();
        for (int index = 0; index < count; index++) {
            Group *group = m_groups->get(index);
            if (group && (group->id() != m_groupChecking)) {
                qDebug() << "Consistency: Checking group: " << group->id();
                bool allOn = true;
                QList<int> lightIds = group->lightIds();
                if (lightIds.contains(idLightChanged)) {
                    qDebug() << "Consistency: Group contains light";
                    for (QList<int>::iterator it = lightIds.begin(); allOn && it != lightIds.end(); ++it) {
                        Light * light = m_lights->findLight(*it);
                        qDebug() << "Consistency: light " << *it << " state is " << light->on();
                        if (!light || !light->on()) {
                            allOn = false;
                        }
                    }
                    group->setOnLocal(allOn);
                    qDebug() << "Consistency: group " << group->id() << " turning to " << allOn;
                }
            }
        }
        m_noPropagate = false;
    }
}

void Consistency::propagateGroup(int idGroupChanged)
{
    qDebug() << "Consistency: propagating change for group: " << idGroupChanged;
    if (!m_noPropagate && m_groups && m_lights) {
        Group * group = m_groups->findGroup(idGroupChanged);
        qDebug() << "Consistency: group status is: " << group->on();
        if (group) {
            m_groupChecking = idGroupChanged;
            QList<int> lightIds = group->lightIds();
            for (int lightId : lightIds) {
                Light * light = m_lights->findLight(lightId);
                if (light) {
                    qDebug() << "Consistency: propagating to light: " << light->id();
                    light->setOnLocal(group->on());
                }
            }
            m_groupChecking = -1;
        }
    }
}

void Consistency::remoteRefresh()
{
    qDebug() << "Consistency: remote refresh";
    if (m_lights) {
        m_lights->refresh();
    }
}
