require_relative 'input'

class Day2
  def solve
    INP.lines.map(&:split).map { |l| score(l) }.sum
  end

  def score(l)
    opp, me = l

    mp = case me
         when 'X'
           1
         when 'Y'
           2
         when 'Z'
           3
         end

    wp = case outcome(opp, me)
         when :win
           6
         when :draw
           3
         when :lose
           0
         end

    mp + wp
  end

  def outcome(opp, me)
    opp = { 'A' => 'R', 'B' => 'P', 'C' => 'S' }[opp]
    me = { 'X' => 'R', 'Y' => 'P', 'Z' => 'S' }[me]
    if opp == me
      :draw
    elsif (opp == 'R' && me == 'S') || (opp == 'S' && me == 'P') || (opp == 'P' && me == 'R')
      :lose
    else
      :win
    end
  end

  def score2(l)
    opp, out = l
    out = { 'X' => :lose, 'Y' => :draw, 'Z' => :win }[out]
    me = desired(opp, out)

    mp = case me
         when 'R'
           1
         when 'P'
           2
         when 'S'
           3
         end

    wp = case out
         when :win
           6
         when :draw
           3
         when :lose
           0
         end

    mp + wp
  end

  def desired(opp, out)
    case opp
    when 'A' # rock
      case out
      when :win
        'P'
      when :draw
        'R'
      when :lose
        'S'
      end

    when 'B' # paper
      case out
      when :win
        'S'
      when :draw
        'P'
      when :lose
        'R'
      end

    when 'C' # scissors
      case out
      when :win
        'R'
      when :draw
        'S'
      when :lose
        'P'
      end
    end
  end

  def solve2
    INP.lines.map(&:split).map { |l| score2(l) }.sum
  end
end

d = Day2.new
p d.solve
ans2 = d.solve2
p ans2 if ans2
