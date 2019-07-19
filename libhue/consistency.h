#ifndef CONSISTENCY_H
#define CONSISTENCY_H

#include <QObject>

class Lights;
class Groups;

class Consistency : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Lights* lights READ lights WRITE setLights NOTIFY lightsChanged)
    Q_PROPERTY(Groups* groups READ groups WRITE setGroups NOTIFY groupsChanged)
public:
    explicit Consistency(QObject *parent = nullptr);

    Lights *lights() const;
    void setLights(Lights *lights);
    Groups *groups() const;
    void setGroups(Groups *groups);

public:
    Q_INVOKABLE void propagateLight(int idLightChanged);
    Q_INVOKABLE void propagateGroup(int idGroupChanged);
    Q_INVOKABLE void remoteRefresh();

signals:
    void lightsChanged();
    void groupsChanged();

public slots:

private:
    Lights *m_lights;
    Groups *m_groups;
    bool m_noPropagate;
    int m_groupChecking;
};

#endif // CONSISTENCY_H
