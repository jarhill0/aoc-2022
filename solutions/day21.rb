# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day21 < Solution
  def solve
    monkeys['root'].call
  end

  def monkeys
    @monkeys = INP.lines.to_h do |line|
      name, operation = line.split(': ')
      if /\d/.match?(operation)
        num = operation.to_i
        [name, proc { num }]
      else
        a, op, b = operation.split
        [name, proc { monkeys[a].call.send(op, monkeys[b].call) }]
      end
    end.freeze
  end

  def solve2; end
end

Day21.new.execute
