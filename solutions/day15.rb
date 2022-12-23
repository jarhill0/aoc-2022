# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'

class Day15 < Solution
  P1_ROW = 2_000_000

  def solve
    solve_row(P1_ROW).length
  end

  def parsed
    @parsed ||= INP.lines.map do |line|
      # Sensor at x=2, y=18: closest beacon is at x=-2, y=15
      words = line.split
      x = words[2].split('=')[-1].to_i
      y = words[3].split('=')[-1].to_i
      bx = words[8].split('=')[-1].to_i
      by = words[9].split('=')[-1].to_i
      [[x, y].freeze, [bx, by].freeze].freeze
    end
  end

  def solve2
    4_000_001.times do |y|
      row = solve_row(y)
      p y if (y % 10_000).zero?
      # p row if y % 10000 == 0

      next unless row.num_ranges > 1

      4_000_001.times do |x|
        p [x, y] unless row.include?(x)
      end
    end
  end

  def solve_row(y_coord)
    no_beacon = RangeSet.new
    parsed.each do |sensor, beacon|
      dist_to_row = (sensor[1] - y_coord).abs
      beacon_dist = sensor.zip(beacon).map { |s, b| (s - b).abs }.sum
      next if dist_to_row > beacon_dist

      play = beacon_dist - dist_to_row

      x_min = sensor[0] - play
      x_max = sensor[0] + play

      no_beacon.add((x_min..x_max))
    end

    parsed.each do |_, beacon|
      no_beacon.remove(beacon[0]) if beacon[1] == y_coord
    end

    no_beacon
  end

  CANDIDATES = [[2_882_446, 1_934_422],
                [1_581_951, 2_271_709],
                [2_638_485, 2_650_264],
                [3_133_845, 3_162_635],
                [2_229_474, 3_709_584]].map(&:freeze).freeze

  def solve2b
    CANDIDATES.filter do |x, y|
      return unless x >= 0 && x <= 4_000_000
      return unless y >= 0 && y <= 4_000_000

      !covered?(x, y)
    end.map { |pt| frequency(pt) }.first
  end

  def covered?(x, y)
    parsed.any? do |sensor, beacon|
      radius = sensor.zip(beacon).map { |s, b| (s - b).abs }.sum
      point_dist = sensor.zip([x, y]).map { |s, p| (s - p).abs }.sum

      point_dist <= radius
    end
  end

  def frequency(point)
    x, y = point
    (x * 4_000_000) + y
  end
end

class Range
  def overlaps?(other)
    raise "Got a #{other.class} but expected a Range" unless other.instance_of?(Range)

    include?(other.begin) ||
      include?(other.end) ||
      other.include?(self.begin) ||
      other.include?(self.end)
  end

  def length
    self.end - self.begin + 1
  end
end

class RangeSet
  def initialize
    @ranges = []
  end

  def add(range)
    raise 'not supported' if range.exclude_end?

    existing = overlapping(range)
    delete_inds = existing.map { |_r, i| i }
    ranges = existing.map { |r, _i| r } + [range]

    @ranges.reject!.with_index { |_, i| delete_inds.include?(i) }

    nonoverlapping_insert(coalesced(ranges))
  end

  def remove(point)
    @ranges.map! do |range|
      if range.include?(point)
        split(range, point)
      else
        range
      end
    end.flatten!
  end

  def include?(point)
    @ranges.any? { |r| r.include?(point) }
  end

  def length
    @ranges.map(&:length).sum
  end

  def num_ranges
    @ranges.length
  end

  private

  def nonoverlapping_insert(range)
    ind = @ranges.each_with_index.find { |r, _i| range.end < r.begin }
    if ind.nil?
      @ranges << range
    else
      @ranges.insert(ind[1], range)
    end
  end

  def overlapping(range)
    @ranges.each_with_index.filter { |r, _i| range.overlaps?(r) }
  end

  def coalesced(ranges)
    begin_ = ranges.map(&:begin).min
    end_ = ranges.map(&:end).max
    (begin_..end_)
  end

  def split(range, at)
    [(range.begin..(at - 1)), ((at + 1)..range.end)].filter { |r| r.length.positive? }
  end
end

class Diamond
  def initialize(center, radius)
    @center = center
    @radius = radius
  end

  def include?(point)
    x, y = point
    cx, cy = @center
    (x - cx).abs + (y - cy).abs <= @radius
  end
end

# Day15.new.execute
puts Day15.new.solve2b.to_s
