
syms Sx Sy Sz Sxy Sxz Syz x y z  real 

syms ca sa cz sz co so Amp ci si real

S = [Sx Sxy Sxz; Sxy Sy Syz; Sxz Syz Sz]
V = [x;y;z]

E = simplify(V'*(S)*V)