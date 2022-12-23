# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day16 < Solution
  P1_MINUTES = 30

  def solve
    best_flow
  end

  def valves
    @valves ||= INP.split_lines.to_h do |line|
      name = line[1]
      rate = line[4].split('=').last.to_i
      connections = line[9..].map do |c|
        if c.length == 3
          c[0...2]
        else
          c
        end
      end

      [name, { rate:, connections: }.freeze]
    end.freeze
  end

  def flow_rate(valve_name)
    valves[valve_name][:rate]
  end

  def best_flow(current_location: 'AA', minutes_remaining: P1_MINUTES, valves_open: Set.new.freeze, total_so_far: 0)
    return 0 if minutes_remaining <= 0

    opts = valve_options(valves_open)

    return total_so_far if opts.length.zero?

    opts.map do |name|
      minutes_busy = distance(current_location, name) + 1

      next total_so_far if minutes_busy > minutes_remaining

      best_flow(
        current_location: name,
        minutes_remaining: minutes_remaining - minutes_busy,
        valves_open: (valves_open + Set[name]).freeze,
        total_so_far: total_so_far + (flow_rate(name) * (minutes_remaining - minutes_busy))
      )
    end.max
  end

  def valve_options(valves_open)
    nonzero_flow.map(&:first).filter { |name| !valves_open.include?(name) }
  end

  def nonzero_flow
    valves.filter { |_k, v| (v[:rate]).positive? }.sort_by { |_k, v| v[:rate] }.reverse
  end

  def distance(start, end_)
    @distance ||= {}
    @distance[Set[start, end_].freeze] ||= bfs_distance(start, end_)
  end

  def bfs_distance(start, end_)
    return 0 if start == end_

    visited = Set[start]
    points = [start]

    l = 0

    loop do
      new_points = []

      points.each do |curr|
        return l if curr == end_

        valves[curr][:connections].each do |connection|
          next if visited.include?(connection)

          visited << connection
          new_points << connection
        end
      end

      points = new_points
      l += 1
    end
  end

  def solve2; end
end

Day16.new.execute
