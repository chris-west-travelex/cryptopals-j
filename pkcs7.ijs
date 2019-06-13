NB. pad y to x bytes; yup
pkcs7pad =: 13 : 'x {.!.(x - # y) y'

NB. pad y to multiple of x bytes
    NB. round up length of y to multiples of x
    len =. 13 : 'x * >. x %~ # y'
pkcs7 =: (len pkcs7pad ]) f.

NB. ---- TESTS ----
assert (16 pkcs7 0 1 2 3) = 0 1 2 3 12 12 12 12 12 12 12 12 12 12 12 12
assert (8 pkcs7 0) = 0 7 7 7 7 7 7 7
assert ({: 16 pkcs7 (i.24)) = 8
