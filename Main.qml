import "Deck.js" as Deck
import QtQuick 2.0

Rectangle {
    id: root

    readonly property var playerPos: Qt.point(897.5, 490)
    readonly property var dealerPos: Qt.point(897.5, 80)
    readonly property var cardOffset: 25
    property var deck: []
    property int deckIndex: 0
    property var playerHand: []
    property var dealerHand: []
    property var canPlayerAct: false
    property var showHoleCard: false
    property var playerStands: false

    function newShoe() {
        deck = Deck.createShuffledDeck();
        deckIndex = 0;
    }

    function dealOne() {
        return deck[deckIndex++];
    }

    function startGame() {
        playerHand = [];
        dealerHand = [];
        playerHandModel.clear();
        dealerHandModel.clear();
        deckIndex = 0;
        newShoe();
        showHoleCard = false;
        canPlayerAct = false;
        playerStands = false;
        dealAnimation.start();
    }

    function hitPlayer() {
        var card = dealOne();
        playerHand = playerHand.concat(card);
        playerHandModel.append({
            "source": card.source
        });
    }

    function standPlayer() {
        playerStands = true;
        endGame();
    }

    function hitDealer() {
        var card = dealOne();
        dealerHand = dealerHand.concat(card);
        dealerHandModel.append({
            "source": card.source
        });
    }

    function endGame() {
        canPlayerAct = false;
        showHoleCard = true;
        dealerTurnAnimation.start();
    }

    function getPlayerScore() {
        return Deck.calculateHandValue(playerHand);
    }

    function getDealerScore() {
        var handValue = Deck.calculateHandValue(dealerHand);
        var holeCardValue = !showHoleCard ? (dealerHand.length > 1 ? dealerHand[1].value : 0) : 0;
        return handValue - holeCardValue;
    }

    function playerIsBusted() {
        return getPlayerScore() > 21;
    }

    function dealerIsBusted() {
        return getDealerScore() > 21;
    }

    function playerHasBlackjack() {
        return getPlayerScore() === 21;
    }

    function dealerHasBlackjack() {
        return getDealerScore() === 21 && showHoleCard;
    }

    function playerWins() {
        if (playerIsBusted())
            return false;

        if (showHoleCard) {
            if (dealerIsBusted())
                return true;

            if (playerHasBlackjack() && !dealerHasBlackjack())
                return true;

            if (dealerHasBlackjack() && !playerHasBlackjack())
                return false;

            return getPlayerScore() > getDealerScore();
        }
        return false;
    }

    function formatPlayerScore() {
        var player = getPlayerScore();
        var dealer = getDealerScore();
        if (!showHoleCard)
            return "Hand: " + player;

        if (playerIsBusted())
            return "Hand: " + player + " (Busted)";

        if (playerHasBlackjack() && !dealerHasBlackjack())
            return "Hand: " + player + " (Blackjack, Wins)";

        if (dealerIsBusted())
            return "Hand: " + player + " (Wins)";

        if (player === dealer)
            return "Hand: " + player + " (Push)";

        if (player > dealer)
            return "Hand: " + player + " (Wins)";

        return "Hand: " + player;
    }

    function formatDealerScore() {
        var dealer = getDealerScore();
        var player = getPlayerScore();
        if (!showHoleCard)
            return "Dealer: " + dealer + " + ?";

        if (dealerIsBusted())
            return "Dealer: " + dealer + " (Busted)";

        if (dealerHasBlackjack() && !playerHasBlackjack())
            return "Dealer: " + dealer + " (Blackjack, Wins)";

        if (playerIsBusted())
            return "Dealer: " + dealer + " (Wins)";

        if (dealer === player)
            return "Dealer: " + dealer + " (Push)";

        if (dealer > player)
            return "Dealer: " + dealer + " (Wins)";

        return "Dealer: " + dealer;
    }

    function tryLogin() {
        sddm.login(usernameInput.text, passwordInput.text, session.index);
    }

    ListModel {
        id: playerHandModel
    }

    ListModel {
        id: dealerHandModel
    }

    SequentialAnimation {
        id: playerTurnAnimation

        running: false

        ScriptAction {
            script: {
                if (!canPlayerAct || playerStands) {
                    playerTurnAnimation.stop();
                    return ;
                }
                if (playerIsBusted() || dealerIsBusted() && showHoleCard) {
                    endGame();
                    playerTurnAnimation.stop();
                    return ;
                }
                hitPlayer();
                canPlayerAct = false;
            }
        }

        PauseAnimation {
            duration: 800
        }

        ScriptAction {
            script: {
                if (playerIsBusted() || dealerIsBusted() && showHoleCard) {
                    endGame();
                    return ;
                }
                dealerTurnAnimation.start();
            }
        }

    }

    SequentialAnimation {
        id: dealerTurnAnimation

        running: false

        ScriptAction {
            script: {
                if (playerIsBusted() || dealerIsBusted() && showHoleCard) {
                    endGame();
                    dealerTurnAnimation.stop();
                    return ;
                }
                if (Deck.calculateHandValue(dealerHand) < 17) {
                    hitDealer();
                } else if (!playerStands) {
                    canPlayerAct = true;
                    dealerTurnAnimation.stop();
                }
            }
        }

        PauseAnimation {
            duration: 800
        }

        ScriptAction {
            script: {
                if (playerIsBusted() || dealerIsBusted() && showHoleCard) {
                    endGame();
                    return ;
                }
                if (Deck.calculateHandValue(dealerHand) < 17 && playerStands)
                    dealerTurnAnimation.restart();
                else if (!playerStands)
                    canPlayerAct = true;
            }
        }

    }

    SequentialAnimation {
        id: dealAnimation

        running: false

        ScriptAction {
            script: idleDeck.model = 10
        }

        PauseAnimation {
            duration: 800
        }

        ScriptAction {
            script: hitPlayer()
        }

        PauseAnimation {
            duration: 500
        }

        ScriptAction {
            script: hitDealer()
        }

        PauseAnimation {
            duration: 500
        }

        ScriptAction {
            script: hitPlayer()
        }

        PauseAnimation {
            duration: 500
        }

        ScriptAction {
            script: hitDealer()
        }

        PauseAnimation {
            duration: 500
        }

        ScriptAction {
            script: {
                canPlayerAct = true;
            }
        }

    }

    Image {
        width: parent.width
        height: parent.height
        source: config.background
    }

    Repeater {
        id: idleDeck

        model: 0

        Card {
            id: card

            x: 1400
            y: -height
            hidden: true
            Component.onCompleted: {
                anim.start();
            }

            NumberAnimation {
                id: anim

                target: card
                property: "y"
                to: 130 - (index * 3)
                duration: 200 + (index * 50)
                easing.type: Easing.InOutQuad
            }

        }

    }

    Repeater {
        model: dealerHandModel

        Card {
            id: card

            x: 1400
            y: 100
            source: model.source
            hidden: index === 1 && !showHoleCard
            Component.onCompleted: {
                animX.start();
                animY.start();
            }

            NumberAnimation {
                id: animX

                target: card
                property: "x"
                to: {
                    if (index === 1)
                        return dealerPos.x - width - cardOffset;
                    else if (index > 1)
                        return dealerPos.x + ((index - 1) * cardOffset);
                    return dealerPos.x;
                }
                duration: 300 + (index * 100)
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                id: animY

                target: card
                property: "y"
                to: {
                    if (index === 1)
                        return dealerPos.y;
                    else if (index > 1)
                        return dealerPos.y + ((index - 1) * cardOffset);
                    return dealerPos.y;
                }
                duration: 300 + (index * 100)
                easing.type: Easing.InOutQuad
            }

        }

    }

    Repeater {
        model: playerHandModel

        Card {
            id: card

            x: 1400
            y: 100
            source: model.source
            Component.onCompleted: {
                animX.start();
                animY.start();
            }

            NumberAnimation {
                id: animX

                target: card
                property: "x"
                to: playerPos.x + (index * cardOffset)
                duration: 300 + (index * 100)
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                id: animY

                target: card
                property: "y"
                to: playerPos.y - (index * cardOffset)
                duration: 300 + (index * 100)
                easing.type: Easing.InOutQuad
            }

        }

    }

    Text {
        id: playerScoreText

        text: formatPlayerScore()
        font.pointSize: 24
        color: "#ffffff"
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height - height - 20
        visible: playerHand.length > 0
    }

    Text {
        id: dealerScoreText

        text: formatDealerScore()
        font.pointSize: 24
        color: "#ffffff"
        anchors.horizontalCenter: parent.horizontalCenter
        y: 20
        visible: dealerHand.length > 0
    }

    Button {
        anchors.centerIn: parent
        text: "Play"
        fontSize: 32
        width: 140
        height: 60
        visible: (showHoleCard || deck.length === 0) && !playerWins()
        onClicked: startGame()
    }

    Button {
        text: "Stand"
        x: (1920 / 2) - width - (width / 2)
        y: 1080 - height - 100
        width: 100
        height: 40
        visible: canPlayerAct
        onClicked: {
            if (!canPlayerAct)
                return ;

            standPlayer();
        }
    }

    Button {
        text: "Hit"
        x: (1920 / 2) + (width / 2)
        y: 1080 - height - 100
        width: 100
        height: 40
        visible: canPlayerAct
        onClicked: {
            if (!canPlayerAct)
                return ;

            playerTurnAnimation.restart();
        }
    }

    Rectangle {
        id: loginForm

        anchors.centerIn: parent
        width: layout.width + 25
        height: layout.height + 25
        color: "#88000000"
        visible: playerWins()

        Column {
            id: layout

            anchors.centerIn: parent
            width: 230
            spacing: 10

            Text {
                text: "Username"
                font.pointSize: 18
                color: "#ffffff"
                width: parent.width
            }

            FocusScope {
                id: username

                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 30
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        event.accepted = true;

                }
                KeyNavigation.tab: password
                KeyNavigation.backtab: loginButton

                Rectangle {
                    anchors.fill: parent
                    color: "#ffffff"
                    border.color: "#000000"
                    border.width: 1
                }

                TextInput {
                    id: usernameInput

                    anchors.fill: parent
                    anchors.margins: 5
                    font.pixelSize: 14
                    clip: true
                    focus: true
                }

            }

            Text {
                text: "Password"
                font.pointSize: 18
                color: "#ffffff"
                width: parent.width
            }

            FocusScope {
                id: password

                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 30
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        event.accepted = true;

                }
                KeyNavigation.tab: loginButton
                KeyNavigation.backtab: username

                Rectangle {
                    anchors.fill: parent
                    color: "#ffffff"
                    border.color: "#000000"
                    border.width: 1
                }

                TextInput {
                    id: passwordInput

                    anchors.fill: parent
                    anchors.margins: 5
                    font.pixelSize: 14
                    echoMode: TextInput.Password
                    clip: true
                    focus: true
                    passwordCharacter: "\u25cf"
                }

            }

            Button {
                id: loginButton

                text: "Login"
                width: parent.width
                height: 30
                onClicked: tryLogin()
                KeyNavigation.tab: username
                KeyNavigation.backtab: password
            }

        }

    }

    ComboBox {
        id: session

        anchors.top: parent.top
        anchors.left: parent.left
        width: 200
        anchors.margins: 5
        model: sessionModel
        index: sessionModel.lastIndex
    }

    Button {
        id: powerButton

        text: "Shutdown"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 100
        height: 30
        anchors.margins: 5
        onClicked: sddm.powerOff()
    }

    Button {
        text: "Reboot"
        anchors.bottom: parent.bottom
        anchors.right: powerButton.left
        width: 100
        height: 30
        anchors.margins: 5
        onClicked: sddm.reboot()
    }

}
