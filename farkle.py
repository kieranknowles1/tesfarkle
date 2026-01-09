#!/usr/bin/env python3

# Implementation of Farkle, using KCD rules, in Python. Done to get a baseline
# before porting to Papyrus

from abc import ABC, abstractmethod
from random import randint
from typing import final

def flip_coin():
  return "Heads" if randint(0, 1) == 0 else "Tails"
def roll_die():
  return randint(1, 6)

class Player(ABC):
  def roll_dice(self, count: int):
    rolls = [roll_die() for _ in range(0, count)]
    print(rolls)
    return rolls

  def __init__(self):
    self.score: int = 0

  def score_set(self, set: list[int]) -> int:
    '''
    Return the score of a dice set, or 0 if invalid
    '''

    def count_of_kind(value: int):
      return set.count(value)

    def is_run(start: int, end: int):
      for i in range(start, end + 1):
        if set.count(i) == 0:
          return False
      return True
    def remove_range(start: int, end: int):
      for i in range(start, end + 1):
        assert set.count(i) > 0
        set.remove(i)
    print(set)

    score = 0
    # Runs of 1..5, 2..6, or 1..6
    if is_run(1, 6):
      remove_range(1, 6)
      score += 1500
    elif is_run(1, 5):
      remove_range(1, 5)
      score += 500
    elif is_run(2, 6):
      remove_range(2, 6)
      score += 750

    def kind_score(face: int, count: int) -> int:
      base = 1000 if face == 1 else 100 * face
      mult = pow(2, count - 3)
      return base * mult

    for face in range(1, 6):
      count = count_of_kind(face)
      print(face, count)
      # 3 or more of a kind
      # face * 100, *2 for 4, *4 for 5, *8 for 6
      # 3 ones are worth 1000
      if count >= 3:
        base = 1000 if face == 1 else 100 * face
        mult = pow(2, count - 3)
        score += base * mult
      # Lone ones/fives
      # 100 points per one, 50 per five
      elif count > 0:
        if face == 1:
          score += 100 * count
        elif face == 5:
          score += 50 * count
        else:
          # Invalid combination
          return 0


    return score

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
    rolls = self.roll_dice(6)
    score = self.score_set(rolls)
    print(score)
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
