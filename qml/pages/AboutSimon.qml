import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    SilicaFlickable {
        contentHeight: column.height+Theme.paddingLarge
        anchors.fill: parent

        VerticalScrollDecorator {}

        Column {
            spacing: Theme.paddingLarge
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Simon Stålenhag")
                id: header

            }
            Image {
                source: "../res/simon.jpg"
                fillMode: Image.PreserveAspectCrop
                anchors {
                            left: parent.left
                            right: parent.right
                            margins: Theme.paddingLarge
                        }
                height: width
            }
            Label {
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignJustify
                wrapMode: Text.Wrap
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("The acclaimed artist, concept designer and author of <i>Ur Varselklotet</i> (2014) Simon Stålenhag (b. 1984) is best known for his highly imaginative images and stories portraying illusive sci-fi phenomena in mundane, hyper-realistic Scandinavian landscapes. <i>Ur Varselklotet</i> was ranked by <b>The Guardian</b> as one of the ‘10 Best Dystopias’, in company with works such as Franz Kafka’s <i>The Trial</i> and Andrew Niccol’s <i>Gattaca</i>.<br><br>Not only have Stålenhag’s unique and cinematic images earned him a worldwide fan base, but have also made him a go-to storyteller, concept artist and illustrator for both the film and computer gaming industry. Simon Stålenhag’s work can be seen in films such as <i>Searching for Sugarman</i> (2012), directed by Malik Bendjeloull, and in games such as <i>Ripple Dot Zero</i> (2013).")
            }

        }
    }
}
