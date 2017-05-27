// based on /usr/share/jolla-gallery/pages/GalleryFullscreenPage.qml
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.TransferEngine 1.0
import Sailfish.Ambience 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.ambience 1.0
import com.jolla.settings.accounts 1.0
import com.jolla.signonuiservice 1.0

import org.nemomobile.dbus 2.0
import org.nemomobile.notifications 1.0

SplitViewPage {
    id: fullscreenPage

    closeOnMinimize: false
    property alias model: imageList.model
    property alias currentIndex: imageList.currentIndex
    // property alias autoPlay: imageList.autoPlay
    property bool imageViewerMode: true// false
    property var currentImageItem: model && model.get(currentIndex)

    readonly property bool currentItemIsImage: true //!!currentImageItem && currentImageItem.mimeType.indexOf("image/") == 0

    signal deleteMedia(int index)
    signal requestIndex(int index)

    /*
    DBusInterface {
        id: dbifA
        service: 'com.jolla.ambienced'
        path: '/com/jolla/ambienced'
        bus: DBus.SessionBus
        iface: 'com.jolla.ambienced'
    }
    */

    /*
    Component {
        id: ambienceSettings
        //property alias contentId: ambienceSettingsPage.contentId
        AmbienceSettingsPage {
            ...
            // TODO: fix priveleged user issue :(
        }
    }
    */

    /*

    function createAmbience(url)
    {
        console.log(Ambience.source)
        // var previousAmbienceUrl = Ambience.source
        // url
        var testUrl = "file:///home/nemo/.local/share/ambienced/wallpapers/2023a860e55c4177bf834b7617bf218dhp.jpg"
        Ambience.setAmbience(testUrl, function(ambienceId) {
            console.log(ambienceId)
            pageStack.push(ambienceSettings, {
                'contentId': ambienceId,
                // 'previousAmbienceUrl': previousAmbienceUrl
            })
        })
    }
    */


    /*
    function remove(index) {
        //: Delete an image
        //% "Deleting"
        remorsePopup.execute( qsTrId("gallery-la-deleting"), function() {
            var files = []
            files.push(model.get(index).url)
            fileRemover.deleteFiles(files)
            pageStack.pop();
        })
    }
    */

    open: true
    objectName: "fullscreenPage"
    allowedOrientations: Orientation.All

    /*
    FileRemover {
        id: fileRemover
    }
    */

    /*
    // Update the Cover via window.activeObject property
    Binding {
        target: window
        property: "activeObject"
        value: fullscreenPage.status === PageStatus.Active
               ? { url: fileInfo.source, mimeType: fileInfo.mimeType }
               : { url: "", mimeType: ""}
    }
    */

    onCurrentIndexChanged: {
        if (status !== PageStatus.Active) {
            return
        }
        if (model === undefined || currentIndex >= model.count) {
            // This can happen if all of the images are deleted
            var firstPage = pageStack.previousPage(fullscreenPage)
            while (pageStack.previousPage(firstPage)) {
                firstPage = pageStack.previousPage(firstPage)
            }
            pageStack.pop(firstPage)
            return
        }
        requestIndex(currentIndex)
    }

    /*
    FileInfo {
        id: fileInfo
        source: currentImageItem ? currentImageItem.url : ""
    }
    */

    // This is the share method list, but it also
    // includes the pulley menu
    background: ShareMethodList {
        id: menuList

        property string url: currentImageItem ? currentImageItem.url : ""
        // filter: fileInfo.localFile ? fileInfo.mimeType : "text/x-url"
        objectName: "menuList"
        // source: fileInfo.localFile ? url : ""
        source: url
        anchors.fill: parent
        /*
        content: fileInfo.localFile ? undefined : {
                                                    "type": "text/x-url",
                                                    "status": url
                                                  }
        */
        content: currentImageItem//undefined//{"mimeType":"image/jpeg", "type": "image/jpeg", "status":url, "url":url}// undefined //{"type": "text/x-url", "status": url}

        PullDownMenu {
            id: pullDownMenu

            // visible: (fileInfo.localFile || fullscreenPage.currentItemIsImage)

//            MenuItem {
//                id: openExternallyItem
//                text: qsTr("Open Externally")
//                onClicked: {
//                    Qt.openUrlExternally(currentImageItem.url)
//                }
//            }

            /*

            MenuItem {
                id: detailsMenuItem
                Component {
                    id: detailsComponent
                    DetailsPage {}
                }

                //% "Details"
                text: qsTrId("gallery-me-details")
                // visible: fileInfo.localFile && !fullscreenPage.imageViewerMode
                visible: !fullscreenPage.imageViewerMode
                // TODO:
                // onClicked: window.pageStack.push(detailsComponent, {modelItem: currentImageItem.itemId} )
            }
            */

            /*
            MenuItem {
                id: deleteMenuItem
                //% "Delete"
                text: qsTrId("gallery-me-delete")
                visible: fileInfo.localFile
                onClicked: fullscreenPage.imageViewerMode
                        ? fullscreenPage.remove(fullscreenPage.currentIndex)
                        : deleteMedia(fullscreenPage.currentIndex)
            }
            */

            /*
            MenuItem {
                id: editMenuItem
                //: Gallery image edit, will lead to a page where user can perform edit operations.
                //% "Edit"
                text: qsTrId("gallery-me-edit")
                // visible:  fullscreenPage.currentItemIsImage && !fullscreenPage.imageViewerMode
                visible: !fullscreenPage.imageViewerMode
                enabled: fileInfo.editableImage
                onClicked: pageStack.push("Sailfish.Gallery.ImageEditPage", { source: imageList.currentItemUrl() })
            }
            */

            MenuItem {
                id: createAmbienceMenuItem
                //% "Create ambience"
                text: qsTrId("gallery-me-create_ambience")
                //visible:  fullscreenPage.currentItemIsImage
                onClicked: {
                    Ambience.setAmbience(currentImageItem.url)
                    // createAmbience(currentImageItem.url)
                    //var ret = dbifA.call('createAmbience',
                   //                    currentImageItem.url.toString());
                }
            }
        }

        header: PageHeader {
            /*
            title: fileInfo.localFile ? currentImageItem.title : (imageList._videoActive ?
                                                                             qsTrId("gallery-la-share") : "")
            */
            title: currentImageItem.title
            //% "Share"
            // description: fileInfo.localFile ? qsTrId("gallery-la-share") : ""
            description: qsTrId("gallery-la-share")
            rightMargin: fullscreenPage.isPortrait ? Theme.horizontalPageMargin : Theme.paddingLarge
        }

        // Add "add account" to the footer. User must be able to
        // create accounts in a case there are none.
        footer: BackgroundItem {
            // Disable mousearea
            enabled: addAccountLabel.visible
            Label {
                id: addAccountLabel
                //% "Add account"
                text: qsTrId("gallery-la-add_account")
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                // visible: fileInfo.localFile
            }

            onClicked: {
                signon_ui_service.inProcessParent = fullscreenPage
                accountCreator.startAccountCreation()
            }
        }

        SignonUiService {
            id: signon_ui_service
            inProcessServiceName: "com.harbour.imagitron"
            inProcessObjectPath: "/JollaGallerySignonUi"
        }

        AccountCreationManager {
            id: accountCreator
            serviceFilter: ["sharing","e-mail"]
            endDestination: fullscreenPage
            endDestinationAction: PageStackAction.Pop
        }
        // SplitViewBackHint {}
    }


    // Element for handling the actual flicking and image buffering
    FlickableImageView {
        id: imageList

        // XXX Qt5 Port - workaround PathView bug
        pathItemCount: 3

        contentWidth: fullscreenPage.width
        contentHeight: fullscreenPage.height

        width: fullscreenPage.foregroundItem.width
        height: fullscreenPage.foregroundItem.height

        objectName: "flickableView"
        isPortrait: fullscreenPage.isPortrait
        menuOpen: fullscreenPage.open

        onClicked: {
            fullscreenPage.open = !fullscreenPage.open
        }
    }

    /*
    RemorsePopup {
        id: remorsePopup
    }
    */
}
