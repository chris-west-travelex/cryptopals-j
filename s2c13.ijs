
NB. kv split (via boxing)
    NB. unbox and wrangle to string, then split on =
    spleq =. '=' & splitstring @: , @: >
    NB. split on & (then on =)
kv =: (_1 spleq\ '&' & splitstring) f.

NB. profile_for as per the challenge
profile_for =: ('email=' , '&uid=10&role=user' ,~ '=X&X' charsub [) f.


NB. ---- TESTS ----
s =. 'foo=bar&baz=qux&zap=zazzle'

assert ($ kv s) = 3 2
assert (1 0 {:: kv s) = 'baz'
assert (profile_for 'cw@cw.com') = 'email=cw@cw.com&uid=10&role=user'
assert (profile_for 'f@b.com&role=admin') = 'email=f@b.comXroleXadmin&uid=10&role=user'
