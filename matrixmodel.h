// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#ifndef MATRIXMODEL_H
#define MATRIXMODEL_H

#include <QAbstractTableModel>
#include <QVector>
#include <QtQml>

class MatrixModel : public QAbstractTableModel {
    Q_OBJECT
    QML_ELEMENT

public:
    explicit MatrixModel(QObject *parent = nullptr);

    enum {
        DisplayRole = Qt::DisplayRole,
        RowIndexRole = Qt::UserRole,
        ColumnIndexole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE void setData(const QVector<QVector<QString>> &data, const int maxRowLen);
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::DisplayRole) override;

    //Qt::ItemFlags flags(const QModelIndex& index) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int getCC();
    Q_INVOKABLE void setCC(int cc);
    Q_INVOKABLE void increaseCC();
    Q_INVOKABLE void decreaseCC();
    Q_INVOKABLE void startFromCC(int cc);

private:
    QVector<QVector<QString>> m_data;
    int maxRowLen;
    int cc=0;
};

#endif // MATRIXMODEL_H
