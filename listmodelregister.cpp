// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#include "listmodelregister.h"
#include <QAbstractListModel>
#include <QDebug>
#include <iostream>
ListModelRegister::ListModelRegister(QObject *parent) : QAbstractListModel(parent) {}

int ListModelRegister::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return registers.value(cc).size();
}

int ListModelRegister::columnCount(const QModelIndex &parent) const
{
    return 1;
}

QVariant ListModelRegister::data(const QModelIndex &index, int role) const
{
    QString regFormat;

    if (!index.isValid() || index.row() >= registers.value(cc).size())
        return QVariant();

    int num;
    unsigned int num_u;
    float hehe;
    QString str = registers.value(cc).at(index.row());
    QStringList split = str.split("=");
    if (split.size() <= 1)
        return QVariant();

    switch (visualFormat) {
        case 1:
            num = split[1].toLong(nullptr, 16);
            for (int i = 31; i >= 0; --i) {
                regFormat.append((num & (1 << i)) ? '1' : '0');
            }
            break;
        case 2:
            num_u = static_cast<uint32_t>(split[1].toLong(nullptr, 16));
            hehe = *(float*)&num_u;
            regFormat = QString::number(hehe);
            break;
        case 3:
            num = static_cast<int32_t>(split[1].toUInt(nullptr, 16));
            regFormat = QString::number(num);
            break;
        case 4:
            num_u = static_cast<uint32_t>(split[1].toUInt(nullptr, 16));
            regFormat = QString::number(num_u);
            break;
        default:
            regFormat = split[1].split("x")[1];
            break;

    }
        return (split[0] + ": ").rightJustified(6, ' ') + regFormat;
}

bool ListModelRegister::setData(const QModelIndex &index, const QVariant &value, int role)
{
    return false;
}

void ListModelRegister::setData(const QMap<int, QStringList> &data)
{
    beginResetModel();
    this->registers = data;
    endResetModel();
}

void ListModelRegister::setCC(int cc)
{
    this->cc = cc;
    emit dataChanged(index(0), index(registers.value(cc).size() - 1));
}

void ListModelRegister::setStartFromCC(int cc)
{
    this->cc = cc;
    emit dataChanged(index(0), index(registers.value(cc).size() - 1));
}

void ListModelRegister::increaseVisualFormat()
{
    this->visualFormat = (visualFormat >= 5 ? 0 : visualFormat + 1);
    emit dataChanged(index(0), index(registers.value(cc).size() - 1));
}

int ListModelRegister::getVisualFormat()
{
    return visualFormat;
}

void ListModelRegister::setVisualFormat(int base) {
    this->visualFormat = base < 5 ? base : 0;
    emit dataChanged(index(0), index(registers.value(cc).size() - 1));
}

Qt::ItemFlags ListModelRegister::flags(const QModelIndex &index) const
{
    return Qt::ItemFlag();
}

QHash<int, QByteArray> ListModelRegister::roleNames() const
{
    QHash<int, QByteArray> names;
    names[Qt::DisplayRole] = "display";
    return names;
}
