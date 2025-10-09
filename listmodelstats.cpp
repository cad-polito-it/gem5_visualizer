// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#include "listmodelstats.h"
#include <QAbstractListModel>
#include <QDebug>

ListModelStats::ListModelStats(QObject *parent) : QAbstractListModel(parent) {}

int ListModelStats::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return stats.value(cc).size();
}

int ListModelStats::columnCount(const QModelIndex &parent) const
{
    return 1;
}

QVariant ListModelStats::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= stats.value(cc).size())
        return QVariant();

    return stats.value(cc).at(index.row());
}

bool ListModelStats::setData(const QModelIndex &index, const QVariant &value, int role)
{
    return false;
}

void ListModelStats::setData(const QMap<int, QStringList> &data)
{
    beginResetModel();
    this->stats = data;
    endResetModel();
}

void ListModelStats::setCC(int cc)
{
    this->cc = cc;
    emit dataChanged(index(0), index(stats.value(cc).size() - 1));
}

Qt::ItemFlags ListModelStats::flags(const QModelIndex &index) const
{
    return Qt::ItemFlag();
}

QHash<int, QByteArray> ListModelStats::roleNames() const
{
    QHash<int, QByteArray> names;
    names[Qt::DisplayRole] = "display";
    return names;
}
