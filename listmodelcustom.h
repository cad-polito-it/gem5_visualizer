// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#ifndef LISTMODELCUSTOM_H
#define LISTMODELCUSTOM_H

#include <QAbstractListModel>
#include <QtQml>

class ListModelCustom : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit ListModelCustom(QObject *parent = nullptr);

    enum {
        DisplayRole = Qt::DisplayRole,
        RowIndexRole = Qt::UserRole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Q_INVOKABLE void setData(const QStringList &data);
    Q_INVOKABLE void setDataFromCC(int cc);
    Qt::ItemFlags flags(const QModelIndex& index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QStringList m_data;
};

#endif // LISTMODELCUSTOM_H
