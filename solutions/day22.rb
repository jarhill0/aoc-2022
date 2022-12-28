# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day22 < Solution
  def solve
    init_position
    walk
    # print_visualization
    password
  end

  DELTAS = {
    right: [0, 1].freeze,
    left: [0, -1].freeze,
    up: [-1, 0].freeze,
    down: [1, 0].freeze
  }.freeze
  DIRECTIONS = %i[right down left up].freeze

  def init_position
    @row = 0
    @col = map.first.first.first
    @dir = :right
  end

  def map
    @map ||= INP.grouped_lines.first.map do |line|
      walls = Set.new(line.chars.each_with_index.filter { |c, _i| c == '#' }.map(&:last)).freeze
      anything = line.chars.each_with_index.filter { |c, _i| c != ' ' }.map(&:last) # rubocop:disable Style/HashExcept
      [anything.minmax, walls].freeze
    end.freeze
  end

  def path
    @path ||= INP.grouped_lines.last.first.split('L').map do |segment|
      segment.split('R').map(&:to_i).inject([]) do |arr, x|
        arr << :R unless arr.empty?
        arr << x
      end
    end.inject([]) do |arr, x|
      arr << :L unless arr.empty?
      arr << x
    end.flatten.freeze
  end

  def walk
    update_visualization
    path.each do |instruction|
      turn(instruction) and next if instruction.is_a?(Symbol)

      instruction.times do
        next_pos = one_step_forward
        break if wall?(next_pos)

        @row, @col = next_pos
        update_visualization
      end
    end
  end

  def turn(dir)
    change = dir == :R ? 1 : -1
    @dir = DIRECTIONS[(DIRECTIONS.index(@dir) + change) % DIRECTIONS.length]
    update_visualization
  end

  def wall?(position)
    row, col = position
    map[row].last.include?(col)
  end

  def one_step_forward
    delta = DELTAS[@dir]
    new_row, new_col = [@row, @col].zip(delta).map(&:sum)

    new_row = 0 if new_row >= map.length
    new_row = map.length - 1 if new_row.negative?
    row_bounds = map[new_row].first

    if @dir == :right || @dir == :left
      if new_col < row_bounds[0]
        new_col = row_bounds[1]
      elsif new_col > row_bounds[1]
        new_col = row_bounds[0]
      end
    elsif new_col < row_bounds[0] || new_col > row_bounds[1]
      rows_to_examine = map.each_with_index
      rows_to_examine = rows_to_examine.reverse_each if @dir == :up
      new_row = rows_to_examine.find do |row, _row_ind|
        bounds = row.first
        new_col >= bounds[0] && new_col <= bounds[1]
      end.last
    end

    [new_row, new_col]
  end

  def password
    (1000 * (@row + 1)) + (4 * (@col + 1)) + DIRECTIONS.index(@dir)
  end

  def solve2; end

  private

  def last_facing
    @last_facing ||= {}
  end

  VIZ_DIRECTIONS = { right: '>', left: '<', up: '^', down: 'v' }.freeze
  def update_visualization
    last_facing[[@row, @col]] = VIZ_DIRECTIONS[@dir]
  end

  def print_visualization
    warn(visualization)
  end

  def visualization
    row_ind = -1
    map.map do |bounds, walls|
      row_ind += 1
      min, max = bounds
      "#{' ' * min}#{(min..max).map do |col_ind|
        facing = last_facing[[row_ind, col_ind]]
        if facing
          facing
        elsif walls.include?(col_ind)
          '#'
        else
          '.'
        end
      end.join}"
    end.join("\n")
  end
end

Day22.new.execute
