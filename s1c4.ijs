load 'utils.ijs'
load 's1c3.ijs'

NB. load the file and box each row
F =. 1!:1 < '4.txt'

NB. guess the value of the single char xor cipher for given data
    FREQT =. ' etaoinsrhdlucmfywgpb,.vkxqjz'
    NB. scorewith 1 0 -- scores (x xor y) with a simple freq
    NB.                  table. low scores are good
    scorewith =. (+/"1) @: (FREQT i. (d2c @: (xor"1 0)))
    NB. get the lowest score for single-byte xor by brute-forcing all the chars
scoreforxor =. ([: <./ (i.255) scorewith~ [) f.

NB. split on LF; chomp the line endings; hex to dec
splt =. 255 & band @: h2d @: }."1 @: > @: ([ <;.1~ (10{a.) E. [)

NB. find the smallest number in the list
minidx =. i. <./

NB. get the line most likely to be a single-char xor
idx =. minidx scoreforxor"1 splt F
line =. idx { splt F
key =. guessxor line

NB. ---- TESTS ----
assert idx = 169
assert key = 53

assert (d2c line xor key) = 'Now that the party is jumping', LF
