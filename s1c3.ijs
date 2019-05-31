load 'utils.ijs'

NB. guess the value of the single char xor cipher for given data
    FREQT =. ' etaoinsrhdlucmfywgpb,.vkxqjz'
    NB. scorewith 1 0 -- scores (x xor y) with a simple freq
    NB.                  table. low scores are good
    scorewith =. (+/"1) @: (FREQT i. (d2c @: (xor " 1 0)))
    NB. find the index of the lowest score
    minidx =. i. <. /
guessxor =: (minidx @: scorewith & (i.255)) f.


NB. ---- TESTS ----
c =: h2d '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'

assert (d2c guessxor c) = 'X'
assert (d2c c xor guessxor c) = 'Cooking MC''s like a pound of bacon'
