# Farkle

Implementation of Farkle in Skyrim, using Kingdom Come Deliverance rules

## Covered Areas

This is primarily a Papyrus project, but also has elements of quest and asset implementation.
A game of Farkle is controlled via a quest which is started using the story manager system.

## Implementation

```mermaid
classDiagram
  class Game {
    +TargetScore
    +PlayGame()
  }

  class Player {
    +int Score
    +PlayRound()*
    +ScoreDice(dice) int
  }
  <<Interface>> Player
  note for Player "Alias on FARGame"

  class HumanPlayer {

  }

  class AiPlayer {

  }
  Player <|-- HumanPlayer
  Player <|-- AiPlayer
  Game ..> Player

  class ScoreSystem {
    +ScoreSelection()*
    +IsBust() int
  }
  <<Interface>> ScoreSystem

  class KcdScoreSystem {
  
  }
  ScoreSystem <|-- KcdScoreSystem

  class FARGame {

  }
  note for FARGame "Main quest for while a game is active"
  FARGame *-- Game
  FARGame *-- ScoreSystem
```