#include <QtQuick>
#include <sailfishapp.h>
#include "imagitronlistmodel.h"

int main(int argc, char *argv[])
{
    ImagitronListModel ilm;
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();
    view->rootContext()->setContextProperty("imagitronModel", &ilm);
    view->setSource(SailfishApp::pathTo("qml/harbour-imagitron.qml"));
    view->show();
    return app->exec();
}

