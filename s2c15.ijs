load 'pkcs7.ijs'

S =. c2d 'ICE ICE BABY'

assert (pkcs7_valid S , 4 # 4) = 1
assert (pkcs7_valid S , 4 # 5) = 0
assert (pkcs7_valid S , 1 + i.4) = 0
