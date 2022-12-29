# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day25 < Solution
  def solve
    Snafu.new(INP.lines.map { |l| Snafu.from(l).to_i }.sum).to_s
  end

  def solve2; end
end

class Snafu
  DIGIT_VALUE = {
    '=' => -2,
    '-' => -1,
    '0' => 0,
    '1' => 1,
    '2' => 2,
  }.freeze
  def self.from(snafu)
    pow = -1
    value = snafu.chars.reverse.map do |char|
      pow += 1
      DIGIT_VALUE[char] * (5**pow)
    end.sum

    Snafu.new(value)
  end

  def initialize(int)
    @value = int
  end

  def to_i
    @value
  end

  DIGITS = {
    -2 => '=',
    -1 => '-',
    0 => '0',
    1 => '1',
    2 => '2',
  }.freeze
  FORBIDDEN_DIGITS = [3, 4].freeze
  def to_s
    digit_values = base_five
    # I'm fairly confident there's an O(n) way to do this (in one pass),
    # but this dumb loop is what I'm feeling right now! 🤪
    while FORBIDDEN_DIGITS.intersect?(digit_values)
      digit_values.each_with_index do |value, index|
        if value > 2
          digit_values[index - 1] += 1
          digit_values[index] -= 5
        end
      end
    end
    digit_values.map { |dv| DIGITS[dv] }.join
  end

  private

  def largest_power
    pow = 0
    pow += 1 while largest_representable_with(pow) < @value
    pow
  end

  def largest_representable_with(pow)
    (0..pow).map { |p| 2 * (5**p) }.sum
  end

  def base_five
    (0..largest_power).reverse_each.map do |pow|
      (@value / (5**pow)) % 5
    end
  end
end

Day25.new.execute
