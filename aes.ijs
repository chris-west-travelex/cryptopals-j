load 'utils.ijs'

NB. 8-bit <<<
rotl8 =: (255) 17 b. 33 b. + ] 33 b.~ 8 -~ [

NB. affine transformation
affine =: 13 : 'x xor (1 rotl8 x) xor (2 rotl8 x) xor (3 rotl8 x) xor (4 rotl8 x) xor 16b63'

NB. function ab = poly_mult (a, b, mod_pol)
NB.  ab = 0;
NB.  for i_bit = 1 : 8
NB.    if bitget (a, i_bit)
NB.      b_shift = bitshift (b, i_bit - 1);
NB.      ab = bitxor (ab, b_shift);
NB.    end
NB.  end
NB.  for i_bit = 16 : -1 : 9
NB.    if bitget (ab, i_bit)
NB.      mod_pol_shift = bitshift (mod_pol, i_bit - 9);
NB.      ab = bitxor (ab, mod_pol_shift);
NB.    end
NB.  end
NB. mod_pol = 283 (16b11b)
    NB. mod_pol
    MP =. 16b11b
    NB. bitshift x by bit offsets in y and then xor
    mul =. 13 : '(22 b.)/ x (33 b.)~ I. |. #: y'
    NB. bitshift MP by 9 - (offset of high bit)
    mpshift =. MP 33 b.~ _9 + # @: #:
    NB. while high bits exist, xor input with bitshifted MP
    div =. (22 b. mpshift) ^:( 0 < 65280 (17 b.) ] )^:_
    NB. do unbounded multiplication, then divide by MP
    pm16 =. div @: mul
pm =: (255 & (17 b.) @: pm16)"0 0 f.

NB. Rijndael substitution box
NB. 3 pm^:(i.15) 1
NB. 3x => 1  3  5  f 11 33 55 ff 1a 2e 72 96 a1 f8 13 ..
NB. 16bf6 pm^:(i.15) 1
NB. 3% => 1 f6 52 c7 b4 6c 24 1c fd a2 97 84 7c dd 4b ..
SBOX =: 99, (affine 246 pm^:(i.255) 1) /: (3 pm^:(i.255) 1)
INVSBOX =: SBOX i. i.256

NB. Round constant matrix
RCON =: ,. 4 ({."0) 10 1 $ 2 pm^:(i. 10) 1

NB. Left-rotate 4 bytes
rotw =. (/:"1) & 3 0 1 2

NB. Generate key schedule (AES 128)
    NB. every 4th row
    f =. 13 : '(_4 { x) (22 b.) ((_1 + (4 <.@% ~# x)) { RCON) (22 b.) (SBOX {~ rotw _1 { x)'
    NB. other rows
    g =. 13 : '(_1 & { x) (22 b.) (_4 & { x)'
    NB. apply f or g depending on row, for 40 rows
    h =. (, f`g`g`g @. (4 & |~ @: #))^:(i.41)
    NB. get the final set of rows
    rs =. {: @: h @: (4 4 & $)
    NB. finally, break into groups of four and pivot col-wise
ksched =: (13 : '(|:"2) 11 4 $ rs x') f.

NB. Mix columns
POLYM =. 4 4 $ 2 3 1 1 1 2 3 1 1 1 2 3 3 1 1 2
INVPOLYM =. 4 4 $ 14 11 13 9 9 14 11 13 13 9 14 11 11 13 9 14

NB. this uses i.16 to drive row and col selection in x and y; then
NB. pms each row/col quad, and xors the result
mixcols =. 13 : '4 4 $ (22 b.)/"1 1 ((_2 (33 b.) i.16) { x) pm ((3 (17 b.) i.16) { y)'

NB. Shift rows
shiftrows =. (i. 4) & (|."0 1)
invshiftrows =. ((i._4) - 3) & (|."0 1)

NB. initial state (from plain/cipher text)
initstate =. |: @: (4 4 & $)

NB. x aes128 y -- encrypt 16 bytes of x with 16 byte key y
    NB. round of: xor key schedule, sub bytes, shift rows, mix cols
    round =. POLYM mixcols [: |: @: shiftrows SBOX {~ [ 22 b. ]
    NB. final round: xor key schedule, sub bytes, shift rows
    finalround =. [: shiftrows SBOX {~ [ 22 b. ]
    NB. use round/ to process first 9 roundkeys; finalround for 10th,
    NB. then xor last one
    cipher =. 13 : ', |: (10 { y) 22 b. (round/ (|. (initstate x), (i.9) { y)) finalround (9 { y)'
aes128 =: (cipher ksched) f.

NB. x aes128d y -- decrypt 16 bytes of x with 16 byte key y
    NB. round of: shift rows, sub bytes, xor key sched, mix cols
    invround =. INVPOLYM & mixcols @: |: @: (22 b.)  INVSBOX {~ invshiftrows
    NB. final round omits mixcols
    decipher =. 13 : ', |: (0{y) 22 b. INVSBOX {~ invshiftrows invround/(((1+i.9){y), ((10{y) 22 b. initstate x))'
aes128d =: (decipher ksched) f.


NB. ECB -- this returns a string because it makes the output
NB.        slightly more sane. decrypt x with key y
aes128ecbd =: 13 : ', d2c (_16[\x) aes128d"1 1 y'


NB. ---- TEST HELPERS ----
NB. generate Rijndael S-Box using code from the matlab paper
matlabsbox =. 3 : 0
   p =. 1
   q =. 1
   out =. 99, 255 # 0

   whilst. p > 1 do.
       NB. p = p ^ (p << 1) ^ (p & 0x80 ? 0x1B : 0);
       p =. 255 band p xor (1 bshift p) xor (((p band 16b80) > 0) { 0 16b1b)

       NB. q ^= q << 1;
       NB. q ^= q << 2;
       NB. q ^= q << 4;
       NB. q ^= q & 0x80 ? 0x09 : 0;
       q =. q xor (1 bshift q)
       q =. q xor (2 bshift q)
       q =. q xor (4 bshift q)
       q =. 255 band q xor ((q band 16b80) > 0) { 0 9

       NB. uint8_t xformed = q ^ ROTL8(q, 1) ^ ROTL8(q, 2) ^ ROTL8(q, 3) ^ ROTL8(q, 4);
       NB.  xformed ^ 0x63;
       out =. (affine q) p} out
   end.
   out
)
NB. SBOX =: sboxfn ''

NB. ---- TESTS ----
assert (5 rotl8 255) = 255

assert (87 pm 163) = 207
assert (255 pm 3) = 26
assert (246 pm 246) = 82

assert (affine 1) = 16b7c
assert (affine 16bf6) = 16b7b

assert (0 { SBOX) = 16b63
assert (1 { SBOX) = 16b7c
assert (16b99 { SBOX) = 16bee
assert (0 { INVSBOX) = 16b52
assert (1 { INVSBOX) = 16b09
assert (matlabsbox '') = SBOX

assert (8 { RCON) = 27 0 0 0

k =. ksched h2d '2b7e151628aed2a6abf7158809cf4f3c'
assert ($ k) = 11 4 4
assert (0 { |: 10 { k) = h2d 'd014f9a8'
assert (1 { |: 10 { k) = h2d 'c9ee2589'
assert (2 { |: 10 { k) = h2d 'e13f0cc8'
assert (3 { |: 10 { k) = h2d 'b6630ca6'

c =. POLYM mixcols 4 4 $ h2d '6353e08c0960e104cd70b751bacad0e7'
assert ($ c) = 4 4
assert (0 { c) = h2d '5f57f71d'
assert (1 { c) = h2d '72f5beb9'
assert (2 { c) = h2d '64bc3bf9'
assert (3 { c) = h2d '1592291a'

assert (, shiftrows 4 4 $ i.16) = 0 1 2 3 5 6 7 4 10 11 8 9 15 12 13 14
assert (, invshiftrows 4 4 $ i.16) = 0 1 2 3 7 4 5 6 10 11 8 9 13 14 15 12

NB. NIST test vectors
pt =. h2d '00112233445566778899aabbccddeeff'
key =. i.16
res =. h2d '69c4e0d86a7b0430d8cdb78070b4c55a'
assert(pt aes128 key) = res
assert(res aes128d key) = pt
