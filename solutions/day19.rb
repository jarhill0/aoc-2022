# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day19 < Solution
  def solve
    blueprints.each_value.map do |bp|
      Blueprint.new(bp).quality_level
    end.sum
  end

  def blueprints
    @blueprints = INP.lines.to_h do |l|
      # rubocop:ignore Metrics/LineLength
      # Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 9 clay. Each geode robot costs 3 ore and 7 obsidian.
      words = l.split
      id = words[1].to_i
      ore_bot_cost = { ore: words[6].to_i, clay: 0, obsidian: 0 }.freeze
      clay_bot_cost = { ore: words[12].to_i, clay: 0, obsidian: 0 }.freeze
      obsidian_bot_cost = { ore: words[18].to_i, clay: words[21].to_i, obsidian: 0 }.freeze
      geode_bot_cost = { ore: words[27].to_i, obsidian: words[30].to_i, clay: 0 }.freeze
      obj = { id:, ore: ore_bot_cost, clay: clay_bot_cost,
              obsidian: obsidian_bot_cost, geode: geode_bot_cost }.freeze
      [id, obj]
    end.freeze
  end

  def solve2; end
end

class Blueprint
  def initialize(raw_bp)
    @id = raw_bp[:id]
    @costs = raw_bp.dup.tap do |bp|
      bp.delete(:id)
      bp.freeze
    end
  end

  attr_reader :id, :costs

  def quality_level
    # id * most_geodes_in(num_minutes: 24)
    id * greedy_most_geodes_in(num_minutes: 24)
  end

  private

  GREEDY_BOT_PREFERENCE = %i[geode obsidian clay ore].freeze
  SPENDABLE_TYPES = %i[ore clay obsidian].freeze
  def greedy_most_geodes_in(num_minutes: 24)
    resources = { ore: 0, clay: 0, obsidian: 0, geode: 0 }
    bots = { ore: 1, clay: 0, obsidian: 0, geode: 0 }

    (1..num_minutes).each do |min|
      warn("== Minute #{min} ==")

      new_bot = GREEDY_BOT_PREFERENCE.find do |bot_type|
        resources.reject { |r| r == :geode }.all? do |resource_name, amount_have|
          costs[bot_type][resource_name] <= amount_have
        end
      end

      if new_bot
        spent = {}
        SPENDABLE_TYPES.each do |resource_type|
          cost = costs[new_bot][resource_type]
          next unless cost.positive?

          resources[resource_type] -= cost
          spent[resource_type] = cost
        end
        warn(
          "Spend #{spent.map { |n, amt| "#{amt} #{n}" }.join(' and ')} to start building a #{new_bot}-collecting robot."
        )
      end

      bots.each do |type, count|
        resources[type] += count
        next unless count.positive?

        warn("#{count} #{type}-collecting robot collects #{count} #{type}; you now have #{resources[type]} #{type}.")
      end

      if new_bot
        bots[new_bot] += 1
        warn("The new #{new_bot}-collecting robot is ready; you now have #{bots[new_bot]} of them.")
      end

      warn('')
    end

    resources[:geode]
  end

  def most_geodes_in(num_minutes: 24, ore: 0, clay: 0, obsidian: 0, geode: 0,
                     ore_bots: 1, clay_bots: 0, obsidian_bots: 0, geode_bots: 0)
    return geode if num_minutes.zero?

    building_choices(ore, clay, obsidian).map do |choice|
      new_ore_bots = choice == :ore_bot ? 1 : 0
      new_clay_bots = choice == :clay_bot ? 1 : 0
      new_obsidian_bots = choice == :obsidian_bot ? 1 : 0
      new_geode_bots = choice == :geode_bot ? 1 : 0

      most_geodes_in(
        num_minutes: num_minutes - 1,
        ore: ore + ore_bots,
        clay: clay + clay_bots,
        obsidian: obsidian + obsidian_bots,
        geode: geode + geode_bots,
        ore_bots: ore_bots + new_ore_bots,
        clay_bots: clay_bots + new_clay_bots,
        obsidian_bots: obsidian_bots + new_obsidian_bots,
        geode_bots: geode_bots + new_geode_bots
      )
    end.max
  end

  def building_choices(ore, clay, obsidian)
    choices = []
    choices << :build_nothing unless ore >= max_ore && clay >= max_clay && obsidian >= max_obsidian

    @costs.each do |recipe_name, ingredients|
      if ore >= ingredients[:ore] && clay >= ingredients[:clay] && obsidian >= ingredients[:obsidian]
        choices << recipe_name
      end
    end
    choices
  end

  def max_ore
    @max_ore ||= @costs.values.map { |c| c[:ore] }.max
  end

  def max_clay
    @max_clay ||= @costs.values.map { |c| c[:clay] }.max
  end

  def max_obsidian
    @max_obsidian ||= @costs.values.map { |c| c[:obsidian] }.max
  end
end

Day19.new.execute
