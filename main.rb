require './LambdaCalculus'

TAPE = -> l { -> m { -> r { -> b { PAIR[PAIR[l][m]][PAIR[r][b]] } } } }
TAPE_LEFT = -> t { LEFT[LEFT[t]] }
TAPE_MIDDLE = -> t { RIGHT[LEFT[t]] }
TAPE_RIGHT = -> t { LEFT[RIGHT[t]] }
TAPE_BLANK = -> t { RIGHT[RIGHT[t]] }

TAPE_WRITE = -> t { -> c { TAPE[TAPE_LEFT[t]][c][TAPE_RIGHT[t]][TAPE_BLANK[t]] } }

TAPE_MOVE_HEAD_RIGHT =
    -> t {

      ]
    }



