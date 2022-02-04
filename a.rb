# TODO: NFA to DFA   思路
#
# TODO: free_moves(super)    what is the super
# TODO: 实现语法解析
# TODO: DFA PDA TM 差别  TM的能力

module A
  def add(x, y)
    x + y
  end
end

class AD
  include A
end

o = Object.new

def o.to_s
  'a new object'
end

def o.inspect
  '[my object]'
end

def join_with_args(before, *words, after)
  words.join ','  # words1,words2, ...
end

p join_with_args 'before', 'word1', 'word2', 'after'


class Point < Struct.new(:x, :y)
  def +(other_point)
    Point.new(x + other_point.x, y + other_point.y)
  end

  def inspect
    "<Point> (#{x}, #{y})"
  end
end

v = AD.new
p v.add 1, 2
