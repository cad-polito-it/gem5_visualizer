// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#ifndef LISTMODELREGISTER_H
#define LISTMODELREGISTER_H

#include <QAbstractListModel>
#include <QtQml>
#include <QtTypes>

class ListModelRegister : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit ListModelRegister(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Q_INVOKABLE void setData(const QMap<int, QStringList> &data);
    Q_INVOKABLE void setCC(int cc);
    Q_INVOKABLE void setStartFromCC(int cc);
    Q_INVOKABLE void increaseVisualFormat();
    Q_INVOKABLE int getVisualFormat();
    Q_INVOKABLE void setVisualFormat(int base);

    Qt::ItemFlags flags(const QModelIndex& index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QMap<int, QStringList> registers;
    int cc = 0;
    int visualFormat = 0; //0: HEX, 1: Decimal, 2: Binary
};

#endif // LISTMODELREGISTER_H
