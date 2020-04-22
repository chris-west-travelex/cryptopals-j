NB. pad y to x bytes; yup
pkcs7pad =: 13 : 'x {.!.(x - # y) y'

NB. pad y to multiple of x bytes
    NB. round up length of y to multiples of x
    len =. 13 : 'x * >. x %~ # y'
pkcs7 =: (len pkcs7pad ]) f.

NB. check pkcs7 padding
    NB. calculate what padding should be from last byte
    pad =. #~ @: {:
    NB. fetch last n bytes to compare
    last =. {.~ _1 * {:
    NB. compare each byte
    cmp =. pad = last
pkcs7_valid =: [: */cmp f.

NB. strip pkcs7
    strip =. [ }.~ [: - [: {: [
    NB. if it's valid, strip the bytes
pkcs7d =: strip ^: pkcs7_valid f.

NB. ---- TESTS ----
assert (16 pkcs7 0 1 2 3) = 0 1 2 3 12 12 12 12 12 12 12 12 12 12 12 12
assert (8 pkcs7 0) = 0 7 7 7 7 7 7 7
assert ({: 16 pkcs7 (i.24)) = 8

assert (pkcs7_valid 0 1 2 3 4 5 2 2) = 1
assert (pkcs7_valid 73 67 69 32 73 67 69 32 66 65 66 89 5 5 5 5) = 0
assert (pkcs7_valid 73 67 69 32 73 67 69 32 66 65 66 89 1 2 3 4) = 0

assert (pkcs7d (16 pkcs7 0 1 2 3)) = 0 1 2 3
assert (pkcs7d (8 pkcs7 0)) = 0

assert (pkcs7d (8 pkcs7 41 42 43 44 45 46 47 48)) = 41 42 43 44 45 46 47 48
