// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#ifndef FILEPARSER_H
#define FILEPARSER_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QColor>
#include <QVector>
#include <QtQml>

class FileParser : public QObject {
    Q_OBJECT
    QML_ELEMENT

public:
    explicit FileParser(QObject *parent = nullptr);

    Q_INVOKABLE bool parseFile(const QUrl &filePathUrl);
    Q_INVOKABLE QUrl stringConversion(const QString &path);
    Q_INVOKABLE QString colorToString(const QColor color);

    Q_INVOKABLE QStringList getListData() const;
    Q_INVOKABLE QVector<QVector<QString>> getTableData() const;
    Q_INVOKABLE QMap<int, QStringList> getRegisters() const;
    Q_INVOKABLE QMap<int, QStringList> getStats() const;
    Q_INVOKABLE QStringList getStringBycc(int CC);
    Q_INVOKABLE int getMaxRowLen() const;
    Q_INVOKABLE void clearData();
    Q_INVOKABLE int getNumOfInstr();
    Q_INVOKABLE int getHighlightedRowByCC(int cc);
    Q_INVOKABLE int getNumOfStalls();

private:
    QStringList m_listData;
    QVector<QVector<QString>> m_tableData;
    QMap<int, int> fCC;
    QMap<int, QStringList> registers;
    QMap<int, QStringList> stats;
    int longestRowVal = -1;
    int numOfStalls = 0;

signals:
    void readEnded();
};

#endif // FILEPARSER_H
