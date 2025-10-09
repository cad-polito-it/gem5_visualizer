cmake_minimum_required(VERSION 3.16)

project(SpecialProjectQML VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(DEFINED QT_CMAKE_PREFIX_PATH)
    set(CMAKE_PREFIX_PATH ${QT_CMAKE_PREFIX_PATH})
endif()

find_package(Qt6 REQUIRED COMPONENTS Quick Core Gui)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(gem5_pipeline_visualizer
    main.cpp
)

list(APPEND QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/ ${CMAKE_CURRENT_BINARY_DIR}/)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)
set(QML_IMPORT_PATH ${QML_IMPORT_PATH} CACHE STRING "" FORCE)

qt_add_qml_module(gem5_pipeline_visualizer
    URI SpecialProjectQML
    VERSION 1.0
    QML_FILES
        Main.qml
    SOURCES
        fileparser.h fileparser.cpp
        listmodelcustom.h listmodelcustom.cpp
        matrixmodel.h matrixmodel.cpp
        QML_FILES BaseStyle.qml
        QML_FILES DarkTheme.qml
        QML_FILES LightTheme.qml
        QML_FILES CustomMenuItem.qml
        QML_FILES CustomRadioButton.qml
    RESOURCES
        icons/next.svg
        icons/fastNext.svg
        icons/back.svg
        icons/fastBack.svg
        icons/pause.svg
        icons/play.svg
        QML_FILES SubmenuButton.qml
        SOURCES listmodelregister.h listmodelregister.cpp
        SOURCES listmodelstats.h listmodelstats.cpp
    )

set(QT_QML_GENERATE_QMLLS_INI ON)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(gem5_pipeline_visualizer PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appSpecialProjectQML
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(gem5_pipeline_visualizer
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Core
    PRIVATE Qt6::Gui
)

include(GNUInstallDirs)
install(TARGETS gem5_pipeline_visualizer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
