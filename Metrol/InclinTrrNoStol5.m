
syms a b Sa Sb R x y z x2 y2 z2  x1 y1 z1 Cz Cz1 m11 m12 m13 m14 m21 m22 m23 m24 m31 m32 m33 m34 I  real 

syms Hx0 Hy0 Hz0 Ax0 Ay0 Az0 real 
syms Hx1 Hy1 Hz1 Ax1 Ay1 Az1 real 
syms Hx2 Hy2 Hz2 Ax2 Ay2 Az2 real 
syms Hx3 Hy3 Hz3 Ax3 Ay3 Az3 real 

SG =  [a  R];
 
RT = [1 a 0;-a 1 0;0 0 1];

F1 = collect([Ax0 Ay0 Az0]*RT*[Hx0;Hy0;Hz0]-R, SG);
F2 = collect([Ax1 Ay1 Az1]*RT*[Hx1;Hy1;Hz1]-R, SG);
F3 = collect([Ax2 Ay2 Az2]*RT*[Hx2;Hy2;Hz2]-R, SG);
F4 = collect([Ax3 Ay3 Az3]*RT*[Hx3;Hy3;Hz3]-R, SG);


MV = collect(simplify(gradient((F1^2+F2^2+F3^2+F4^2)/2, SG)), SG) % ÕÃ 
% 
% solve(MV == 0, [a,R])

X = [m11,m12,m13,m14;m21,m22,m23,m24;m31,m32,m33,m34;] 

RX = [1 0 0; 0 cos(a) sin(a); 0 -sin(a) cos(a)]

RY = [cos(b) 0 -sin(b); 0 1 0; sin(b) 0 cos(b)]

RZ = [cos(a) sin(a) 0; -sin(a) cos(a) 0; 0 0 1]

RZ = [1 (a) 0; -(a) 1 0; 0 0 1]

RZ*X


R = simplify(RY*RX)

F = R*[x;y;z]

ML = [x1 y1 z1]*RZ*[x;y;z] - I

MV = gradient(ML^2, [a I])

R*X

SG =  [a b  Cz];
MV = collect(simplify(gradient((F(3)-Cz)^2/2, SG)), [x y z]) % ÕÃ 

                                                   
