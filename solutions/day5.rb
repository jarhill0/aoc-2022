# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'

class Day5 < Solution
  def solve
    @stacks = start
    moves.each { |m| move(*m) }
    top_crates
  end

  def start
    num_stacks = (INP.lines[0].length + 1) / 4

    stacks = Array.new(num_stacks) { [] }
    INP.content.split("\n\n")[0].split("\n").each do |line|
      (0..(num_stacks - 1)).each do |i|
        true_i = 1 + i * 4
        c = line[true_i]
        if 'A' <= c && c <= 'Z'
          stacks[i].push(c)
        end
      end
    end
    stacks.each { |s| s.reverse! }
    stacks
  end

  def moves
    INP.content.split("\n\n")[1].split("\n").map do |line|
      a = line.split
      [a[1].to_i, a[3].to_i - 1, a[5].to_i - 1]
    end
  end

  def move(q, s, d)
    return if q <= 0

    @stacks[d].push(@stacks[s].pop)

    move(q - 1, s, d)
  end

  def top_crates
    @stacks.map { |s| s[-1] }.join
  end

  def solve2
    @stacks = start
    moves.each { |m| move2(*m) }
    top_crates
  end

  def move2(q, s, d)
    rev_items = []

    q.times { rev_items.push(@stacks[s].pop) }
    q.times { @stacks[d].push(rev_items.pop) }
  end
end

Day5.new.execute
