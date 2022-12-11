# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day9 < Solution
  def solve
    visited = Set.new
    tail_positions { |pos| visited.add(pos) }
    visited.length
  end

  def tail_positions(n = 2)
    links = Array.new(n, [0, 0].freeze)
    yield links.last
    moves.each do |dir, amt|
      puts "#{dir} #{amt}"
      amt.times do
        links = update_links(links, dir).freeze
        yield links.last
      end
    end
  end

  def update_links(links, move_dir)
    prev = nil
    links.map do |link|
      new_link = if prev == nil
                   move_head(link, move_dir).freeze
                 else
                   move_tail(prev, link).freeze
                 end
      prev = new_link
      new_link
    end
  end

  def move_head(head, dir)
    x, y = head
    case dir
    when 'U'
      [x, y + 1]
    when 'D'
      [x, y - 1]
    when 'R'
      [x + 1, y]
    when 'L'
      [x - 1, y]
    else
      raise 'Unreachable with proper input'
    end
  end

  def move_tail(head, tail)
    hx, hy = head
    tx, ty = tail
    vx = hx - tx
    vy = hy - ty

    dist_sq = (vx * vx) + (vy * vy)
    if dist_sq <= 2 # touching
      tail
    elsif dist_sq == 4 # one step back, linearly
      [tx + vx / 2, ty + vy / 2]
    else # need a diag move
      [tx + vx / vx.abs, ty + vy / vy.abs]
    end

  end

  def moves
    @moves ||= INP.split_lines.map { |dir, amt| [dir, amt.to_i] }.freeze
  end

  def solve2
    visited = Set.new
    puts '***********'
    tail_positions(10) { |pos| visited.add(pos) }
    visited.length
  end
end

Day9.new.execute
