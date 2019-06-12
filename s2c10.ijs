load 'utils.ijs'
load 'aes.ijs'

F =. 1!:1 < '10.txt'
k =. c2d 'YELLOW SUBMARINE'
i =. 16 # 0
text =. d2c (b64d F) aes128cbcd (k; i)


NB. ---- TESTS ----
assert (+/ 'Sparkamatic' E. text) = 1
assert ((c2d text) aes128cbc (k; i)) = b64d F
