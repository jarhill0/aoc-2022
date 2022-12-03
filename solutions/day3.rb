# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'

class Day3 < Solution
  def solve
    INP.lines.map {|l| priority(shared(l))}.sum
  end

  def priority(letter)
    if 'z'.ord >= letter.ord && letter.ord >= 'a'.ord
      letter.ord - 'a'.ord + 1
    else
      letter.ord - 'A'.ord + 26 + 1
    end
  end

  def shared(sack)
    p1 = sack[..sack.length/2]
    p2 = sack[(sack.length/2)..]
    p1.chars.find {|c| p2.include?(c)}
  end

  def solve2
    (0..INP.lines.length / 3 - 1).map do |i|
      group = INP.lines[3 * i .. 3 * i + 2]
      priority(shared2(*group))
    end.sum
  end

  def shared2(e1, e2, e3)
    e1.chars.find {|c| e2.include?(c) && e3.include?(c)}
  end
end

Day3.new.execute
