import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nemomobile.dbus 2.0 // for external gallery view

// TODO: grid
Page {
    id: pageRoot
    onStatusChanged: {
        if (status === PageStatus.Active && pageStack.depth === 1) {
            pageStack.pushAttached("MenuPage.qml", {});
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        /* // TODO
        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    imagitronModel.refresh();
                }
            }
        }
        */
        PageHeader {
            title: qsTr("Simon Stålenhag's Imagitron")
            id: header
        }
        SilicaListView {
            id: mainListView
            clip: true
            anchors.topMargin: header.height
            anchors.fill: parent
            VerticalScrollDecorator {}
            model: imagitronModel
            delegate: Item {
                width: parent.width
                height: width
                Label {
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    anchors.fill: parent
                    anchors.margins: Theme.paddingLarge
                    text: title
                }
                Image {
                    id: image
                    anchors.fill: parent
                    cache: true
                    source: previewUrl
                    fillMode: Image.PreserveAspectCrop
                    smooth: false
                    anchors {
                        left: parent.left
                        right: parent.right
                        // margins: Theme.paddingLarge
                    }
                    BusyIndicator {
                        size: BusyIndicatorSize.Large
                        anchors.centerIn: image
                        running: image.status != Image.Ready
                    }
                }
                BackgroundItem {
                    anchors.fill: parent
                    onClicked: {
                        gallery.openImage()
                    }
                }
                DBusInterface {
                    id: gallery

                    service: 'com.jolla.gallery'
                    path: '/com/jolla/gallery/ui'
                    iface: 'com.jolla.gallery.ui'

                    function openImage() {
                        typedCall('showImages', { type: 'as', value: imagitronModel.getUrlsListForDbus(index) })
                    }
                }
            }
        }
    }
}


