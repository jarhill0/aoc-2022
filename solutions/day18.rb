# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day18 < Solution
  def solve
    cubes.map do |cube1|
      6 - covered_faces(cube1)
    end.sum
  end

  def cubes
    @cubes ||= INP.lines.map { |l| l.split(',').map(&:to_i).freeze }.freeze
  end

  def covered_faces(cube1)
    cubes.count do |cube2|
      shares_face(cube1, cube2)
    end
  end

  def shares_face(cube1, cube2)
    coord_differences = cube1.zip(cube2).map { |coord1, coord2| (coord1 - coord2).abs }
    coord_differences.count(1) == 1 && coord_differences.count(0) == 2 # Set[coord_differences] == Set[1, 0, 0]
  end

  def solve2; end
end

Day18.new.execute
