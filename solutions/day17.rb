# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

WIDTH = 7

class Day17 < Solution
  def solve
    @player_inputs = player_inputs
    @piece_inputs = piece_inputs
    @tiles = Tiles.new

    2022.times { drop_piece }

    @tiles.tower_height
  end

  def drop_piece
    piece = @piece_inputs.next.new(@tiles)

    until piece.stopped
      piece.send(@player_inputs.next)
      piece.down
    end

    piece.persist
  end

  def player_inputs
    INP.content.strip.chars.cycle
  end

  def piece_inputs
    [MinusShape, PlusShape, AngleShape, BarShape, SquareShape].cycle
  end

  def solve2; end
end

class Tiles
  def initialize
    @tile_rows = {}
  end

  def row(row_ind)
    @tile_rows[row_ind] ||= 0
  end

  def filled?(row_ind, col_ind)
    (row(row_ind) & mask(col_ind)).nonzero?
  end

  def fill(row_ind, col_ind)
    value = row(row_ind) | mask(col_ind)
    @tile_rows[row_ind] = value
  end

  def tower_height
    (@tile_rows.reject { |_, row| row.zero? }.keys.max || -1) + 1
  end

  def inspect
    (0..tower_height).map do |r|
      "|#{(0...WIDTH).map { |c| filled?(r, c) ? '#' : '.' }.join}|"
    end.reverse.join("\n") + "\n+#{'-' * WIDTH}+"
  end

  private

  def mask(ind)
    1 << ind
  end
end

class Array
  def freeze_2d
    map(&:freeze).freeze
  end
end

class Shape
  def initialize(tiles)
    # coords refer to bottom left corner of the piece
    @col_ind = 2
    @row_ind = tiles.tower_height + 3

    @tiles = tiles
    @stopped = false
  end

  attr_reader :stopped

  def <
    @col_ind -= 1 unless would_intersect(@col_ind - 1, @row_ind)
  end

  def >
    @col_ind += 1 unless would_intersect(@col_ind + 1, @row_ind)
  end

  def down
    if would_intersect(@col_ind, @row_ind - 1)
      @stopped = true
    else
      @row_ind -= 1
    end
  end

  def persist
    real_coords.each do |c, r|
      @tiles.fill(r, c)
    end
  end

  private

  def would_intersect(col_ind, row_ind)
    real_coords(col_ind, row_ind).any? { |c, r| c.negative? || c >= WIDTH || row_ind.negative? || @tiles.filled?(r, c) }
  end

  def real_coords(col_ind = nil, row_ind = nil)
    # coords refer to bottom left corner of the piece
    col_ind ||= @col_ind
    row_ind ||= @row_ind

    self.class::RAW_SHAPE.reverse.each_with_index.flat_map do |row, row_offset|
      row.each_with_index.filter { |tile, _| tile }.map do |_, col_offset|
        [col_ind + col_offset, row_ind + row_offset]
      end
    end
  end
end

class MinusShape < Shape
  RAW_SHAPE = [[true, true, true, true]].freeze_2d
end

class BarShape < Shape
  RAW_SHAPE = [[true], [true], [true], [true]].freeze_2d
end

class SquareShape < Shape
  RAW_SHAPE = [
    [true, true],
    [true, true]
  ].freeze_2d
end

class PlusShape < Shape
  RAW_SHAPE = [
    [false, true, false],
    [true, true, true],
    [false, true, false]
  ].freeze_2d
end

class AngleShape < Shape
  RAW_SHAPE = [
    [false, false, true],
    [false, false, true],
    [true, true, true]
  ].freeze_2d
end

Day17.new.execute
