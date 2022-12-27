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
    total_so_far: 0,
    want_at_least: nil
  )
    return 0 if minutes_remaining <= 0

    opts = valve_options(valves_open)

    return total_so_far if opts.empty?

    if want_at_least
      bound = upper_bound(valves_open:, minutes_remaining:)
      if bound < want_at_least
        # warn("Pruning: want #{want_at_least}; upper bound #{bound}")
        return total_so_far
      end
    end

    best_so_far = 0

    opts.map do |name|
      minutes_busy = distance(current_location, name) + 1

      next total_so_far if minutes_busy > minutes_remaining

      result_for_option = best_flow(
        current_location: name,
        minutes_remaining: minutes_remaining - minutes_busy,
        valves_open: (valves_open + Set[name]).freeze,
        total_so_far: total_so_far + (flow_rate(name) * (minutes_remaining - minutes_busy)),
        want_at_least: best_so_far
      )

      best_so_far = result_for_option if result_for_option > best_so_far

      result_for_option
    end.max
  end

  def upper_bound(valves_open:, minutes_remaining:)
    options = valve_options(valves_open).to_enum
    bound = 0
    until minutes_remaining < 2
      begin
        time_on = minutes_remaining - 1
        total_flow = flow_rate(options.next) * time_on
        bound += total_flow

        minutes_remaining -= 2
      rescue StopIteration
        break
      end
    end

    bound
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
    my_best_flow_with_elephant
  end

  def my_best_flow_with_elephant(
    my_location: 'AA',
    my_minutes_remaining: P2_MINUTES,
    valves_open: Set.new.freeze,
    total_so_far: 0
  )
    return 0 if my_minutes_remaining <= 0

    opts = valve_options(valves_open)

    return total_so_far if opts.empty?

    result_if_i_keep_going = opts.map do |name|
      my_minutes_busy = distance(my_location, name) + 1
      next total_so_far unless my_minutes_busy < my_minutes_remaining

      my_best_flow_with_elephant(
        my_location: name,
        my_minutes_remaining: my_minutes_remaining - my_minutes_busy,
        valves_open: (valves_open + Set[name]).freeze,
        total_so_far: total_so_far + (flow_rate(name) * (my_minutes_remaining - my_minutes_busy))
      )
    end.max

    result_if_the_elephant_goes_now = best_flow(minutes_remaining: P2_MINUTES, valves_open:, total_so_far:)

    [result_if_i_keep_going, result_if_the_elephant_goes_now].max
  end
end

Day16.new.execute
