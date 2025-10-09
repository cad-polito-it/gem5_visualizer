// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#include "listmodelcustom.h"
#include <QAbstractListModel>
#include <QDebug>

ListModelCustom::ListModelCustom(QObject *parent) : QAbstractListModel(parent) {}

int ListModelCustom::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_data.size();
}

int ListModelCustom::columnCount(const QModelIndex &parent) const
{
    return 1;
}

QVariant ListModelCustom::data(const QModelIndex &index, int role) const
{
    QStringList strList;
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    switch(role) {
    case Qt::DisplayRole:
        return m_data.at(index.row());
    case RowIndexRole:
        return index.row();
    default:
        return QVariant();
    }
}

bool ListModelCustom::setData(const QModelIndex &index, const QVariant &value, int role)
{
    return false;
}

void ListModelCustom::setData(const QStringList &data)
{
    beginResetModel();
    m_data = data;
    endResetModel();
}

void ListModelCustom::setDataFromCC(int cc) {
    QStringList nd(m_data.begin() + cc, m_data.end());
    setData(nd);
}

Qt::ItemFlags ListModelCustom::flags(const QModelIndex &index) const
{
    return Qt::ItemFlag();
}

QHash<int, QByteArray> ListModelCustom::roleNames() const
{
    QHash<int, QByteArray> names;
    names[Qt::DisplayRole] = "display";
    names[RowIndexRole] = "rowIndex";
    return names;
}
