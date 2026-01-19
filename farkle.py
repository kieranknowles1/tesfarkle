#!/usr/bin/env python3

# Implementation of Farkle, using KCD rules, in Python. Done to get a baseline
# before porting to Papyrus

from abc import ABC, abstractmethod
from dataclasses import dataclass
from random import randint
from typing import final, override

DICE_COUNT = 6

def flip_coin():
  return "Heads" if randint(0, 1) == 0 else "Tails"
def roll_die():
  return randint(1, 6)
def roll_dice(count: int):
  rolls = [roll_die() for _ in range(0, count)]
  print(rolls)
  return rolls

@dataclass
class ScoreStats:
  '''
  How much can we score and with how many dice using:
    Everything we can
    The least we can
  '''
  best_score: int
  best_dice: int
  fewest_score: int
  fewest_dice: int

class ScoreSystem(ABC):
  @abstractmethod
  def bust_chance(self, i: int) -> float:
    '''
    Approximate bust chance for N dice as a fraction. See test_bust_chances for
    validation against ground truth. Correct to within 3 decimal places (0.1%)
    '''

  def is_bust(self, rolls: list[int]):
    '''
    Is the player bust with the given rolls?
    '''
    result = self.score_stats(rolls)
    return result.best_score == 0

  @abstractmethod
  def score_stats(self, rolls: list[int]) -> ScoreStats:
    '''
    Return the best possible score of a selection, and whether all dice are used
    '''

  def score_selection(self, rolls: list[int]) -> int:
    '''
    Return the score of a dice set, or 0 if one or more dice are unused
    '''
    result = self.score_stats(rolls)
    return result.best_score if result.best_dice == len(rolls) else 0

class KcdScoreSystem(ScoreSystem):
  def bust_chance(self, i) -> float:
    return [
      0.667,
      0.444,
      0.278,
      0.157,
      0.077,
      0.031,
    ][i - 1]

  @override
  def score_stats(self, rolls: list[int]) -> ScoreStats:
    unused = rolls
    best_score = 0
    fewest_score = 0
    fewest_dice = 9999

    def is_run(start: int, end: int):
      for i in range(start, end + 1):
        if unused.count(i) == 0:
          return False
      return True
    def remove_range(start: int, end: int):
      for i in range(start, end + 1):
        assert unused.count(i) > 0
        unused.remove(i)
    def count_of_kind(value: int):
      return unused.count(value)
    def remove_face(face: int):
      return list(filter(face.__ne__, unused))

    def face_value(face: int, count: int) -> int:
      # 3 or more of a kind
      # face * 100, *2 for 4, *4 for 5, *8 for 6
      # 3 ones are worth 1000
      if count >= 3:
        base = 1000 if face == 1 else 100 * face
        mult = pow(2, count - 3)
        return base * mult
      # Lone ones/fives
      # 100 points per one, 50 per five
      if face == 1 or face == 5:
        lone = 50 if face == 5 else 100
        return lone * count
      return 0

    # Runs of 1..5, 2..6, or 1..6
    if is_run(1, 6):
      remove_range(1, 6)
      best_score += 1500
      fewest_score = 100 # Score the 1
      fewest_dice = 1
    elif is_run(1, 5):
      remove_range(1, 5)
      best_score += 500
      fewest_score = 100 # Score the 1
      fewest_dice = 1
    elif is_run(2, 6):
      remove_range(2, 6)
      best_score += 750
      fewest_score = 50 # Score the 5
      fewest_dice = 1

    for face in range(1, 6+1):
      count = count_of_kind(face)
      value = face_value(face, count)

      if value > 0:
        needed = 1 if face in [1, 5] else count
        if needed < fewest_dice:
          fewest_dice = needed
          # If we rolled a one or five, use that
          # otherwise, score three twos etc.
          lone_value = face_value(face, 1)
          fewest_score = lone_value if lone_value > 0 else face_value(face, 3)


        unused = remove_face(face)
      best_score += value

    return ScoreStats(
      best_score = best_score,
      best_dice = len(rolls) - len(unused),
      fewest_score = fewest_score,
      fewest_dice = fewest_dice,
    )

class Player(ABC):
  def __init__(self):
    self.score: int = 0

  @property
  @abstractmethod
  def name(self) -> str:
    ...

  @abstractmethod
  def play(self, scoring: ScoreSystem) -> int:
    '''
    Play a round, returning the player's score this round
    '''
    ...

class HumanPlayer(Player):
  @property
  def name(self) -> str:
    return "Human"

  def play(self, scoring: ScoreSystem) -> int:
    raise NotImplementedError()

@final
class AiPlayer(Player):
  def __init__(self, name: str):
    super().__init__()
    self._name = name

  @property
  def name(self) -> str:
    return self._name

  def play(self, scoring: ScoreSystem) -> int:
    rolls = roll_dice(DICE_COUNT)
    score = scoring.score_stats(rolls)
    print(score)
    raise NotImplementedError()

@final
class Game:
  def __init__(self, scoring: ScoreSystem, player1: Player, player2: Player):
    self.scoring = scoring
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
      player.score += player.play(self.scoring)
      if player.score >= self.target_score:
        return player
    return None

def main():
  scoring = KcdScoreSystem()
  a = AiPlayer("Alan")
  b = AiPlayer("Bob")
  g = Game(scoring, a, b)
  g.play_game()

if __name__ == "__main__":
  main()
