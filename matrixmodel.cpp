// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#include "matrixmodel.h"
#include "QDebug"

MatrixModel::MatrixModel(QObject *parent) : QAbstractTableModel(parent) {}

int MatrixModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return m_data.size();
}

int MatrixModel::columnCount(const QModelIndex &parent) const {
    return m_data.isEmpty() ? 0 : maxRowLen;
}

QVariant MatrixModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_data.size() || index.column() >= m_data[index.row()].size() || index.column() >= cc)
        return QString("");
    switch(role) {
    case Qt::DisplayRole:
        return m_data.at(index.row()).at(index.column());
    case RowIndexRole:
        return index.row();
    case ColumnIndexole:
        return index.column() + 1;
    default:
        return QString("");
    }
}

void MatrixModel::setData(const QVector<QVector<QString>> &data, const int maxRowLen) {
    beginResetModel();
    m_data = data;
    this->maxRowLen = maxRowLen;
    endResetModel();
}

bool MatrixModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    return false;
}

QHash<int, QByteArray> MatrixModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[Qt::DisplayRole] = "display";
    names[RowIndexRole] = "rowIndexTable";
    names[ColumnIndexole] = "columnIndexTable";
    return names;
}

int MatrixModel::getCC()
{
    return cc;
}

void MatrixModel::setCC(int cc)
{
    this->cc = (cc >= maxRowLen ? maxRowLen : cc);
    emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
}

void MatrixModel::increaseCC()
{
    cc = (cc >= maxRowLen ? maxRowLen : cc+1);
    emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
}

void MatrixModel::decreaseCC()
{
    cc = (cc <= 0 ? 0 : cc-1);
    emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
}

void MatrixModel::startFromCC(int cc) {
    QVector<QVector<QString>> nv(m_data.begin() + cc, m_data.end());
    setData(nv, maxRowLen);
}