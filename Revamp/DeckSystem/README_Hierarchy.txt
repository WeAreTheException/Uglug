Deck scene hierarchy:

DeckSystemRoot
├── MatchSetup
│   ├── MatchDeckSetup
│   ├── MatchSeedConfig
│   └── MatchDeckModeConfig
├── PlayerOneDrawPile
│   ├── DrawPileInstance
│   ├── DrawPileView
│   ├── DrawPileCounter
│   └── DrawPileVisuals
├── PlayerTwoDrawPile
│   ├── DrawPileInstance
│   ├── DrawPileView
│   ├── DrawPileCounter
│   └── DrawPileVisuals
├── WorkerPile
│   ├── WorkerSource
│   ├── WorkerPileView
│   └── WorkerPileVisuals
└── DiscardPile
    ├── DeathPile
    ├── SacrificePile
    └── DiscardPileVisuals

Attach scripts only to matching nodes.
Helpers are not attached to nodes.
