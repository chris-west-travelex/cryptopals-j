NB. j is a headfck

NB. h2d (monad) converts hex string to decimal array
    HEX =. '0123456789abcdef'
    f =. +/ @: (* & 16 1)
h2d =: (_2 & (f\ HEX & i.)) f.

NB. d2c convert decimal sequence to ASCII string
d2c =: { & a.

bshift =: 33 b.  NB. <<
band =: 17 b.    NB. &

NB. b64 _ encodes an array of decimals into a base64 string.
    NB. map 0-64 to b64 char
    B64 =. 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
    lookup =. { & B64
    NB. c1, c2 calculate 6-bit chars from three nibbles
    c1 =. (2 & bshift @: {.) + (_2 & bshift @: (1 & {))
    c2 =. ((4 & bshift @: (1&{ @: band & 3)) + {:)
    NB. fit nibbles into groups of three; zero-padded
    fitted =. (_3 & ([\))
    NB. convert bytes into nibbles
    nibs =. , @: (_2 & ((_4 & bshift @: band & 240, band & 15)"0 \ ))
    NB. calculate expected padding characters
    pad =. > @: (((0$0); 64 64; 64) {~ (3 | #))
    NB. calculate expected number of output characters
    sz =. >. @: ((4%3) * #)
    NB. derive 0-64 6-bit values, to index into char lookup
    indices =. sz {. (, @: ((c1 , c2)"1 @: fitted @: nibs))
b64 =: (lookup @: (indices, pad)) f.

assert (b64 h2d '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d') = 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'
assert (b64 h2d '4927') = 'SSc='
assert (b64 h2d '49')   = 'SZ=='
