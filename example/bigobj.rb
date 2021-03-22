require_relative '../obj_diff'

class Checkout
  def initialize(line_items)
    @line_items = line_items
  end
end

c1 = Checkout.new([[:apple, 1]])
c2 = Checkout.new([[:apple, 2]])

e1 = { checkout: c1 }
e2 = { checkout: c2 }

puts ObjDiff[e1, e2]