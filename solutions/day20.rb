# frozen_string_literal: true

require_relative 'input'
require_relative 'solution'
require 'set'

class Day20 < Solution
  def solve
    (0...inp_sequence.length).each do |original_index|
      shuffle(original_index)
    end

    coordinates
  end

  def print
    puts indices.to_s
    puts(indices.map do |original_index|
      inp_sequence[original_index]
    end.join(', '))
  end

  def indices
    # list of indices into the original list, now in a new order.
    @indices ||= (0...inp_sequence.length).to_a
  end

  def inp_sequence
    @inp_sequence ||= INP.ints.freeze
  end

  def input_length
    inp_sequence.length
  end

  def shuffle(original_index)
    value = inp_sequence[original_index]
    current_index = indices.find_index(original_index) # TODO: O(n) -- augment with a Hash?

    move(current_index, value)
  end

  def move(index, amount)
    delete_ind = wrap_lookup(index)
    insert_ind = wrap_insert(index + amount)

    index_value = delete_at(delete_ind)
    insert(insert_ind, index_value)
  end

  def value_at(index)
    inp_sequence[indices[wrap_lookup(index)]]
  end

  def delete_at(index)
    indices.delete_at(wrap_lookup(index))
  end

  def insert(index, value)
    indices.insert(wrap_insert(index), value)
  end

  def wrap_lookup(index)
    index % input_length
  end

  def wrap_insert(index)
    ((index - 1) % (input_length - 1)) + 1
  end

  def coordinates
    zero_ind = indices.each_with_index.find do |inp_index, _current_index|
      inp_sequence[inp_index].zero?
    end.last

    value_at(zero_ind + 1000) + value_at(zero_ind + 2000) + value_at(zero_ind + 3000)
  end

  def solve2; end
end

Day20.new.execute
