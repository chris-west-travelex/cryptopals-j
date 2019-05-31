NB. h2d (monad) converts hex string to decimal array
    HEX =. '0123456789abcdef'
    f =. +/ @: (* & 16 1)
h2d =: (_2 & (f\ HEX & i.)) f.
d2h =: , @: (HEX {~ (16 16 & #:))

NB. d2c convert decimal sequence to ASCII string
d2c =: { & a.
c2d =: a. & i.

bshift =: 33 b.  NB. <<
band =: 17 b.    NB. &
xor =: 22 b.     NB. ^


