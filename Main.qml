import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtMultimedia

Rectangle {
    id: container
    width: Screen.width
    height: Screen.height
    color: "black"
    state: "video"

    readonly property string assetsPath: "/usr/share/sddm/themes/sa2-login/assets/"

    // --- PLAYLIST SINCRONIZADA COM SEU TXT ---
    property var playlist: [
        "Live&Learn(Instrumental)", "EscapeFromTheCity(Instrumental)", "metalHarbor",
        "finalRush", "itDoesntMatter", "pumpkinHill", "aquaticMine", "meteorHerd",
        "unknownFromMe", "believeInMyself", "RadicalHighway", "whiteJungle",
        "skyRail", "throwItAllAway", "eggman", "flyInTheFreedom", "supportingMe", "live&Learn"
    ]
    property int currentTrackIndex: 0
    property string currentTrackName: (playlist && playlist.length > 0) ? playlist[currentTrackIndex] : ""

    function updateTime() {
        var date = new Date()
        clockText.text = date.toLocaleTimeString(Qt.locale(), "HH:mm")
    }

    function goToLogin() {
        if (container.state !== "login") {
            startRiff.stop() 
            container.state = "login"
            jukebox.play()
        }
    }

    Component.onCompleted: {
        updateTime()
    }

    MediaPlayer {
        id: startRiff
        audioOutput: AudioOutput { volume: 1.0 }
        source: assetsPath + "music/riff.mp3"
    }

    MediaPlayer {
        id: jukebox
        audioOutput: AudioOutput { volume: 1.0 }
        // Forçamos o refresh do source apenas quando necessário
        source: (container.state === "login" && currentTrackName !== "") 
                ? "file://" + assetsPath + "music/" + currentTrackName + ".mp3" 
                : ""
        loops: MediaPlayer.Infinite
        
        onErrorOccurred: (error, errorString) => {
            console.log("Erro na Jukebox: " + errorString + " | Fonte tentada: " + source)
        }
    }

    // --- ESTADO 0: VÍDEO INTRO ---
    Item {
        id: videoScreen
        anchors.fill: parent
        visible: container.state === "video"
        
        VideoOutput { 
            id: vOut
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop 
        }

        MediaPlayer {
            id: introPlayer
            videoOutput: vOut
            audioOutput: AudioOutput { volume: 1.0 }
            source: assetsPath + "video/intro.mp4"
            autoPlay: true
            onPlaybackStateChanged: {
                if (playbackState === MediaPlayer.StoppedState && container.state === "video") {
                    container.state = "lock"
                    startRiff.play()
                }
            }
        }

        MouseArea { 
            anchors.fill: parent
            onClicked: { 
                introPlayer.stop()
                container.state = "lock"
                startRiff.play()
            } 
        }
    }

    Image { 
        id: backgroundImage
        anchors.fill: parent
        source: assetsPath + "fundo.png"
        fillMode: Image.PreserveAspectCrop
        visible: container.state !== "video" 
    }

    // --- ESTADO 1: LOCK SCREEN (PRESS START) ---
    Item {
        id: lockScreen
        anchors.fill: parent
        visible: container.state === "lock"
        focus: container.state === "lock"

        Item {
            id: logoClockContainer
            anchors.centerIn: parent
            width: 700; height: 400
            opacity: container.state === "lock" ? 1.0 : 0.0
            scale: container.state === "lock" ? 1.0 : 1.5
            
            Behavior on opacity { NumberAnimation { duration: 800 } }
            Behavior on scale { NumberAnimation { duration: 1200; easing.type: Easing.OutBack } }

            Image { 
                id: sa2LogoBase
                source: assetsPath + "logo_vazia.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit 
            }
            
            Item {
                id: clockWrapper
                width: clockText.width; height: clockText.height
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -35
                anchors.verticalCenterOffset: 15
                
                Text { 
                    id: clockText
                    font.pixelSize: 85
                    font.bold: true
                    font.family: "Nise Sonic"
                    text: "00:00" 
                }
                
                LinearGradient {
                    anchors.fill: clockText; source: clockText
                    gradient: Gradient { 
                        GradientStop { position: 0.48; color: "#FF0000" } 
                        GradientStop { position: 0.52; color: "#00CCFF" } 
                    }
                }
            }
        }

        Item {
            id: pressStartContainer
            anchors.top: logoClockContainer.bottom
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            width: pressStartText.width
            height: pressStartText.height

            Text {
                id: pressStartText
                text: "PRESS START BUTTON"
                font.pixelSize: 38
                font.bold: true
                color: "white"
            }

            SequentialAnimation on opacity {
                running: container.state === "lock"
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.1; duration: 600; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.1; to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
            }

            LinearGradient {
                anchors.fill: pressStartText; source: pressStartText
                gradient: Gradient { 
                    GradientStop { position: 0.0; color: "#FF0000" }
                    GradientStop { position: 0.5; color: "#800080" }
                    GradientStop { position: 1.0; color: "#0000FF" }
                }
            }
        }

        MouseArea { anchors.fill: parent; onClicked: goToLogin() }
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                goToLogin()
                event.accepted = true
            }
        }
    }

    // --- ESTADO 2: LOGIN SCREEN (JUKEBOX) ---
    Item {
        id: loginScreen
        anchors.fill: parent
        visible: container.state === "login"

        RowLayout {
            anchors.centerIn: parent; spacing: 100

            ColumnLayout {
                spacing: 15
                Image {
                    id: cdDisc; Layout.preferredWidth: 260; Layout.preferredHeight: 260; source: assetsPath + "cd.png"
                    RotationAnimation on rotation { 
                        from: 0; to: 360; duration: 4000; loops: Animation.Infinite
                        running: container.state === "login" 
                    }
                }
                
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: 10
                    Button { 
                        flat: true; implicitWidth: 40
                        contentItem: Text { text: "◀"; font.pixelSize: 30; color: "#FF0000"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                        onClicked: { 
                            currentTrackIndex = (currentTrackIndex - 1 + playlist.length) % playlist.length
                            jukebox.play() 
                        } 
                    }
                    Item {
                        width: 200; height: 40
                        Text { 
                            id: musicNameText; anchors.centerIn: parent; width: 200
                            text: currentTrackName.toUpperCase()
                            color: "white"; font.bold: true; font.pixelSize: 14
                            elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter 
                        }
                        LinearGradient {
                            anchors.fill: musicNameText; source: musicNameText
                            gradient: Gradient { 
                                GradientStop { position: 0.0; color: "#FF0000" }
                                GradientStop { position: 1.0; color: "#0000FF" }
                            }
                        }
                    }
                    Button { 
                        flat: true; implicitWidth: 40
                        contentItem: Text { text: "▶"; font.pixelSize: 30; color: "#00CCFF"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                        onClicked: { 
                            currentTrackIndex = (currentTrackIndex + 1) % playlist.length
                            jukebox.play() 
                        } 
                    }
                }
            }

            ColumnLayout {
                spacing: 20
                Item {
                    id: avatarArea; Layout.preferredWidth: 280; Layout.preferredHeight: 360; Layout.alignment: Qt.AlignHCenter
                    Image { id: avatarFrame; anchors.fill: parent; source: assetsPath + "avatar_vazio.png"; fillMode: Image.PreserveAspectFit }
                    Image {
                        anchors.fill: parent; anchors.margins: 25; anchors.bottomMargin: 95
                        source: (userModel && userModel.lastUser) ? "image://faces/" + userModel.lastUser : ""
                        fillMode: Image.PreserveAspectCrop
                    }
                    RowLayout {
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 20; anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.9
                        Button { 
                            flat: true; implicitWidth: 35
                            contentItem: Text { text: "▲"; font.pixelSize: 22; color: "#FF0000"; font.bold: true }
                            onClicked: userModel.index = (userModel.index - 1 + userModel.count) % userModel.count 
                        }
                        Item {
                            Layout.fillWidth: true; height: 30
                            Text {
                                id: userLabel; anchors.centerIn: parent; width: parent.width
                                text: (userModel && userModel.lastUser ? userModel.lastUser : "PLAYER").toUpperCase()
                                color: "white"; font.bold: true; font.pixelSize: 22; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                            }
                            LinearGradient {
                                anchors.fill: userLabel; source: userLabel
                                gradient: Gradient { 
                                    GradientStop { position: 0.0; color: "#FF0000" }
                                    GradientStop { position: 1.0; color: "#0000FF" }
                                }
                            }
                        }
                        Button { 
                            flat: true; implicitWidth: 35
                            contentItem: Text { text: "▼"; font.pixelSize: 22; color: "#00CCFF"; font.bold: true }
                            onClicked: userModel.index = (userModel.index + 1) % userModel.count 
                        }
                    }
                }
                TextField {
                    id: passwordField; Layout.preferredWidth: 260; Layout.alignment: Qt.AlignHCenter
                    placeholderText: "PASSWORD"; echoMode: TextInput.Password; font.pixelSize: 18; color: "white"; horizontalAlignment: Text.AlignHCenter
                    background: Rectangle { color: "#111"; border.color: "#00CCFF"; border.width: 2; radius: 4 }
                    onAccepted: sddm.login(userModel.lastUser, passwordField.text, sessionModel.lastIndex)
                    onVisibleChanged: if (visible) forceActiveFocus()
                }
            }
        }
        Keys.onEscapePressed: container.state = "lock"
    }
}
