load 'utils.ijs'

B64 =. 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='

NB. b64 _ encodes an array of decimals into a base64 string.
    NB. map 0-64 to b64 char
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

NB. b64d _ decodes a base64 string into an array of decimals
    NB. parse chars and strip garbage
    lookup =. 65 -.~ B64 & i.
    NB. convert 6-bit values back to bytes
    b1 =. (2 & bshift @: (0&{)) + (_4 & bshift @: (1&{))
    b2 =. 16bff & band @: ((4 & bshift @: (1&{)) + (_2 & bshift @: (2&{)))
    b3 =. 16bff & band @: ((6 & bshift @: (2&{)) + (3&{))
    NB. swap padding to zeroes to stop b1-3 calcs breaking
    unpad =. 63 & band
    NB. calculate number of trailing nulls
    trim =. _1 * [: +/ '=' & E.
b64d =: (trim }. [: , _4 (b1, b2, b3)\ [: unpad lookup) f.


NB. ---- TESTS ----
assert (b64 h2d '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d') = 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'
assert (b64 c2d 'Man') = 'TWFu'
assert (b64 c2d 'Ma') = 'TWE='
NB. assert (b64 c2d 'M') = 'TQ=='  NB. this is broken for 1 char

assert (b64d 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t') = h2d '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'
assert (b64d 'TWFu') = c2d 'Man'
assert (b64d 'TWE=') = c2d 'Ma'
assert (b64d 'TQ==') = c2d 'M'
