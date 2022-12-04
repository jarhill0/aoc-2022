# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'

class Day4 < Solution
  def solve
    ranges.count { |r| full_contained(*r) }
  end

  def ranges
    INP.lines.map do |l|
      l.split(',').map { |a| a.split('-').map(&:to_i) }
    end
  end

  def full_contained(a, b)
    a[0] <= b[0] && a[1] >= b[1] || b[0] <= a[0] && b[1] >= a[1]
  end

  def solve2
    ranges.count { |r| any_overlap(*r) }
  end

  def any_overlap(a, b)
    a[0] <= b[1] && a[1] >= b[0] || b[0] <= a[1] && b[1] >= a[0]
  end
end

Day4.new.execute
