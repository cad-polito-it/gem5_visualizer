// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#ifndef LISTMODELSTATS_H
#define LISTMODELSTATS_H

#include <QAbstractListModel>
#include <QtQml>
#include <QtTypes>

class ListModelStats: public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    ListModelStats(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Q_INVOKABLE void setData(const QMap<int, QStringList> &data);
    Q_INVOKABLE void setCC(int cc);

    Qt::ItemFlags flags(const QModelIndex& index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QMap<int, QStringList> stats;
    int cc = 0;
};

#endif // LISTMODELSTATS_H
