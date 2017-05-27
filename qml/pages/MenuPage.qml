import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        contentWidth: parent.width // Why is this necessary?
        VerticalScrollDecorator {}
        Column {
            id: column
            width: parent.width
            PageHeader {
                title: qsTr("Menu")
            }
            SectionHeader {
                text: qsTr("Links")
            }
            IconTextButton {
                text: qsTr("Art Gallery")
                iconSource: "image://theme/icon-m-link"
                onClicked: {
                    Qt.openUrlExternally("http://simonstalenhag.se/");
                }

            }
            IconTextButton {
                text: qsTr("Sketchbook")
                iconSource: "../res/tumblr.svg"
                onClicked: {
                    Qt.openUrlExternally("http://simonstalenhag.tumblr.com/");
                }
            }
            IconTextButton {
                text: qsTr("\"Tales from the Loop\" hardcover")
                iconSource: "../res/amazon.svg"
                onClicked: {
                    Qt.openUrlExternally("https://www.amazon.com/Tales-Loop-Simon-St%C3%A5lenhag/dp/1624650392");
                }
            }
            IconTextButton {
                text: qsTr("Prints")
                iconSource: "../res/redbubble.png"
                onClicked: {
                    Qt.openUrlExternally("http://www.redbubble.com/people/simonstalenhag");
                }
            }
            IconTextButton {
                text: qsTr("Microblog")
                iconSource: "../res/twitter.svg"
                onClicked: {
                    Qt.openUrlExternally("https://twitter.com/simonstalenhag");
                }
            }
            IconTextButton {
                text: qsTr("Music")
                iconSource: "../res/soundcloud.svg"
                onClicked: {
                    Qt.openUrlExternally("https://soundcloud.com/simon-st-lenhag");
                }
            }
            SectionHeader {
                text: qsTr("About")
            }
            ListItem {
                Label {
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("About artist")
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutSimon.qml"))
                }
            }
            ListItem {
                Label {
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("About developer")
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("About.qml"))
                }
            }

        }
    }
}
