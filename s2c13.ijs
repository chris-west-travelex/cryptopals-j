load 'utils.ijs'
load 'aes.ijs'

NB. kv split (via boxing)
    NB. unbox and wrangle to string, then split on =
    spleq =. '=' & splitstring @: , @: >
    NB. split on & (then on =)
kv =: (_1 spleq\ '&' & splitstring) f.

NB. profile_for as per the challenge
profile_for =: ('email=' , '&uid=10&role=user' ,~ '=X&X' charsub [) f.

NB. random key
KEY =: (? 16 $ 256)

NB. encrypt a profile
    NB. ECB with fixed, random key
    ecbrkey =. aes128ecb & KEY
enc_profile =: (ecbrkey @: c2d @: profile_for) f.

NB. decrypt a profile (and parse it)
dec_profile =: ([: kv [: d2c KEY aes128ecbd~ [) f.

NB. strategy is:
NB.  1. first use e-mail field to get encrypted pkcs7-padded block for "admin<pad>"
NB.  2. then get cyphertext with e-mail field that lands "user" at beginning of a block
NB.  3. then replace the last block of 2. with the block from 1.

NB.    0123456789abcdef0123456789abcdef0123456789abcdef
NB.    |               |               |
NB. 1. email=6789abcdefadminbbbbbbbbbbb@cw.com&etc=etc
NB. 2. email=6789cw@cw.com&uid=10&role=user

one_a =. enc_profile d2c (c2d '6789abcdefadmin'), (11 $ 11), (c2d '@cw.com')
one_b =. 16 }. 32 {. one_a

two =. enc_profile '6789cw@cw.com'

three =. (_16 }. two) , one_b


NB. ---- TESTS ----
s =. 'foo=bar&baz=qux&zap=zazzle'

assert ($ kv s) = 3 2
assert (1 0 {:: kv s) = 'baz'
assert (profile_for 'cw@cw.com') = 'email=cw@cw.com&uid=10&role=user'
assert (profile_for 'f@b.com&role=admin') = 'email=f@b.comXroleXadmin&uid=10&role=user'
assert (kv profile_for 'cw@cw.com') = (dec_profile enc_profile 'cw@cw.com')

assert (2 1 {:: dec_profile three) = 'admin'
