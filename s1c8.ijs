load 'utils.ijs'
load 'aes.ijs'


NB. split on LF; chomp the line endings; hex to dec; drop last row
NB. this is different from the other definition :P
splt =. [: }: 255 & band @: h2d @: }."1 @: > @: ([ <;.1~ (10{a.) E. [)

    NB. juggle row into 10 x 16 bytes; count unique 16 byte phrases
    uniq =. [: # @: ~. 10 16 $ {

    NB. index of the smallest number
    minidx =. i. <./

    NB. find the row with the fewest unique phrases
    urow =. 13 : 'minidx (i. # x) uniq"0 2 x'
ecbrow =: (urow @: splt) f.


NB. ---- TESTS ----
F =. 1!:1 < '8.txt'

assert(ecbrow F) = 131
