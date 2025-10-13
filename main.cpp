// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtGui>
#include <QtQml>
#include <QDebug>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
#include <iomanip>
#include <optional>
#include <ranges>
#include <string_view>
#include <cstdint>

#include "fileparser.h"
#include "matrixmodel.h"
#include "listmodelregister.h"
#include "listmodelstats.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("PolitecnicoDiTorino");

    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("SpecialProjectQML", "Main");

    QObject::connect(&engine, &QQmlApplicationEngine::quit, &QGuiApplication::quit);

    try
    {
        QObject *root = engine.rootObjects().first();
		QObject *mainContainer = root->findChild<QObject*>("ContainerDiAntonio");
		MatrixModel *matrixModel = root->findChild<MatrixModel*>("NEO");
		ListModelRegister *listModelRegister = root->findChild<ListModelRegister*>("LINDA");
		ListModelStats *listModelStats = root->findChild<ListModelStats*>("RUST");
		QObject *rightGL = root->findChild<QObject*>("HTML");
		QObject *textInput = root->findChild<QObject*>("FABRIZIO");
		FileParser *parser = root->findChild<FileParser*>("FileParserDiPeppa");
		if (argc == 2)
		{
			parser->clearData();
			if (parser->parseFile(QUrl((std::string("file:") + argv[1]).c_str())))
			{
				mainContainer->setProperty("visible", true);
				matrixModel->setCC(0);
				listModelRegister->setCC(0);
				listModelStats->setCC(0);
				rightGL->setProperty("cc", 0);
				textInput->setProperty("text", "0");
			}
		}
    }
    catch (const std::exception& e)
    {
        std::cerr << "Error: " << e.what() << '\n';
        return 1;
    }

    return app.exec();
}
