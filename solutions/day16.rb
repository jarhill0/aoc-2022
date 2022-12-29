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

  def best_flow(
    current_location: 'AA',
    minutes_remaining: P1_MINUTES,
    valves_open: Set.new.freeze,
    total_so_far: 0
  )
    raise 'Too little time!' if minutes_remaining <= 0

    opts = valve_options(valves_open)

    return total_so_far if opts.empty?

    opts.map do |name|
      minutes_busy = distance(current_location, name) + 1

      next total_so_far if minutes_busy >= minutes_remaining

      best_flow(
        current_location: name,
        minutes_remaining: minutes_remaining - minutes_busy,
        valves_open: (valves_open + Set[name]).freeze,
        total_so_far: total_so_far + (flow_rate(name) * (minutes_remaining - minutes_busy)),
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
    @distance["#{start}|#{end_}"] ||= bfs_distance(start, end_)
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

  P2_MINUTES = 26

  def solve2
    valve_options = {}
    flow_from_valves(valve_map: valve_options)
    best_combination(valve_options)
  end

  def best_combination(valve_options)
    valve_options.filter_map do |my_valves, my_total|
      valve_options.filter_map do |elephant_valves, elephant_total|
        next unless my_valves.disjoint?(elephant_valves)

        my_total + elephant_total
      end.max
    end.max
  end

  def flow_from_valves(
    valve_map:,
    current_location: 'AA',
    minutes_remaining: P2_MINUTES,
    valves_open: Set.new.freeze,
    total_so_far: 0
  )
    raise 'Too little time!' if minutes_remaining <= 0

    valve_map[valves_open] = total_so_far if !valve_map[valves_open] || valve_map[valves_open] < total_so_far

    opts = valve_options(valves_open)

    return if opts.empty?

    opts.each do |name|
      minutes_busy = distance(current_location, name) + 1

      next if minutes_busy >= minutes_remaining

      flow_from_valves(
        current_location: name,
        minutes_remaining: minutes_remaining - minutes_busy,
        valves_open: (valves_open + Set[name]).freeze,
        total_so_far: total_so_far + (flow_rate(name) * (minutes_remaining - minutes_busy)),
        valve_map:,
      )
    end
  end
end

Day16.new.execute
