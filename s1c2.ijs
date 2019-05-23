load 's1c1.ijs'

NB. XOR a matched stream of bytes
xor =: 22 b.


NB. ---- TESTS ----
a =: h2d '1c0111001f010100061a024b53535009181c'
b =: h2d '686974207468652062756c6c277320657965'

assert (a xor b) = (h2d '746865206b696420646f6e277420706c6179')
