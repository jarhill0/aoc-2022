# frozen_string_literal: true

require_relative 'input'

class Day2
  # R=1, P=2, S=3
  # L=1, D=2, W=3
  ENCODING = { 'X' => 1, 'Y' => 2, 'Z' => 3,
               'A' => 1, 'B' => 2, 'C' => 3 }.freeze

  def solve
    encoded.map { |l| score1(*l) }.sum
  end

  def score1(opponent, me)
    outcome = (me - opponent + 1) % 3
    me + 3 * outcome
  end

  def solve2
    encoded.map { |l| score2(*l) }.sum
  end

  def score2(opponent, outcome)
    me = (opponent + outcome) % 3 + 1
    me + 3 * (outcome - 1)
  end

  private

  def encoded
    INP.lines.map(&:split).map { |l| l.map { |m| ENCODING[m] } }
  end
end

d = Day2.new
p d.solve
ans2 = d.solve2
p ans2 if ans2
