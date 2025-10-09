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
        // Log log("./gem5.log"); //todo: riscrivi il path giusto
        // log.print_diagram();
        // rewrite(log.first_writeback);
    }
    catch (const std::exception& e)
    {
        std::cerr << "Error: " << e.what() << '\n';
        return 1;
    }

    return app.exec();
}
