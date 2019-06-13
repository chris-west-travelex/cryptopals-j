load 'utils.ijs'
load 'aes.ijs'

NB. encryption_oracle as described in challenge
    NB. random 16 byte key; using '3 :' to force it to be a verb, not a noun
    rkey =. 3 : '? 16 $ 256'
    NB. generate 5-10 random bytes
    pad =. 3 : '(5 + ? 6) ?@$ 256'
    NB. ECB with a random key
    ecb =. aes128ecb rkey
    NB. CBC with a random key and iv
    cbc =. aes128cbc (rkey; rkey)
    NB. choose ecb or cbc
    choose =. ecb`cbc @. (3 : '?2')
    NB. randomly pad the pt, before and after
    padpt =. pad, [, pad
encryption_oracle =: (choose @: padpt) f.


NB. ecb detector (adverb)
NB.  ... puts 8 blocks of data into u, then
NB.      counts unique in first six encrypted.
NB.      if there are only two unique, it's ECB
is_ecb =: 1 : '1 = >./ i.~ 6 16 $ u (128 # 65)'


NB. ---- TESTS ----
assert($ rkey 0) = 16
assert(encryption_oracle is_ecb) <: 1  NB. these aren't very convincing tests
assert(encryption_oracle is_ecb) >: 0
