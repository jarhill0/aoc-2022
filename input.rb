class Input
  def initialize
    @content = STDIN.read
  end

  def lines
    @content.split
  end

  def grouped_lines
    @content.split("\n\n").map(&:split)
  end

  def ints
    lines.map(&:to_i)
  end
end

INP = Input.new
