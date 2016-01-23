// std
#include <tuple>
#include <iostream>
#include <memory>
// Qt
#include <QDebug>
#include <QTest>
#include <QSignalSpy>
#include <QTimer>
#include <QApplication>
#include <QQuickWindow>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQmlContext>
// DOtherSide
#include "DOtherSide/DOtherSide.h"
#include "DOtherSide/DosQObject.h"
#include "DOtherSide/DosQMetaObject.h"
#include "DOtherSide/DosQObject.h"
#include "DOtherSide/DosQAbstractListModel.h"

template<typename Test>
bool ExecuteTest(int argc, char* argv[]) {
    Test test;
    return QTest::qExec(&test, argc, argv) == 0;
}

template<typename Test>
bool ExecuteGuiTest(int argc, char* argv[]) {
    QApplication app(argc, argv);
    Test test;
    return QTest::qExec(&test, argc, argv) == 0;
}

/*
 * Test QGuiApplication
 */
class TestQGuiApplication : public QObject
{
    Q_OBJECT

private slots:
    void testExecution() {
        bool quit = false;
        dos_qguiapplication_create();
        QTimer::singleShot(100, [&quit](){ quit = true; dos_qguiapplication_quit(); });
        dos_qguiapplication_exec();
        QVERIFY(quit);
        dos_qguiapplication_delete();
    }
};

/*
 * Test QApplication
 */
class TestQApplication : public QObject
{
    Q_OBJECT

private slots:
    void testExecution() {
        bool quit = false;
        dos_qapplication_create();
        QTimer::singleShot(100, [&quit](){ quit = true; dos_qapplication_quit(); });
        dos_qapplication_exec();
        QVERIFY(quit);
        dos_qapplication_delete();
    }
};

/*
 * Test QQmlApplicationEngine
 */
class TestQQmlApplicationEngine : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase() {
        m_engine = nullptr;
    }

    void cleanupTestCase() {
        QVERIFY(m_engine == nullptr);
    }

    void init() {
        QVERIFY(m_engine == nullptr);
        dos_qqmlapplicationengine_create(&m_engine);
        QVERIFY(m_engine != nullptr);
    }

    void cleanup() {
        dos_qqmlapplicationengine_delete(m_engine);
        m_engine = nullptr;
    }

    void testCreateAndDelete() {
        // Implicit by invoking init and cleanup
    }

    void testLoadUrl() {
        void* url = nullptr;
        dos_qurl_create(&url, "qrc:///main.qml", QUrl::TolerantMode);
        QVERIFY(url != nullptr);
        dos_qqmlapplicationengine_load_url(m_engine, url);
        QCOMPARE(engine()->rootObjects().size(), 1);
        QCOMPARE(engine()->rootObjects().front()->objectName(), QString::fromLocal8Bit("testWindow"));
        QVERIFY(engine()->rootObjects().front()->isWindowType());
        dos_qurl_delete(url);
    }

    void testLoadData() {
        dos_qqmlapplicationengine_load_data(m_engine, "import QtQuick.Controls 1.4; ApplicationWindow { objectName: \"testWindow\"}");
        QCOMPARE(engine()->rootObjects().size(), 1);
        QCOMPARE(engine()->rootObjects().front()->objectName(), QString::fromLocal8Bit("testWindow"));
        QVERIFY(engine()->rootObjects().front()->isWindowType());
    }

    void testRootObjects() {
        void** rootObjects = nullptr;
        int length = 0;
        void* url = nullptr;
        dos_qurl_create(&url, "qrc:///main.qml", QUrl::TolerantMode);
        dos_qqmlapplicationengine_load_url(m_engine, url);
        dos_qurl_delete(url);
        dos_qqmlapplicationengine_rootObjects(m_engine, &rootObjects, &length);
        QCOMPARE(length, 1);
        QObject* window = reinterpret_cast<QObject*>(rootObjects[0]);
        QVERIFY(window->isWindowType());
        dos_qobjectptr_array_delete(rootObjects);
    }

private:
    QQmlApplicationEngine* engine() { return static_cast<QQmlApplicationEngine*>(m_engine); }

    void* m_engine;
};

/*
 * Test QQmlContext
 */
class TestQQmlContext : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase() {
        m_engine = nullptr;
        m_context = nullptr;
    }

    void cleanupTestCase() {
        QVERIFY(m_engine == nullptr);
        QVERIFY(m_context == nullptr);
    }

    void init() {
        dos_qqmlapplicationengine_create(&m_engine);
        dos_qqmlapplicationengine_context(m_engine, &m_context);
        QVERIFY(m_engine != nullptr);
        QVERIFY(m_context != nullptr);
    }

    void cleanup() {
        m_context = nullptr;
        dos_qqmlapplicationengine_delete(m_engine);
        m_engine = nullptr;
    }

    void testCreateAndDelete() {
        // Implicit by invoking init and cleanup
    }

    void testSetContextProperty() {
        QVariant testData("Test Message");
        dos_qqmlcontext_setcontextproperty(m_context, "testData", &testData);
        engine()->loadData("import QtQuick 2.5; Text { objectName: \"label\"; text: testData } ");
        QObject* label = engine()->rootObjects().first();
        QVERIFY(label != nullptr);
        QCOMPARE(label->objectName(), QString::fromLocal8Bit("label"));
        QCOMPARE(label->property("text").toString(), testData.toString());
    }

private:
    QQmlApplicationEngine* engine() { return static_cast<QQmlApplicationEngine*>(m_engine); }
    QQmlContext* context() { return static_cast<QQmlContext*>(m_context); }

    void* m_engine;
    void* m_context;
};

int main(int argc, char* argv[])
{
    using namespace DOS;

    bool success = true;
    //success &= ExecuteTest<TestQGuiApplication>(argc, argv);
    //success &= ExecuteTest<TestQApplication>(argc, argv);
    //success &= ExecuteGuiTest<TestQQmlApplicationEngine>(argc, argv);
    //success &= ExecuteGuiTest<TestQQmlContext>(argc, argv);

    QString value = "";

    DOS::SignalDefinitions signalDefinitions {DOS::SignalDefinition {"nameChanged", {}}};
    DOS::SlotDefinitions slotDefinitions {DOS::SlotDefinition {"name", QMetaType::QString, {}}, DOS::SlotDefinition {"setName", QMetaType::Void, {QMetaType::QString}}};
    DOS::PropertyDefinitions propertyDefinitions {DOS::PropertyDefinition{"name", QMetaType::QString, "name", "setName", "nameChanged"}};

    auto mo = std::make_shared<DosQMetaObject>(std::make_shared<DosQAbstractListModelMetaObject>(),
                                               "TestClass",
                                               signalDefinitions,
                                               slotDefinitions,
                                               propertyDefinitions);

    auto moh = std::make_unique<DosIQMetaObjectHolder>(mo);

    auto ose = [&value](const QString& name, const std::vector<QVariant>& args) -> QVariant {
        if (name == "name")
            return value;
        else if (name == "setName")
            value = args.front().toString();
        return QVariant();
    };

    void* dPointer = nullptr;

    RowCountCallback rcc;
    ColumnCountCallback ccc;
    DataCallback dc;
    SetDataCallback sdc;
    RoleNamesCallback rnc;
    FlagsCallback fc;
    HeaderDataCallback hdc;

    DosQAbstractListModel testObject(dPointer, moh->data(), ose, rcc, ccc, dc, sdc, rnc, fc, hdc);
    testObject.setObjectName("testObject");
    testObject.setProperty("name", "pippo");

    std::cout  << testObject.property("objectName").toString().toStdString() << std::endl
               << testObject.property("name").toString().toStdString() << std::endl
               << value.toStdString() << std::endl;

    QMetaObject::invokeMethod(&testObject, "setName", Q_ARG(QString, "pluto"));


    std::cout  << testObject.property("objectName").toString().toStdString() << std::endl
               << testObject.property("name").toString().toStdString() << std::endl
               << value.toStdString() << std::endl;


    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("testObject", QVariant::fromValue<QObject*>(&testObject));
    engine.load(QUrl("qrc:///main.qml"));

    return app.exec();
}

#include "test_dotherside.moc"