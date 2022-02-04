class LCVariable < Struct.new(:name)
  def replace(name, replacement)
    if self.name == name
      replacement
    else
      self
    end
  end

  def callable?
    false
  end

  def reducible?
    false
  end

  def to_s
    name.to_s
  end

  def inspect
    to_s
  end
end

class LCFunction < Struct.new(:parameter, :body)
  def replace(name, replacement)
    if parameter == name
      self
    else
      LCFunction.new(parameter, body.replace(name, replacement))
    end
  end

  def callable?
    true
  end

  def reducible?
    false
  end

  def call(argument)
    body.replace(parameter, argument)
  end

  def to_s
    "-> #{parameter} { #{body} }"
  end

  def inspect
    to_s
  end
end

class LCCall < Struct.new(:left, :right)
  def replace(name, replacement)
    LCCall.new(left.replace(name, replacement), right.replace(name, replacement))
  end

  def callable?
    true
  end

  def reducible?
    left.reducible? || right.reducible? || left.callable?
  end

  def reduce
    if left.reducible?
      LCCall.new(left.reduce, right)
    elsif right.reducible?
      LCCall.new(left, right.reduce)
    else
      left.call(right)
    end
  end

  def to_s
    "#{left}[#{right}]"
  end

  def inspect
    to_s
  end
end

# p expression = LCCall.new(
#     LCCall.new(LCVariable.new(:x), LCVariable.new(:y)),
#     LCFunction.new(:y, LCCall.new(LCVariable.new(:y), LCVariable.new(:x))))
#
# p expression.replace(:y, LCVariable.new(:z))

# one = LCFunction.new(:p,
#                      LCFunction.new(:x,
#                                     LCCall.new(LCVariable.new(:p), LCVariable.new(:x))
#                      ) )
# increment =
#     LCFunction.new(:n, LCFunction.new(:p,
#                                       LCFunction.new(:x, LCCall.new(
#                                           LCVariable.new(:p), LCCall.new(
#                                           LCCall.new(LCVariable.new(:n), LCVariable.new(:p)),
#                                           LCVariable.new(:x) )
#                                       ) )
#     ) )
# add =
#     LCFunction.new(:m, LCFunction.new(:n,
#                                       LCCall.new(LCCall.new(LCVariable.new(:n), increment), LCVariable.new(:m)) )
#     )
#
# expression = LCCall.new(LCCall.new(add, one), one)
# while expression.reducible?
#   puts expression
#   expression = expression.reduce
# end
# puts expression
#
#
# p expression = LCCall.new(LCCall.new(add, one), one)
require 'treetop'

Treetop.load('lambda_calculus.treetop')
parse_tree = LambdaCalculusParser.new.parse('-> x { x[x] }[-> y { y }]')

# p parse_tree
p expression = parse_tree.to_ast
p expression.reduce