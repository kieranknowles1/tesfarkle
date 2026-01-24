#!/usr/bin/env python3
from typing import final
import unittest

import farkle
import analysis


@final
class FarkleTestMethods(unittest.TestCase):
  def score_check(self, dice: list[int], expected: int):
    score = farkle.KcdScoreSystem()
    self.assertEqual(score.score_selection(dice), expected)

  def test_bust_chances(self):
    score = farkle.KcdScoreSystem()
    actual = analysis.exact_bust_risk(score)
    for i in range(1, len(actual) + 1):
      given = score.bust_chance(i)
      self.assertAlmostEqual(given, actual[i - 1], places=3)

  def test_run_15(self):
    self.score_check([1, 2, 3, 4, 5], 500)
  def test_run_and_one(self):
    self.score_check([1, 2, 3, 4, 5, 1], 600)
  def test_run_16(self):
    self.score_check([1, 2, 3, 4, 5, 6], 1500)
  def test_run_26(self):
    self.score_check([2, 3, 4, 5, 6], 750)
  def test_run_alone(self):
    self.score_check([1, 2, 3, 4, 5, 5], 550)
    self.score_check([1, 2, 3, 4, 5, 1], 600)

  # Scoring example from Wikipedia
  # For example, if a player throws a combination of one, two, three, three,
  # three, and five, they could do any of the following:
  #     score three threes as 300 and then throw the remaining three dice
  def test_three_threes(self):
    self.score_check([3, 3, 3], 300)
  #     score the single one as 100 and then throw the remaining five dice
  def test_one_one(self):
    self.score_check([1], 100)
  #     score the single five as 50 and then throw the remaining five dice
  def test_one_five(self):
    self.score_check([5], 50)
  #     score three threes, the single one, and the single five for a total of 450 and stop, banking 450 points in that turn
  def test_score_full(self):
    self.score_check([3, 3, 3, 1, 5], 450)
  def test_score_invalid(self):
    # The lone two makes this an invalid combination
    # Players would have to leave it unselected
    self.score_check([1, 2, 3, 3, 3, 5], 0)

  def test_three_ones(self):
    self.score_check([1, 1, 1], 1000)
  def test_four_ones(self):
    self.score_check([1, 1, 1, 1], 2000)
  def test_five_fives(self):
    self.score_check([5, 5, 5, 5, 5], 2000)

  # Commit 71d36ecf52f40c516c14f9324404996e4b26c1fb
  # Scoring three sixes would not be recognised as face iteration stopped at 5
  def test_full_house(self):
    # three sizes, two ones, and a five
    self.score_check([6, 6, 1, 6, 1, 5], 850)

  def test_three_sizes(self):
    self.score_check([6, 6, 6], 600)

  def test_unused_dice(self):
    rolls = [1, 1, 1, 2, 3, 4]
    scoring = farkle.KcdScoreSystem()
    # We're not bust
    self.assertEqual(scoring.score_stats(rolls), farkle.ScoreStats(
      best_score=1000,
      best_dice=3,
      fewest_score=100,
      fewest_dice=1
    ))
    self.assertEqual(scoring.is_bust(rolls), False)
    # But we also don't have a full house
    self.assertEqual(scoring.score_selection(rolls), 0)

    rolls = [1, 3, 5, 2, 4, 4]
    self.assertEqual(scoring.score_stats(rolls), farkle.ScoreStats(
      best_score=500, # Run 1..5
      best_dice=5,
      fewest_score=100,
      fewest_dice=1
    ))

  def test_ai_four_of_kind(self):
    rolls = [2, 2, 2, 2]
    scoring = farkle.KcdScoreSystem()
    self.assertEqual(scoring.score_stats(rolls), farkle.ScoreStats(
      best_score=400,
      best_dice=4,
      fewest_score=200,
      fewest_dice=3
    ))

  def test_ai_one_and_five(self):
    rolls = [5, 1]
    scoring = farkle.KcdScoreSystem()
    self.assertEqual(scoring.score_stats(rolls), farkle.ScoreStats(
      best_score=150,
      best_dice=2,
      fewest_score=100, # Prefer scoring the one, as it gives more points for the same die
      fewest_dice=1
    ))

  def test_ai_two_triples(self):
    rolls = [2, 2, 2, 6, 6, 6]
    scoring = farkle.KcdScoreSystem()
    self.assertEqual(scoring.score_stats(rolls), farkle.ScoreStats(
      best_score=800,
      best_dice=6,
      fewest_score=600, # Prefer scoring the sixes, as it gives more points for the same dice
      fewest_dice=3
    ))

class AiTestMethods(unittest.TestCase):
  def test_reroll_when_won_first_roll(self):
    scoring = farkle.KcdScoreSystem()
    ai = farkle.AiPlayer("Bob")
    game = farkle.Game(scoring, ai, ai, target_score=1000)
    active_dice = 6
    round_score = 0
    scorestats = farkle.ScoreStats(
      best_score=1000, best_dice=3,
      fewest_score=100, fewest_dice=50
    )

    will_reroll = ai.will_reroll(game, active_dice, round_score, scorestats)
    # We shouldn't want to reroll if our first roll won us the game
    self.assertFalse(will_reroll)

if __name__ == "__main__":
  _ = unittest.main()
