# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'

class Day10 < Solution
  def solve
    init_prog
    run_prog(19)
    sum = signal_strength
    sum += signal_strength while run_prog(40)
    sum
  end

  def init_prog
    @cycle = 1
    @x = 1
    @ip = 0
    @add_cycles_elapsed = 0
  end

  def run_prog(n_inst)
    start_cycle = @cycle
    while @cycle - start_cycle < n_inst
      inst = prog[@ip]
      return false unless inst

      send(inst[0], *inst[1..])
      @cycle += 1
    end
    true
  end

  def noop
    @ip += 1
  end

  def addx(amt)
    if @add_cycles_elapsed == 1
      @x += amt
      @ip += 1
      @add_cycles_elapsed = 0
    else
      @add_cycles_elapsed = 1
    end
  end

  def signal_strength
    @cycle * @x
  end

  def prog
    @prog ||= INP.split_lines.map { |l| l.length == 2 ? [l[0], l[1].to_i] : l }
  end

  def solve2
    init_prog
    init_screen
    draw_pixel
    draw_pixel while run_prog(1)
    show_screen
  end

  SCREEN_W = 40
  SCREEN_H = 6

  def init_screen
    @screen = Array.new(SCREEN_H) { Array.new(SCREEN_W, ' ') }
  end

  def draw_pixel
    @screen[curr_pixel[:y]][curr_pixel[:x]] = '#' if curr_pixel_in_sprite?
  end

  def curr_pixel_in_sprite?
    (curr_pixel[:x] - @x).abs <= 1
  end

  def curr_pixel
    { x: (@cycle - 1) % SCREEN_W, y: ((@cycle - 1) / SCREEN_W) % SCREEN_H }
  end

  def show_screen
    @screen.map(&:join).join("\n")
  end
end

Day10.new.execute
