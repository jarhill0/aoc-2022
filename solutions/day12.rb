# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day12 < Solution
  def solve
    shortest_path_length
  end

  def map
    @map ||= Map.new(INP.lines.map(&:chars))
  end

  def shortest_path_length(start = nil)
    path_length = 0
    curr = start || [map.start]
    visited = Set.new(curr)

    loop do
      new_curr = []

      curr.each do |square|
        return path_length if square == map.end

        explore_next = map.reachable_neighbors(square).filter { |n| !visited.include?(n) }
        new_curr.concat(explore_next)
        visited.merge(explore_next)
      end

      path_length += 1
      curr = new_curr
    end
  end

  def solve2
    shortest_path_length(map.squares_at(0))
  end
end

class Map
  def initialize(grid)
    @grid = grid
  end

  def reachable_neighbors(coords)
    r, c = coords
    me = height(r, c)
    neighbors = [[r + 1, c], [r - 1, c], [r, c + 1], [r, c - 1]]
    neighbors.filter do |neighbor|
      height(*neighbor) <= me + 1
    end
  end

  def squares_at(height)
    squares = []
    each_square do |square, coords|
      squares << coords if value(square) == height
    end
    squares
  end

  def start
    @start ||= each_square do |square, coords|
      return coords if square == 'S'
    end
  end

  def end
    @end ||= each_square do |square, coords|
      return coords if square == 'E'
    end
  end

  private

  def each_square
    @grid.each_with_index do |row, r|
      row.each_with_index { |s, c| yield [s, [r, c]] }
    end
  end

  def height(r, c)
    return 100 if r.negative? || r >= @grid.length

    row = @grid[r]

    return 101 if c.negative? || c >= row.length

    value(row[c])
  end

  def value(square)
    case square
    when 'S'
      value('a')
    when 'E'
      value('z')
    else
      square.ord - 'a'.ord
    end
  end
end

Day12.new.execute
