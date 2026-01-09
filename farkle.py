#!/usr/bin/env python3

# Implementation of Farkle, using KCD rules, in Python. Done to get a baseline
# before porting to Papyrus

from abc import ABC, abstractmethod
from random import randint
from typing import final

def flip_coin():
  return "Heads" if randint(0, 1) == 0 else "Tails"
def roll_dice():
  return randint(1, 6)

class Player(ABC):
  def __init__(self):
    self.score: int = 0

  @property
  @abstractmethod
  def name(self) -> str:
    ...

  @abstractmethod
  def play(self) -> int:
    '''
    Play a round, returning the player's score this round
    '''
    ...

class HumanPlayer(Player):
  @property
  def name(self) -> str:
    return "Human"

  def play(self) -> int:
    raise NotImplemented()

@final
class AiPlayer(Player):
  def __init__(self, name: str):
    super().__init__()
    self._name = name

  @property
  def name(self) -> str:
    return self._name

  def play(self) -> int:
    raise NotImplemented()

@final
class Game:
  def __init__(self, player1: Player, player2: Player):
    self.target_score = 2000
    self.players = [player1, player2]

    pass

  def play_game(self):
    # Randomise who goes first
    flip = flip_coin()
    assert len(self.players) == 2 # Only support exactly 2 players
    if flip == "Heads":
      self.players.reverse()
    print(f"{flip} - {self.players[0].name} goes first.")

    winner = None
    while winner == None:
      winner = self.play_round()
    print(f"{winner.name} wins!")

  def play_round(self):
    '''
    Play a round, returning a player if they win
    '''
    for player in self.players:
      print(f"{player.name}'s turn")
      player.score += player.play()
      if player.score >= self.target_score:
        return player
    return None

def main():
  a = AiPlayer("Alan")
  b = AiPlayer("Bob")
  g = Game(a, b)
  g.play_game()

if __name__ == "__main__":
  main()
