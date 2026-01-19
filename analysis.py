#!/usr/bin/env python3

from farkle import DICE_COUNT, KcdScoreSystem, ScoreSystem


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

def exact_bust_risk(scoring: ScoreSystem) -> list[float]:
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
      if scoring.is_bust(combination):
        bust += 1
    out.append(bust / total)
  return out

def main():
  scoring = KcdScoreSystem()
  print(exact_bust_risk(scoring))

if __name__ == "__main__":
  main()
