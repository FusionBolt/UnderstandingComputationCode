(1..100).map do |n|
  if (n % 15).zero?
    'FizzBuzz'
  elsif (n % 3).zero?
    'Fizz'
  elsif (n % 5).zero?
    'Buzz'
  else
    n.to_s
  end
end

ZERO = -> p { -> x { x } }
ONE = -> p { -> x { p[x] } }
TWO = -> p { -> x { p[p[x]] } }
THREE = -> p { -> x { p[p[p[x]]] } }
FIVE = -> p { -> x { p[p[p[p[p[x]]]]] } }

TRUE = -> x { -> y { x } }
FALSE = -> x { -> y { y } }

# IF =
#     -> b {
#       -> x {
#         -> y {
#           b[x][y]
#         }
#       }
#     }

# TODO:???
IF = -> b { b }

IS_ZERO = -> n { n[-> x { FALSE }][TRUE] }

PAIR = -> x { -> y { -> f { f[x][y] } } }
LEFT = -> p { p[-> x { -> y {x} } ] }
RIGHT = -> p { p[-> x { -> y {y} } ] }

INCREMENT = -> n { -> p { -> x { p[n[p][x]] } } }
SLIDE = -> p { PAIR[RIGHT[p]][INCREMENT[RIGHT[p]]] }
DECREMENT = -> n { LEFT[n[SLIDE][PAIR[ZERO][ZERO]]] }

ADD = -> m { -> n { n[INCREMENT][m] } }
SUBTRACT = -> m { -> n { n[DECREMENT][m] } }
MULTIPLY = -> m { -> n { n[ADD[m]][ZERO] } }
POWER = -> m { -> n { n[MULTIPLY[m]][ONE]} }
IS_LESS_OR_EQUAL = -> m { -> n { IS_ZERO[SUBTRACT[m][n]] } }

Z = -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[-> y { x[x][y] }] }] }

MOD =
    Z[-> f { -> m { -> n {
      IF[IS_LESS_OR_EQUAL[n][m]][
          -> x {
            f[SUBTRACT[m][n]][n][x]
          }
      ][
          m
      ]
    }}}]

EMPTY = PAIR[TRUE][TRUE]
UNSHIFT = -> l { -> x {
  PAIR[FALSE][PAIR[x][l]]
}}

IS_EMPTY = LEFT
FIRST = -> l { LEFT[RIGHT[l]] }
REST = -> l { RIGHT[RIGHT[l]] }

RANGE =
    Z[-> f {
      ->m { -> n {
        IF[IS_LESS_OR_EQUAL[m][n]][
            -> x {
              UNSHIFT[f[INCREMENT[m]][n]][m][x]
            }
        ][
            EMPTY
        ]
      }}
    }]

FOLD =
    Z[-> f {
      -> l { -> x { -> g {
        IF[IS_EMPTY[l]][
            x
        ][
            -> y {
              g[f[REST[l]][x][g]][FIRST[l]][y]
            }
        ]
      }}}
    }]

MAP =
    -> k { -> f {
      FOLD[k][EMPTY][
          -> l { -> x { UNSHIFT[l][f[x]] } }
      ]
    }}

def to_integer(proc)
  proc[-> n { n + 1 }][0]
end

def to_boolean(proc)
  IF[proc][true][false]
end

def if(proc, x, y)
  proc[x][y]
end

def zero?(proc)
  proc[-> x { FALSE }][TRUE]
end

def slide(pair)
  [pair.last, pair.last + 1]
end

def to_array(l, count = nil)
  array = []

  until to_boolean(IS_EMPTY[l]) || count == 0
    array.push(FIRST[l])
    l = REST[l]
    count = count - 1 unless count.nil?
  end

  array
end


p IF[TRUE]['happy']['sad']
pair = PAIR[THREE][FIVE]
p pair
p to_integer(LEFT[pair])
p to_integer(RIGHT[pair])
p to_boolean(IS_LESS_OR_EQUAL[TWO][TWO])
p to_boolean(IS_LESS_OR_EQUAL[THREE][TWO])
p to_integer(MOD[THREE][TWO])

my_list = UNSHIFT[
    UNSHIFT[
        UNSHIFT[EMPTY][THREE]
    ][TWO] ][ONE]
p "array"
p to_array(my_list).map { |p| to_integer(p) }

p IS_EMPTY[my_list]
p to_integer(FIRST[my_list])

p my_range = RANGE[ONE][FIVE]
p to_array(my_range).map { |p| to_integer(p) }

p to_integer(FOLD[my_range][ONE][MULTIPLY])

p my_list = MAP[RANGE[ONE][FIVE]][INCREMENT]
p to_array(my_list).map { |p| to_integer(p) }


TEN = MULTIPLY[TWO][FIVE]
B = TEN
F = INCREMENT[B]
I = INCREMENT[F]
U = INCREMENT[I]
ZED = INCREMENT[U]

FIZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][I]][F]
BUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][U]][B]
FIZZBUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[BUZZ][ZED]][ZED]][I]][F]

HUNDRED = MULTIPLY[TEN][TEN]
FIFTEEN = MULTIPLY[FIVE][THREE]

def to_char(c)
  '0123456789BFiuz'.slice(to_integer(c))
end

def to_string(s)
  to_array(s).map { |c| to_char(c) }.join
end


DIV =
    Z[-> f { -> m { -> n {
      IF[IS_LESS_OR_EQUAL[n][m]][ -> x {
        INCREMENT[f[SUBTRACT[m][n]][n]][x] }
      ][ ZERO
      ]
    } } }]
PUSH = -> l {
  -> x { FOLD[l][UNSHIFT[EMPTY][x]][UNSHIFT]
  } }

TO_DIGITS =
    Z[-> f { -> n { PUSH[
        IF[IS_LESS_OR_EQUAL[n][DECREMENT[TEN]]][ EMPTY
        ][
            -> x {
              f[DIV[n][TEN]][x] }
        ]
    ][MOD[n][TEN]] } }]

FIFTY = MULTIPLY[FIVE][TEN]

solution =
    MAP[RANGE[ONE][FIFTY]][-> n {
      IF[IS_ZERO[MOD[n][FIFTEEN]]][
          FIZZBUZZ
      ][IF[IS_ZERO[MOD[n][THREE]]][
            FIZZ
        ][IF[IS_ZERO[MOD[n][FIVE]]][
              BUZZ
          ][
              TO_DIGITS[n]
          ]]]
    }]

# p 'solution'
# p solution
# to_array(solution).each do |p|
#   puts to_string(p)
# end

ZEROS = Z[-> f {UNSHIFT[f][ZERO] }]

p to_array(ZEROS, 5).map { |p| to_integer(p) }

