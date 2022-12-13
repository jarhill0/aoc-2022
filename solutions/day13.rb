# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'

class Day13 < Solution
  def solve
    packet_pairs.each_with_index.map { |p, i| right_order(p) ? i + 1 : 0 }.sum
  end

  def right_order(pair)
    compare(*pair) == LEFT_LOWER
  end

  LEFT_LOWER = -1
  EQUAL = 0
  LEFT_HIGHER = 1

  def compare(left, right)
    left.zip(right) do |l_elem, r_elem|
      break if r_elem == nil # Ruby's zip is stupid

      if l_elem.class == Integer && r_elem.class == Integer
        if l_elem < r_elem
          return LEFT_LOWER
        elsif l_elem > r_elem
          return LEFT_HIGHER
        end

      elsif l_elem.class == Array && r_elem.class == Array
        result = compare(l_elem, r_elem)
        return result if result != EQUAL

      elsif l_elem.class == Integer
        result = compare([l_elem], r_elem)
        return result if result != EQUAL

      elsif r_elem.class == Integer
        result = compare(l_elem, [r_elem])
        return result if result != EQUAL
      end
    end

    if left.length < right.length
      LEFT_LOWER
    elsif left.length == right.length
      EQUAL
    else
      LEFT_HIGHER
    end
  end

  def packet_pairs
    @packet_pairs ||= INP.grouped_lines.map do |group|
      group.map do |line|
        parse_list(line)
      end.freeze
    end.freeze
  end

  def packets
    @packets ||= INP.lines.filter { |l| l.length > 0 }.map do |line|
      parse_list(line)
    end.freeze
  end

  def parse_list(line)
    eval(line).freeze
  end

  DIVIDERS = [[[2]], [[6]]].freeze

  def solve2
    all_packets = packets + DIVIDERS
    all_packets.sort! do |left, right|
      compare(left, right)
    end
    DIVIDERS.map do |divider|
      all_packets.index(divider) + 1
    end.reduce(:*)
  end
end

Day13.new.execute
