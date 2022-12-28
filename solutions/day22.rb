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

  def solve2
    find_face_bounds
  end

  def walk2
    update_visualization
    path.each do |instruction|
      turn(instruction) and next if instruction.is_a?(Symbol)

      instruction.times do
        next_pos, next_dir = one_cube_step_forward
        break if wall?(next_pos)

        @row, @col = next_pos
        @dir = next_dir
        update_visualization
      end
    end
  end

  def one_cube_step_forward
    delta = DELTAS[@dir]
    new_row, new_col = [@row, @col].zip(delta).map(&:sum)
    new_dir = @dir

    [[new_row, new_col], new_dir]
  end

  def face_bounds
    @face_bounds ||= find_face_bounds
  end

  private

  # I could hard-code this for my input, but I like the challenge of solving the general case
  # Also, that helps me test on the sample input.
  def find_face_bounds
    # chunk vertically
    row_0_bounds = map.first[0]

    vertical_chunks = []
    first_row_this_chunk = 0
    curr_l = row_0_bounds[1] - row_0_bounds[0] + 1
    map.each_with_index do |row, row_ind|
      bounds = row[0]
      l = bounds[1] - bounds[0] + 1

      next unless l != curr_l

      vertical_chunks << [first_row_this_chunk, row_ind - 1]
      curr_l = l
      first_row_this_chunk = row_ind
    end

    vertical_chunks << [first_row_this_chunk, map.length - 1]

    # find face width from vertical chunks
    face_width = vertical_chunks.map(&:first).map do |row_ind|
      bounds = map[row_ind][0]
      bounds[1] - bounds[0] + 1
    end.min

    # now use that to divide the larger chunks
    faces = vertical_chunks.flat_map do |start_row_ind, end_row_ind|
      bounds = map[start_row_ind][0]
      width = bounds[1] - bounds[0] + 1
      num_faces = width / face_width

      num_faces.times.map do |i|
        start_col_ind = bounds[0] + (i * face_width)
        end_col_ind = bounds[0] + ((i + 1) * face_width) - 1
        [[start_row_ind, start_col_ind].freeze, [end_row_ind, end_col_ind].freeze].freeze
      end
    end.freeze

    warn(faces.inspect)

    # TODO: now figure out how they connect
    # connect immediate neighbors by comparing coordinates

    # fill in the rest by aggregating transitions over the existing connections until all faces have all connections
    # (that is, repeatedly translate A->B->C into A->C, until the connections are filled)

    # me[up] = me[up][right] + 1 turn to the right
  end

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
