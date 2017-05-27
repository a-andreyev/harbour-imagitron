import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import Sailfish.Gallery 1.0
import QtMultimedia 5.0
import org.nemomobile.policy 1.0

// TODO: remove video part

SlideshowView {
    id: view

    property bool itemScaled: currentItem !== null && currentItem.itemScaled
    property bool isPortrait
    property bool menuOpen
    property bool autoPlay
    property Item _activeItem
    property bool _applicationActive: window.applicationActive
    property alias _videoActive: permissions.enabled
    property bool _minimizedPlaying

    property real contentWidth: width
    property real contentHeight: height

    signal clicked

    function currentItemUrl() {
        return model.get(currentIndex).url
    }

    interactive: !itemScaled && count > 1


    Component.onCompleted: {
        view.positionViewAtIndex(view.currentIndex, PathView.Center)
        if (!view._activeItem && currentItem) {
            view._activeItem = currentItem
            view._activeItem.active = true
        }
    }

    onCurrentItemChanged: {
        if (!moving && currentItem) {
            if (view._activeItem) {
                view._activeItem.active = false
            }

            view._activeItem = currentItem
            view._activeItem.active = true
        }
    }

    onMovingChanged: {
        if (!moving && view._activeItem != currentItem) {
            if (view._activeItem) {
                view._activeItem.active = false
            }
            mediaPlayer.stop()
            mediaPlayer.source = ""
            view._activeItem = currentItem
            if (view._activeItem) {
                view._activeItem.active = true
            }
        }
    }

    on_ApplicationActiveChanged: {
        if (!_applicationActive) {
            // if we were playing a video when we minimized, store that information.
            _minimizedPlaying = mediaPlayer.playbackState == MediaPlayer.PlayingState
            if (_minimizedPlaying) {
                mediaPlayer.pause() // and automatically pause the video
            }
        } else if (_minimizedPlaying) {
            view._play() // restart playback automatically.  will also go fullscreen.
        }
    }

    function _play() {
        if (_videoActive) {
            mediaPlayer.source = view._activeItem.source
            mediaPlayer.play()
        }
    }

    function _togglePlay() {
        if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
            mediaPlayer.pause()
        } else if (_videoActive) {
            mediaPlayer.source = view._activeItem.source
            mediaPlayer.play()
        }
    }

    function _pause() {
        if (_videoActive) {
            mediaPlayer.source = view._activeItem.source
            mediaPlayer.pause()
        }
    }

    function _stop() {
        mediaPlayer.stop()
    }

    MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaTogglePlayPause; onPressed: view._togglePlay() }
    MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaPlay; onPressed: view._play() }
    MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaPause; onPressed: view._pause() }
    MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaStop; onPressed: view._stop() }
    MediaKey { enabled: keysResource.acquired; key: Qt.Key_ToggleCallHangup; onPressed: view._togglePlay() }

    Permissions {
        id: permissions

        enabled: window.applicationActive && view._activeItem && !view._activeItem.isImage
        applicationClass: "player"

        Resource {
            id: keysResource
            type: Resource.HeadsetButtons
            optional: true
        }
    }

    delegate: Item {
        id: mediaItem

        property QtObject modelData: model
        property bool isImage: model.mimeType.indexOf("image/") == 0
        property bool active
        readonly property bool itemScaled: loader.item.scaled != undefined && loader.item.scaled
        readonly property url source: model.url

        width: view.width
        height: view.height

        visible: view.moving || active

        opacity: Math.abs(x) <= view.width ? 1.0 -  (Math.abs(x) / view.width) : 0

        onActiveChanged: {
            if (active && autoPlay) {
                mediaPlayer.source = source
            }
        }

        Component {
            id: imageComponent

            ImageViewer {
                id: imgViever
                width: view.isPortrait ? Screen.width : Screen.height
                height: view.contentHeight

                source: model.url
                menuOpen: view.menuOpen
                fit: view.isPortrait ? Fit.Width : Fit.Height
                orientation: model.orientation
                enableZoom: !view.moving

                active: mediaItem.active

                onClicked: view.clicked()

                BusyIndicator {
                    id: imgVBusyInd
                    size: BusyIndicatorSize.Medium
                    anchors.centerIn: parent
                    running: true // FIXME: custrom imageViewer
                }
                onSourceChanged: {
                    imgVBusyInd.running=false
                }
            }
        }

        Component {
            id: videoComponent

            VideoPoster {
                property bool scaled

                player: mediaPlayer

                source: model.url
                mimeType: model.mimeType
                active: mediaItem.active
                duration: model.duration

                width: mediaItem.width
                height: mediaItem.height

                contentWidth: view.contentWidth
                contentHeight: view.contentHeight

                onClicked: {
                   view.clicked()
                   if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                       // pause and go splitscreen
                       view._pause()
                   } else if (!view.menuOpen && // negate because we just opened it via view.clicked() above
                                (mediaPlayer.playbackState == MediaPlayer.StoppedState
                              || mediaPlayer.playbackState == MediaPlayer.PausedState)) {
                       // start playback and go fullscreen
                       view._play()
                   }
               }
            }
        }

        // TODO: Move BusyIndicator inside VideoPoster. See bug #20995
        BusyIndicator {
            id: busyIndicator
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            running: autoPlay && !mediaPlayer.hasVideo && mediaPlayer.error == MediaPlayer.NoError
        }

        Loader {
            id: loader

            property int playbackState: mediaPlayer.playbackState

            active: !autoPlay
            anchors.centerIn: mediaItem

            sourceComponent: mediaItem.isImage ? imageComponent: videoComponent
            asynchronous: view.currentIndex != model.index

            // Delay Poster creation until we're in playing state. Without this when auto playing
            // poster will blink at the beginning.
            onPlaybackStateChanged: {
                if (!active && autoPlay && playbackState == MediaPlayer.PlayingState) {
                    loader.active = true
                }
            }
        }
    }

    children: [
        Loader {
            id: mediaPlayerLoader

            sourceComponent: mediaPlayerComponent
            active: false

            width: view.contentWidth
            height: view.contentHeight
            anchors.centerIn: view._activeItem
        }
    ]

    QtObject {
        id: mediaPlayer

        property url source
        onSourceChanged: {
            mediaPlayerLoader.active = true
            mediaPlayerLoader.item.player.source = source
        }

        readonly property int playbackState: mediaPlayerLoader.item
                ? mediaPlayerLoader.item.player.playbackState
                : MediaPlayer.StoppedState
        readonly property int status: mediaPlayerLoader.item
                ? mediaPlayerLoader.item.player.status
                : MediaPlayer.NoMedia
        readonly property bool hasVideo: mediaPlayerLoader.item
                    && mediaPlayerLoader.item.player.hasVideo
        readonly property int error: mediaPlayerLoader.item
                    ? mediaPlayerLoader.item.player.error
                    : MediaPlayer.NoError
        readonly property int position: mediaPlayerLoader.item
                    ? mediaPlayerLoader.item.player.position
                    : 0
        readonly property int duration: mediaPlayerLoader.item
                    ? mediaPlayerLoader.item.player.duration
                    : 0

        onStatusChanged: console.log("status changed", status)

        function play() {
            if (mediaPlayerLoader.item) {
                mediaPlayerLoader.item.player.play()
            }
        }
        function pause() {
            if (mediaPlayerLoader.item) {
                mediaPlayerLoader.item.player.pause()
            }
        }
        function stop() {
            if (mediaPlayerLoader.item) {
                mediaPlayerLoader.item.player.stop()
            }
        }
        function seek(position) {
            if (mediaPlayerLoader.item) {
                mediaPlayerLoader.item.player.seek(position)
            }
        }
    }

    Component {
        id: mediaPlayerComponent

        Item {
            property alias player: videoPlayer

            visible: videoPlayer.playbackState != MediaPlayer.StoppedState

            Rectangle {
                anchors.fill: parent
                color: 'black'
                opacity: video.playing ? 1 : 0
                Behavior on opacity { FadeAnimation {} }
            }

            VideoOutput {
                id: video

                property bool playing: videoPlayer.playbackState == MediaPlayer.PlayingState

                anchors.fill: parent
                source: MediaPlayer {
                    id: videoPlayer

                    autoPlay: view.autoPlay

                    onPlaybackStateChanged: {
                        if (playbackState == MediaPlayer.PlayingState && view.menuOpen) {
                            // go fullscreen for playback if triggered via Play icon.
                            view.clicked()
                        }
                    }
                }

                ScreenBlank {
                    suspend: video.playing
                }
            }
        }
    }
}
