# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day23 < Solution
  def solve
    init_elves
    10.times { elf_round }
    @map.empty_ground_in_bounding_box
  end

  def elf_start_positions
    @elf_start_positions ||= INP.lines.each_with_index.flat_map do |line, row|
      line.chars.each_with_index.filter_map do |char, col|
        [row, col].freeze if char == '#'
      end
    end.freeze
  end

  def init_elves
    @map = Map.new
    @elves = elf_start_positions.map { |row, col| Elf.new(row, col, @map) }.freeze
    @direction_manager = DirectionManager.new
  end

  def elf_round
    any_moved = false

    # { desired_pos => [elves] }
    desires = {}
    @elves.each do |elf|
      proposed = elf.proposed_move(@direction_manager)

      next if proposed.nil?

      desires[proposed] ||= []
      desires[proposed] << elf
    end

    desires.values.filter { |elves| elves.length == 1 }.each do |elves|
      elf = elves.first
      elf.move
      any_moved = true
    end

    @direction_manager = @direction_manager.rotate

    any_moved
  end

  def solve2
    init_elves
    round_count = 1
    round_count += 1 while elf_round
    round_count
  end
end

class Map
  def initialize
    # { pos => elf }
    @locations = {}
    @elf_count = 0
  end

  def move(elf, new_position)
    current_position = elf.position
    elf_removed = remove_elf(current_position)
    raise 'Removed the wrong elf!' if elf_removed != elf

    put_elf(elf, new_position)
  end

  def add_elf(elf, position)
    put_elf(elf, position)
    @elf_count += 1
  end

  def elf_at?(position)
    !get_elf(position).nil?
  end

  def empty_ground_in_bounding_box
    bounding_box_area - @elf_count
  end

  def visualize
    warn("#{visualization}\n\n")
  end

  def visualization
    rows, cols = bounding_box
    row_min, row_max = rows
    col_min, col_max = cols

    (row_min..row_max).map do |row|
      (col_min..col_max).map do |col|
        elf_at?([row, col]) ? '#' : '.'
      end.join
    end.join("\n")
  end

  private

  def get_elf(position)
    @locations[position]
  end

  def put_elf(elf, position)
    raise 'Already occupied!' if @locations[position]

    @locations[position] = elf
  end

  def remove_elf(position)
    @locations.delete(position)
  end

  def bounding_box_area
    bounding_box.map { |a, b| b - a + 1 }.inject(:*)
  end

  # [[row_min, row_max], [col_min, col_max]]
  def bounding_box
    [@locations.keys.map(&:first).minmax,
     @locations.keys.map(&:last).minmax]
  end
end

class Elf
  def initialize(row, col, map)
    @row = row
    @col = col
    @map = map

    @map.add_elf(self, position)
  end

  # TODO: If no other Elves are in one of those eight positions, the Elf does not do anything during this round
  def proposed_move(direction_manager)
    @proposed_move = nil

    return if surroundings_empty?

    direction_manager.directions do |direction|
      if clear?(direction)
        @proposed_move = step(direction)
        break
      end
    end
    @proposed_move
  end

  def move
    raise 'No proposed move!' unless @proposed_move

    @map.move(self, @proposed_move)
    @row, @col = @proposed_move
  end

  def position
    [@row, @col].freeze
  end

  private

  DELTAS = {
    north: [-1, 0].freeze,
    south: [1, 0].freeze,
    east: [0, 1].freeze,
    west: [0, -1].freeze,
  }.freeze

  def step(*directions)
    deltas = directions.map { |dir| DELTAS[dir] }
    [@row, @col].zip(*deltas).map(&:sum).freeze
  end

  SIDE_POSITIONS = { north: %i[east west].freeze, south: %i[east west].freeze,
                     east: %i[north south].freeze, west: %i[north south].freeze }.freeze

  def clear?(direction)
    squares = [step(direction)]
    SIDE_POSITIONS[direction].each { |side| squares << step(direction, side) }

    squares.none? { |square| @map.elf_at?(square) }
  end

  def surroundings_empty?
    DELTAS.keys.all? { |dir| clear?(dir) }
  end
end

class DirectionManager
  DIRECTIONS = %i[north south west east].freeze

  def initialize(ind = 0)
    @ind = ind
  end

  def rotate
    DirectionManager.new((@ind + 1) % DIRECTIONS.length)
  end

  def directions
    DIRECTIONS.length.times do |i|
      yield DIRECTIONS[(@ind + i) % DIRECTIONS.length]
    end
  end
end

Day23.new.execute
