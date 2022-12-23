# frozen_string_literal: true

class Input
  def initialize
    @content = $stdin.read
  end

  attr_reader :content

  def lines
    @lines ||= @content.split("\n")
  end

  def grouped_lines
    @grouped_lines ||= @content.split("\n\n").map { |l| l.split("\n") }
  end

  def split_lines
    @split_lines ||= @content.split("\n").map(&:split)
  end

  def ints
    @ints ||= lines.map(&:to_i)
  end
end

INP = Input.new
