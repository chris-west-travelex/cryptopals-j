load 'aes.ijs'

NB. load the file and box each row
F =. 1!:1 < '7.txt'

text =. (b64d F) aes128ecbd 'YELLOW SUBMARINE'
echo text

NB. ---- TESTS ----
assert (+/ 'Sparkamatic' E. text) = 1
