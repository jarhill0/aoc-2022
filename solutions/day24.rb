# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day24 < Solution
  def solve
    minutes_to_complete
  end

  def minutes_to_complete
    t = 0
    positions = Set[start]

    loop do
      next_positions = Set.new

      positions.each do |position|
        return t if position == finish

        options(position).each do |option|
          next_positions << option unless blizzards.occupied?(t + 1, *option)
        end
      end

      t += 1
      positions = next_positions
    end
  end

  # can stay, or move one unit in any direction
  DELTAS = [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]].each(&:freeze).freeze
  def options(position)
    DELTAS.map { |delta| delta.zip(position).map(&:sum).freeze }.filter do |pos|
      row, col = pos
      ((row >= 0 && row < height) && (col >= 0 && col < width)) || pos == start || pos == finish
    end
  end

  def blizzards
    @blizzards ||= Blizzards.new(parsed_blizzards, width, height)
  end

  def height
    @height ||= INP.lines.length - 2
  end

  def width
    @width ||= INP.lines.first.length - 2
  end

  BLIZZARD_TYPES = {
    '>' => { direction: :horizontal, parity: 1 }.freeze,
    '<' => { direction: :horizontal, parity: -1 }.freeze,
    '^' => { direction: :vertical, parity: -1 }.freeze,
    'v' => { direction: :vertical, parity: 1 }.freeze
  }.freeze

  def parsed_blizzards
    @parsed_blizzards ||= INP.lines[1...-1].each_with_index.flat_map do |line, row|
      line[1...-1].chars.each_with_index.filter_map do |char, col|
        next if char == '.'

        BLIZZARD_TYPES[char].merge({ initial_row: row, initial_column: col }).freeze
      end
    end
  end

  def start
    @start ||= [-1, INP.lines.first[1...-1].chars.index('.')].freeze
  end

  def finish
    @finish ||= [height, INP.lines.last[1...-1].chars.index('.')].freeze
  end

  def solve2; end
end

class Blizzards
  def initialize(blizzards, width, height)
    @width = width
    @height = height
    @horizontal_blizzards = {}
    @vertical_blizzards = {}

    blizzards.each do |blizzard|
      if blizzard[:direction] == :horizontal
        horizontal_blizzards_in_row(blizzard[:initial_row]) << blizzard
      else
        vertical_blizzards_in_column(blizzard[:initial_column]) << blizzard
      end
    end
  end

  def occupied?(time, row, column)
    horizontal_blizzards_in_row(row).any? { |blizzard| position_of(blizzard, time) == column } ||
      vertical_blizzards_in_column(column).any? { |blizzard| position_of(blizzard, time) == row }
  end

  def horizontal_blizzards_in_row(row)
    @horizontal_blizzards[row] ||= []
  end

  def vertical_blizzards_in_column(column)
    @vertical_blizzards[column] ||= []
  end

  def position_of(blizzard, time)
    if blizzard[:direction] == :horizontal
      (blizzard[:initial_column] + (time * blizzard[:parity])) % @width
    else
      (blizzard[:initial_row] + (time * blizzard[:parity])) % @height
    end
  end
end

Day24.new.execute
