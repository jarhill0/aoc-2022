# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'

$div_by_three = true
$lcm = 1
$lcm_set = false

class Day11 < Solution
  def solve
    monkeys = starting_state
    shenanigans(monkeys, 20)
    monkeys.map(&:inspection_count).sort.last(2).inject(&:*)
  end

  def starting_state
    monkeys = []
    monkeys.push *(INP.grouped_lines.map do |monkey|
      Monkey.from(monkey, Proc.new { |dest, item| monkeys[dest].receive(item) })
    end)
    $lcm_set = true
    monkeys
  end

  def shenanigans(monkeys, num_rounds)
    num_rounds.times do |i|
      monkeys.each(&:take_turn)
    end
  end

  def solve2
    $div_by_three = false
    monkeys = starting_state
    shenanigans(monkeys, 10000)
    monkeys.map(&:inspection_count).sort.last(2).inject(&:*)
  end
end

class Monkey
  def initialize(items:, operation:, recipient:, tx_item:)
    @items = items
    @operation = operation
    @recipient = recipient
    @inspection_count = 0
    @tx_item = tx_item
  end

  def inspection_count
    @inspection_count
  end

  def receive(item)
    @items.push(item)
  end

  def take_turn
    until @items.empty?
      inspect_and_throw @items.shift
    end
  end

  def inspect_and_throw(item)
    new_item = @operation.call(item)
    new_item /= 3 if $div_by_three
    new_item %= $lcm if $lcm_set
    dest = @recipient.call(new_item)
    @tx_item.call(dest, new_item)

    @inspection_count += 1
  end

  def self.from(lines, tx_item)
    _, starting_items, operation, test, test_true, test_false = lines
    items = starting_items.split(':').last.split(', ').map(&:to_i)
    operation = self.parse_op(operation.split('=').last.strip)
    divisor = test.split.last.to_i
    $lcm *= divisor unless $lcm_set
    true_dest = test_true.split.last.to_i
    false_dest = test_false.split.last.to_i
    recipient = Proc.new { |worry_level| worry_level % divisor == 0 ? true_dest : false_dest }
    Monkey.new(items: items, operation: operation, recipient: recipient, tx_item: tx_item)
  end

  def self.parse_op(operation)
    operand1, operator, operand2 = operation.split
    Proc.new do |old|
      op1 = operand1 == 'old' ? old : operand1.to_i
      op2 = operand2 == 'old' ? old : operand2.to_i
      op1.send(operator, op2)
    end
  end
end

Day11.new.execute
