# frozen_string_literal: true

class Solution
  def solve; end

  def solve2; end

  def execute
    print_if_present(solve)
    print_if_present(solve2)
  end

  private

  def print_if_present(x)
    p x if x
  end
end
