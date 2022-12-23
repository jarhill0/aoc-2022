# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'

class Day14 < Solution
  SAND_SOURCE = [500, 0].freeze

  def solve
    @m = map
    @bottom = bottom_of @m

    c = 0
    c += 1 while place_sand
    c
  end

  def place_sand(stop_at_floor = true)
    return false if get_block(SAND_SOURCE) != AIR

    x, y = SAND_SOURCE
    loop do
      xn, yn = next_loc(x, y)
      if xn == x && yn == y
        set_block([x, y], SAND)
        return true # at rest
      elsif stop_at_floor && yn >= @bottom
        return false # fell off
      end
      x = xn
      y = yn
    end
  end

  def next_loc(x, y)
    options(x, y).find { |coords| get_block(coords) == AIR }
  end

  def options(x, y)
    [below(x, y), below_left(x, y), below_right(x, y), [x, y]]
  end

  def below(x, y)
    [x, y + 1]
  end

  def below_left(x, y)
    [x - 1, y + 1]
  end

  def below_right(x, y)
    [x + 1, y + 1]
  end

  def set_block(coords, block)
    @m[coords] = block
  end

  def get_block(coords)
    return ROCK if coords[1] == floor

    @m[coords] || AIR
  end

  AIR = 1
  ROCK = 2
  SAND = 3

  def map
    map = {}
    INP.lines.each do |line|
      prev = nil
      line.split(' -> ').each do |point|
        point = point.split(',').map(&:to_i)
        unless prev.nil?
          iter_points(prev, point) do |pt|
            map[pt] = ROCK
          end
        end
        prev = point
      end
    end
    map
  end

  def iter_points(s, e)
    yield s

    dx = e[0] - s[0]
    dy = e[1] - s[1]
    if dy.zero?
      sx = dx / dx.abs
      x = s[0]
      while x != e[0]
        x += sx
        yield [x, s[1]]
      end
    else
      sy = dy / dy.abs
      y = s[1]
      while y != e[1]
        y += sy
        yield [s[0], y]
      end
    end
  end

  def bottom_of(map)
    map.filter { |_k, v| v == ROCK }.map { |coords, _| coords[1] }.max + 1
  end

  def floor
    @bottom + 1
  end

  def solve2
    @m = map
    @bottom = bottom_of @m

    c = 0
    c += 1 while place_sand(false)
    c
  end
end

Day14.new.execute
