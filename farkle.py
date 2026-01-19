#!/usr/bin/env python3

# Implementation of Farkle, using KCD rules, in Python. Done to get a baseline
# before porting to Papyrus

from abc import ABC, abstractmethod
from random import randint
from typing import final

DICE_COUNT = 6

def flip_coin():
  return "Heads" if randint(0, 1) == 0 else "Tails"
def roll_die():
  return randint(1, 6)
def total_combinations(numdice: int):
  '''
  Total combinations from rolling N dice
  '''
  return pow(6, numdice)

class DiceIterator:
  '''
  Iterate all possible combinations from rolling N dice
  '''
  def __init__(self, numdice: int):
    self.numdice = numdice
    self.current = 0
    self.max = total_combinations(numdice)
    self.powers = [total_combinations(i - 1) for i in range(1, numdice + 1)]

  def __iter__(self):
    return self

  def __next__(self):
    if self.current >= self.max:
      raise StopIteration()

    value = [
      (self.current // self.powers[i]) % 6 + 1
      for i in range(self.numdice)
    ]
    self.current += 1

    return value

class ScoreSystem(ABC):
  @abstractmethod
  def bust_chance(self, i: int) -> float:
    '''
    Approximate bust chance for N dice as a fraction. See test_bust_chances for
    validation against ground truth. Correct to within 3 decimal places (0.1%)
    '''

  def exact_bust_risk(self) -> list[float]:
    '''
    Calculate the risk of going bust based on number of dice rolled using
    full enumeration.
    VERY SLOW: Precompute results if at all possible. Runs in O(n^6)
    as we check if every possible combination.
    '''
    out = []

    for dice in range(1, DICE_COUNT + 1):
      total = total_combinations(dice)
      bust = 0
      for combination in DiceIterator(dice):
        if self.is_bust(combination):
          bust += 1
      out.append(bust / total)
    return out

  def is_bust(self, rolls: list[int]):
    '''
    Is the player bust with the given rolls?
    '''
    best, _full = self.best_score(rolls)
    return best == 0

  @abstractmethod
  def best_score(self, rolls: list[int]) -> tuple[int, bool]:
    '''
    Return the best possible score of a selection, and whether all dice are used
    '''

  def score_selection(self, rolls: list[int]) -> int:
    '''
    Return the score of a dice set, or 0 if one or more dice are unused
    '''
    result, full = self.best_score(rolls)
    return result if full else 0

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

  def best_score(self, rolls: list[int]) -> tuple[int, bool]:
    unused = rolls
    def count_of_kind(value: int):
      return unused.count(value)

    def is_run(start: int, end: int):
      for i in range(start, end + 1):
        if unused.count(i) == 0:
          return False
      return True
    def remove_range(start: int, end: int):
      for i in range(start, end + 1):
        assert unused.count(i) > 0
        unused.remove(i)
    def remove_face(face: int):
      return list(filter(face.__ne__, unused))

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

    for face in range(1, 6 + 1):
      count = count_of_kind(face)
      # 3 or more of a kind
      # face * 100, *2 for 4, *4 for 5, *8 for 6
      # 3 ones are worth 1000
      if count >= 3:
        base = 1000 if face == 1 else 100 * face
        mult = pow(2, count - 3)
        score += base * mult
        unused = remove_face(face)
      # Lone ones/fives
      # 100 points per one, 50 per five
      elif count > 0:
        if face == 1:
          score += 100 * count
          unused = remove_face(face)
        elif face == 5:
          score += 50 * count
          unused = remove_face(face)
        else:
          # Invalid combination
          pass


    return (score,unused == [])

class Player(ABC):
  def roll_dice(self, count: int):
    rolls = [roll_die() for _ in range(0, count)]
    print(rolls)
    return rolls

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
    rolls = self.roll_dice(DICE_COUNT)
    score = scoring.score_selection(rolls)
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
