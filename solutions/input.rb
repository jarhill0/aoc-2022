class Input
  def initialize
    @content = STDIN.read
  end

  def content
    @content
  end

  def lines
    @lines ||= @content.split("\n")
  end

  def grouped_lines
    @grouped_lines ||= @content.split("\n\n").map { |l| l.split("\n") }
  end

  def ints
    @ints ||= lines.map(&:to_i)
  end
end

INP = Input.new
