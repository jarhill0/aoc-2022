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

  def p2_monkeys
    @p2_monkeys ||= INP.lines.to_h do |line|
      name, operation = line.split(': ')
      if name == 'humn'
        [name, nil]
      elsif /\d/.match?(operation)
        [name, operation.to_i]
      else
        [name, operation.split]
      end
    end.freeze
  end

  def solve2
    root = p2_monkeys['root']
    left = evaluate(root.first)
    right = evaluate(root.last)

    desired = left || right
    find_human_value(left.nil? ? root.first : root.last, desired)
  end

  def evaluate(monkey_name)
    return nil if monkey_name == 'humn'

    monkey = p2_monkeys[monkey_name]

    if monkey.is_a?(Integer)
      monkey
    else
      left, operation, right = monkey
      left_result = evaluate(left)
      right_result = evaluate(right)

      left_result && right_result && left_result.send(operation, right_result)
    end
  end

  def find_human_value(monkey_name, desired)
    return desired if monkey_name == 'humn'

    monkey = p2_monkeys[monkey_name]

    raise 'No human value for Integer monkey!' if monkey.is_a?(Integer)

    left, operation, right = monkey
    left_result = evaluate(left)
    right_result = evaluate(right)

    monkey_name = left_result.nil? ? left : right

    desired =
      if left_result.nil?
        # left_expr OP right_result = desired
        # => left_expr = desired OP_INV right_result
        case operation
        when '+'
          desired - right_result
        when '-'
          desired + right_result
        when '*'
          desired / right_result
        when '/'
          desired * right_result
        else
          raise "Unknown operation #{operation}"
        end
      else

        case operation
        when '+'
          desired - left_result
        when '-'
          # left_result - right_expr = desired
          # => -right_expr = desired - left_result
          # => right_expr = left_result - desired
          left_result - desired
        when '*'
          desired / left_result
        when '/'
          # left_result / right_expr = desired
          # => left_result = right_expr * desired
          # => left_result / desired = right_expr
          left_result / desired
        else
          raise "Unknown operation #{operation}"
        end
      end
    find_human_value(monkey_name, desired)
  end
end

Day21.new.execute
