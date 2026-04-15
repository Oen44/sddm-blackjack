const SUITS = ["clubs", "diamonds", "hearts", "spades"];
const RANKS = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king", "ace"];
const cardBase = Qt.resolvedUrl("cards");

function blackjackValue(rank) {
    if (rank === "ace") return 11;
    if (rank === "king" || rank === "queen" || rank === "jack") return 10;
    return parseInt(rank, 10);
}

function calculateHandValue(hand) {
    let value = 0;
    let aces = 0;

    for (let i = 0; i < hand.length; i++) {
        const cardValue = hand[i].value;
        value += cardValue;
        if (cardValue === 11) aces++;
    }

    while (value > 21 && aces > 0) {
        value -= 10;
        aces--;
    }

    return value;
}

function createDeck() {
    const deck = [];
    let id = 0;

    for (let s = 0; s < SUITS.length; s++) {
        for (let r = 0; r < RANKS.length; r++) {
            const suit = SUITS[s];
            const rank = RANKS[r];
            const value = blackjackValue(rank);
            const filename = `${rank}_of_${suit}.png`;

            deck.push({
                id: id++,
                rank: rank,
                suit: suit,
                value: value,
                filename: filename,
                source: `${cardBase}/${filename}`
            });
        }
    }
    return deck;
}

function shuffleInPlace(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        const tmp = array[i];
        array[i] = array[j];
        array[j] = tmp;
    }
    return array;
}

function createShuffledDeck() {
    const deck = createDeck();
    shuffleInPlace(deck);
    return deck;
}
