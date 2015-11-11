
syms a b Sa Sb R x0 y0 z0 x2 y2 z2  x1 y1 z1 Cz Cz1 m11 m12 m13 m14 m21 m22 m23 m24 m31 m32 m33 m34  real 

syms ca sa cz sz co so Amp ci si real

RO = [co so 0; -so co 0; 0 0 1]
RZ = [cz 0 -sz; 0 1 0; sz 0 cz]
RA = [ca sa 0; -sa ca 0; 0 0 1]

A = collect(simplify(RO*RZ*RA*[Amp*ci; 0; Amp*si]), Amp) 

G = collect(simplify(RO*RZ*RA*[0; 0; Amp]), Amp) 


 SG =  [a  b];
 
% F = a*x0 + b*y0 + z0;
% F1 = a*x1 + b*y1 + z1;
% F2 = a*x2 + b*y2 + z2;
% 
%  MV = collect(gradient((F^2 + F1^2 + F2^2)/2, SG), SG); % ÕÃ 
%  
% MV = simplify(MV)


% MV = [b*(x0*y0 + x1*y1 + x2*y2 + x3*y3) - y1*z1 - y2*z2 - y3*z3 - y0*z0 + a*(y0^2 + y1^2 + y2^2 + y3^2) + Cz*(y0 + y1 + y2 + y3);
%       a*(x0*y0 + x1*y1 + x2*y2 + x3*y3) - x1*z1 - x2*z2 - x3*z3 - x0*z0 + b*(x0^2 + x1^2 + x2^2 + x3^2) + Cz*(x0 + x1 + x2 + x3)]
% 
% MV = subs(MV, Cz, ((z0 + z1 + z2 + z3) - b*(x0 + x1 + x2 + x3) - a*(y0 + y1 + y2 + y3))/4) ;  
% 
% MV = collect(simplify(MV), [a, b])

RR = [1  0  b; 0  1  a; -b  -a  1]

RT = [1 a 0;-a 1 0;0 0 1]

    
X = [m11,m12,m13,m14;m21,m22,m23,m24;m31,m32,m33,m34;] 

R = [1, 0, -0; 0,    1, a; 0,   -a, 1]

R*X

RR*X
RT*X

M = [m11,m12,m13;m21,m22,m23;m31,m32,m33;]

M1 = inv(M)*(m11*m22*m33 - m11*m23*m32 - m12*m21*m33 + m12*m23*m31 + m13*m21*m32 - m13*m22*m31) 

simplify(M1*M)

collect(M1*[m14;m24;m34],[m14, m24, m34])

sims
