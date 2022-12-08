# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day8 < Solution
  def solve
    @seen = Set.new

    trees.each_with_index do |row, r|
      m = -1
      row.each_with_index do |tree, c|
        if tree > m
          @seen.add([r, c])
          m = tree
        end
      end

      m = -1
      row.reverse.each_with_index do |tree, c_inv|
        c = row.length - c_inv - 1
        if tree > m
          @seen.add([r, c])
          m = tree
        end
      end
    end

    (0..trees.first.length - 1).each do |c|
      m = -1
      trees.each_with_index do |row, r|
        tree = row[c]
        if tree > m
          @seen.add([r, c])
          m = tree
        end
      end

      m = -1
      trees.reverse.each_with_index do |row, r_inv|
        r = trees.length - r_inv - 1
        tree = row[c]
        if tree > m
          @seen.add([r, c])
          m = tree
        end
      end
    end

    @seen.length
  end

  def trees
    @trees ||= INP.lines.map { |l| l.chars.map(&:to_i) }
  end

  def scenic_score(tree, r, c)
    return 0 if r == 0 || c == 0 || r == trees.length - 1 || c == trees.first.length - 1

    u_dist = d_dist = l_dist = r_dist = 1

    begin
      ru = r - 1
      while ru >= 0 and trees[ru][c] < tree
        ru -= 1
        u_dist += 1 if ru >= 0
      end
    end

    begin
      row_down = r + 1
      while row_down < trees.length and trees[row_down][c] < tree
        row_down += 1
        d_dist += 1 if row_down < trees.length
      end
    end

    begin
      cl = c - 1
      while cl >= 0 and trees[r][cl] < tree
        cl -= 1
        l_dist += 1 if cl >= 0
      end
    end

    begin
      cr = c + 1
      while cr < trees.first.length and trees[r][cr] < tree
        cr += 1
        r_dist += 1 if cr < trees.first.length
      end
    end

    ans = u_dist * d_dist * l_dist * r_dist
    if ans == 299880
      STDERR.puts "299880 at (#{r}, #{c})"
    end
    if r == 3 && c == 2
      STDERR.puts "udlr, #{u_dist} #{d_dist}, #{l_dist}, #{r_dist}"
    end
    ans
  end

  def solve2
    trees.each_with_index.map do |row, r|
      row.each_with_index.map do |tree, c|
        scenic_score(tree, r, c)
      end
    end.flatten.max
  end
end

Day8.new.execute
