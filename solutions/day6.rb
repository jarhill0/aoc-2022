# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day6 < Solution
  def solve
    buff = []
    i = 0
    INP.content.chars.each do |c|
      i += 1
      buff.push(c)
      next unless buff.length == 4
      return i if Set.new(buff).length == 4

      buff.delete_at(0)
    end
  end

  def solve2
    buff = []
    i = 0
    INP.content.chars.each do |c|
      i += 1
      buff.push(c)
      next unless buff.length == 14
      return i if Set.new(buff).length == 14

      buff.delete_at(0)
    end
  end
end

Day6.new.execute
