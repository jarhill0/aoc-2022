# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'

class Day7 < Solution
  def initialize
    @root = {}
    @pwd = [@root]
  end

  def solve
    trace_history
    walk_directories.filter_map { |d| dir_size(d) <= 100_000 ? dir_size(d) : nil }.sum
  end

  def trace_history
    INP.lines.each do |line|
      if line.start_with?('$ cd ')
        cd(line.split.last)
      elsif line.start_with?('$ ls')
        next
      elsif line.start_with?('dir ')
        mkdir(line.split.last)
      else
        size, fname = line.split
        size = size.to_i
        create_file(fname, size)
      end
    end
  end

  def wd
    @pwd[-1]
  end

  def cd(dir_name)
    @pwd.pop and return if dir_name == '..'
    return if dir_name == '/'

    wd[dir_name] ||= {}
    @pwd.push(wd[dir_name])
  end

  def mkdir(dir_name)
    wd[dir_name] ||= {}
  end

  def create_file(name, size)
    wd[name] = size
  end

  def walk_directories
    Enumerator.new do |y|
      dwalker(y)
    end
  end

  def dwalker(y, d = @root)
    d.each_value do |val|
      if val.instance_of?(Hash)
        y << val
        dwalker(y, val)
      end
    end
  end

  def dir_size(dir)
    dir[:size] ||= dir.values.sum do |item|
      if item.instance_of?(Integer)
        item
      else
        dir_size(item)
      end
    end
  end

  MAX_FS_SIZE = 40_000_000

  def solve2
    need_to_free = dir_size(@root) - MAX_FS_SIZE
    walk_directories.filter_map { |d| dir_size(d) >= need_to_free ? dir_size(d) : nil }.min
  end
end

Day7.new.execute
