require_relative 'input'

class Day1
  def solve
    INP.grouped_lines.map {|g| g.map(&:to_i).sum}.max
  end

  def solve2
    INP.grouped_lines.map {|g| g.map(&:to_i).sum}.sort.reverse.first(3).sum
  end
end

d = Day1.new
p d.solve
ans2 = d.solve2
p ans2 if ans2
