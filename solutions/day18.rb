# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day18 < Solution
  def solve
    shape.surface_area
  end

  def shape
    @shape ||= Shape.new(cubes)
  end

  def cubes
    @cubes ||= INP.lines.map { |l| l.split(',').map(&:to_i).freeze }.freeze
  end

  def solve2
    shape.external_surface_area
  end
end

class Shape
  def initialize(cubes)
    @cubes = cubes
    @cubes.each(&:freeze)
    @cubes.freeze
  end

  attr_reader :cubes

  def surface_area
    @surface_area ||= cubes.map do |cube|
      6 - covered_faces(cube)
    end.sum
  end

  def external_surface_area
    surface_area - internal_surface_area
  end

  def include?(cube)
    @cubes.include?(cube)
  end

  def cube_graph
    @cube_graph ||= cubes.to_h do |cube1|
      [cube1, neighbors(cube1)]
    end
  end

  def neighbors(cube1)
    cubes.filter do |cube2|
      shares_face(cube1, cube2)
    end
  end

  private

  def covered_faces(cube1)
    cubes.count do |cube2|
      shares_face(cube1, cube2)
    end
  end

  def shares_face(cube1, cube2)
    coord_differences = cube1.zip(cube2).map { |coord1, coord2| (coord1 - coord2).abs }
    coord_differences.count(1) == 1 && coord_differences.count(0) == 2 # Set[coord_differences] == Set[1, 0, 0]
  end

  def internal_surface_area
    air_pockets.map(&:surface_area).sum
  end

  def air_pockets
    @air_pockets ||= AirPocketFinder.new(self).air_pockets.map do |pocket|
      Shape.new(pocket)
    end
  end
end

class AirPocketFinder
  def initialize(shape)
    @shape = shape
  end

  attr_reader :shape

  def air_pockets
    @air_pockets ||= [].tap do |pockets|
      find_air_pockets do |pocket|
        pockets << pocket.freeze
      end
    end.freeze
  end

  private

  def visited
    @visited ||= Set.new
  end

  def visited?(cube)
    visited.include?(cube)
  end

  def mark_visited(cube)
    visited.add(cube)
  end

  def find_air_pockets
    each_cube do |cube|
      next if @shape.include?(cube)
      next if visited?(cube)

      mark_visited(cube)

      pocket = pocket_around(cube)
      yield pocket if pocket
    end
  end

  def pocket_around(start)
    pocket = [start]
    queue = [start]

    is_external = false

    until queue.empty?
      cube = queue.shift
      adjacent_unvisited_air(cube).each do |adj_cube|
        is_external ||= out_of_bounds?(adj_cube) # we still need to mark this space as visited

        next if out_of_bounds?(adj_cube)

        pocket << adj_cube
        queue << adj_cube
        mark_visited(adj_cube)
      end
    end

    is_external ? nil : pocket
  end

  def out_of_bounds?(cube)
    min, max = bounding_box

    cube.zip(min, max).any? { |coord, lbound, ubound| coord < lbound || coord > ubound }
  end

  def bounding_box
    @bounding_box ||=
      begin
        xs = shape.cubes.map(&:first)
        zs = shape.cubes.map(&:last)
        ys = shape.cubes.map { |c| c[1] }

        %i[min max].map do |meth|
          [xs, ys, zs].map { |a| a.send(meth) }.freeze
        end.freeze
      end
  end

  def adjacent_unvisited_air(cube)
    adjacent_cubes(cube).reject { |c| @shape.include?(c) || visited?(c) }
  end

  def adjacent_cubes(cube)
    x, y, z = cube
    [
      [x - 1, y, z],
      [x + 1, y, z],
      [x, y - 1, z],
      [x, y + 1, z],
      [x, y, z - 1],
      [x, y, z + 1],
    ].each(&:freeze).freeze
  end

  def each_cube
    min, max = bounding_box
    (min[0]..max[0]).each do |x|
      (min[1]..max[1]).each do |y|
        (min[2]..max[2]).each do |z|
          yield [x, y, z].freeze
        end
      end
    end
  end
end

Day18.new.execute
