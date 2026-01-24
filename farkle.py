#!/usr/bin/env python3

# Implementation of Farkle, using KCD rules, in Python. Done to get a baseline
# before porting to Papyrus

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass
from random import randint
import random
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
def percentile_roll(chance: float):
  '''
  Return true in 1/chance cases
  '''
  return random.uniform(0, 1) < chance

def print_status(player: Player, round: int, selection: int):
  print(f"{player.name}: {player.score}/{round}/{selection}")

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
  def bust_chance(self, i: int) -> float:
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
    unused = list(rolls)
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
        needed = 1 if face in [1, 5] else 3
        # Score as few as possible, unless we could get more points with the same number of dice
        if needed < fewest_dice or (needed == fewest_dice and face_value(face, needed) > fewest_score):
          fewest_dice = needed
          fewest_score = face_value(face, needed)

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
    self.score = 0
    self.times_busted = 0

  @property
  @abstractmethod
  def name(self) -> str:
    ...

  @abstractmethod
  def play(self, game: Game) -> int:
    '''
    Play a round, returning the player's score this round
    '''
    ...

class HumanPlayer(Player):
  @property
  def name(self) -> str:
    return "Human"

  def select_dice(self, scoring: ScoreSystem, rolls: list[int]) -> list[int]:
    while True:
      prompt = ", ".join([
        f"{chr(i + ord('a'))}: {rolls[i]}"
        for i in range(len(rolls))
      ])
      print(f"Rolls: {prompt}")
      choice = input("Which dice will you score: ")

      selection = [rolls[ord(i) - ord('a')] for i in choice]
      if scoring.score_selection(selection) > 0:
        return selection
      else:
        print("Invalid combination")


  def play(self, game: Game) -> int:
    active_dice = DICE_COUNT
    round_score = 0

    while True:
      if active_dice == 0: # Start again with a full hand after a full house
        active_dice = DICE_COUNT
      rolls = roll_dice(active_dice)
      if game.scoring.is_bust(rolls):
        self.times_busted += 1
        print("Bust!")
        return 0

      selection = self.select_dice(game.scoring, rolls)
      selection_score = game.scoring.score_selection(selection)

      print_status(self, round_score, selection_score)
      round_score += selection_score
      active_dice -= len(selection)

      reroll = input("Do you want to roll again? (y/n) ") == 'y'

      if not reroll:
        break

    print("Bank")
    return round_score

@final
class AiPlayer(Player):
  def __init__(self, name: str):
    super().__init__()
    self._name = name

  @property
  def name(self) -> str:
    return self._name

  def will_reroll(self, game: Game, active_dice: int, round_score: int, roll_score: ScoreStats) -> bool:
    # If we've won, then stop rolling
    if round_score + self.score + roll_score.best_score >= game.target_score:
      return False

    potential = round_score + roll_score.fewest_score
    risk_mult = potential / 500

    next_roll_dice = active_dice - roll_score.fewest_dice
    next_roll_dice = DICE_COUNT if next_roll_dice == 0 else next_roll_dice

    risk = game.scoring.bust_chance(next_roll_dice)
    chance = (1 - (risk_mult * risk)) ** 3/4
    print(f"Thinking about reroll {chance}")
    return percentile_roll(chance)

  def take_all(self, game: Game, round_score: int, roll_score: ScoreStats):
    score_if_taken = self.score + round_score + roll_score.best_score

    # If we'd win, take it
    if score_if_taken >= game.target_score:
      return True
    # Otherwise, randomise decision
    return percentile_roll(roll_score.best_score / 500 ** 2)

  def play(self, game: Game) -> int:
    active_dice = DICE_COUNT
    round_score = 0

    while True:
      if active_dice == 0: # Start again with a full hand after a full house
        active_dice = DICE_COUNT
      rolls = roll_dice(active_dice)
      if game.scoring.is_bust(rolls):
        self.times_busted += 1
        print("Bust!")
        return 0

      # Do we want to reroll?
      roll_score = game.scoring.score_stats(rolls)
      wants_reroll = self.will_reroll(game, active_dice, round_score, roll_score)

      # If we have a full house, are going to stop rolling, or "choose to", take
      # everything we can
      hand_score: int
      if not wants_reroll or roll_score.best_dice == active_dice or self.take_all(game, round_score, roll_score):
        hand_score = roll_score.best_score
        active_dice -= roll_score.best_dice
        print(f"Take it all {round_score}")
      else:
        hand_score = roll_score.fewest_score
        active_dice -= roll_score.fewest_dice
        print(f"Take as little as possible {round_score}")
      print_status(self, round_score, hand_score)
      round_score += hand_score

      if not wants_reroll:
        break

    print("Bank")
    return round_score

@final
class Game:
  def __init__(
    self,
    scoring: ScoreSystem,
    player1: Player,
    player2: Player,
    random_start: bool = True,
    target_score: int = 2000
  ):
    self.random_start = random_start
    self.scoring = scoring
    self.target_score = target_score
    self.players = [player1, player2]

    pass

  def play_game(self):
    # Randomise who goes first
    if self.random_start:
      flip = flip_coin()
      assert len(self.players) == 2 # Only support exactly 2 players
      if flip == "Heads":
        self.players.reverse()
      print(f"{flip} - {self.players[0].name} goes first.")

    # Reset everyone's score
    for p in self.players:
      p.score = 0

    winner = None
    while winner == None:
      winner = self.play_round()
    print(f"{winner.name} wins!")

    return winner

  def play_round(self):
    '''
    Play a round, returning a player if they win
    '''
    for player in self.players:
      print(f"{player.name}'s turn")

      score = player.play(self)
      if score == 0:
        print(f"{player.name} went bust")
      else:
        print(f"{player.name} scored {score}")
        player.score += score
      if player.score >= self.target_score:
        return player

    print("End of round scores:")
    for player in self.players:
      print(f"\t{player.name}: {player.score}")
    return None

def main():
  scoring = KcdScoreSystem()
  a = HumanPlayer()
  b = AiPlayer("Bob")
  g = Game(scoring, a, b)
  g.play_game()

if __name__ == "__main__":
  main()
