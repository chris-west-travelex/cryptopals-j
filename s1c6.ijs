load 'utils.ijs'
load 'base64.ijs'
load 's1c3.ijs'  NB. for guessxor
load 's1c5.ijs'  NB. for rkxor

NB. calculate hamming edit distance between x and y (by xor'ing then counting bits)
hamming =: (13 : '+/ , #: x 22 b. y') f.

NB. guess key length
    NB. find smallest of
    minidx =. i. <./
    NB. find average
    avg =. +/ % #
    NB. get average hamming distance between 5 sets of x chars in y
    NB. f =. 13 : 'x %~ (x {. y) hamming ((x + i.x) { y)'
    f =. 13 : 'x %~ avg _2 hamming/\ (32, x) $ y'
guesskeylen =: (2 + [: minidx (2 + i.30) f"0 1 [) f.

guesskey =: (13 : 'guessxor"1 |: (_1 * guesskeylen x) [\ x') f.


NB. ---- TESTS ----
F =. 1!:1 < '6.txt'
assert((c2d 'this is a test') hamming (c2d 'wokka wokka!!!')) = 37
assert(guesskeylen b64d F) = 29

key =. guesskey b64d F
assert(d2c key) = 'Terminator X: Bring the noise'

text =. d2c key rkxor~ b64d F
assert (+/ 'Sparkamatic' E. text) = 1
