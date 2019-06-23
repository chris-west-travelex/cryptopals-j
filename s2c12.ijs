load 'utils.ijs'
load 'aes.ijs'
load 'base64.ijs'
load 's2c11.ijs'

NB. encryption_oracle as described in challenge
    NB. ECB with fixed, random key
    ecbrkey =. aes128ecb & (? 16 $ 256)
    NB. "do not decode this string now. don't do it"
    s =. b64d 'Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK'
ecb_oracle =: ([: ecbrkey s,~ [) f.

NB. calculate blocksize
     NB. feed 32, 33, ... 96 bytes into u; count the output bytes
     NB. o =. 1 : '([: # u) \ (32 + i.64)'
     NB. then subtract each from the next and pick the biggest result
     NB. 1 : '>./ 2 ({: - {.)\ u o'
blocksize =: 1 : '>./ 2 ({: - {.)\ ([: # u) \ (32 + i.64)'

NB. algorithm to unpack one block
NB. TODO CONVERT TO GERUND
    NB. calculate padding length from bytes so far
    pl =. 15 - [: $ ]

    NB. pad x to blocksize-1 bytes
    p =. 13 : '(0 #~ pl x) , x'

    NB. turn a ($ n) array into ($ n 256), then suffix with values 0..255
    NB. ... thus making a dictionary of blocks
    d =. (i.256) ,~"0 1 [

    NB. consult the oracle with x nulls
    t =. [: ecb_oracle 0 #~ [

    NB. return index of t in ecb_oracle(d), concatenated with bytes so far ...
    NB. given x = bytes so far
    c =. 13 : 'x , I. (16 & =) +/ |: (16 {. t pl x) ="1 1 (16 & {.)"1 ecb_oracle"1 (d p x)'

    NB. call c with its own output 16 times, starting with an empty array
firstblock =: c^:16 i.0

NB. hackery for second block
pl =. 31 - [: $ ]
c =. 13 : 'x , I. (32 & =) +/ |: (32 {. t pl x) ="1 1 (32 & {.)"1 ecb_oracle"1 (d p x)'
secondblock =: c^:16 firstblock


NB. ---- TESTS ----
assert (ecb_oracle 1) = (ecb_oracle 1)
assert (ecb_oracle is_ecb) = 1
assert (ecb_oracle blocksize) = 16
assert (firstblock) = 'Rollin'' in my 5.'
