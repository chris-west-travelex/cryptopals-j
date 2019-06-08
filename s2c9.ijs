load 'utils.ijs'
load 'pkcs7.ijs'


NB. ---- TESTS ----
assert(20 pkcs7 c2d 'YELLOW SUBMARINE') = 89 69 76 76 79 87 32 83 85 66 77 65 82 73 78 69 4 4 4 4
