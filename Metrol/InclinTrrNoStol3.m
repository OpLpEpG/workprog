
syms a b Sa Sb R x0 y0 z0 x2 y2 z2 x3 y3 z3 x1 y1 z1 Cz real 
syms x01 y01 z01 x21 y21 z21 x31 y31 z31 x11 y11 z11 Cz1 real 

RX = [1 0 0; 0 cos(a) sin(a); 0 -sin(a) cos(a)]

RY = [cos(b) 0 -sin(b); 0 1 0; sin(b) 0 cos(b)]

simplify(RY*RX)

%assume(ax > 0)
%assume(ay > 0)
%assume(az > 0)

Exy = [1 0 0; 0 1 0;0 0 0];
Ez = [0 0 0; 0 0 0;0 0 1];

Vm0 = [x0;y0;z0];
Vm1 = [x1;y1;z1];
Vm2 = [x2;y2;z2];
Vm3 = [x3;y3;z3];
Vm01 = [x01;y01;z01];
Vm11 = [x11;y11;z11];
Vm21 = [x21;y21;z21];
Vm31 = [x31;y31;z31];

% Amp = diag([1 ay az]) 
% Vd = [dx;dy;dz]
% Ku = [1 alpha betta; 0 1 gamma; 0 0 1]
% 
simplify(inv(RX*RY))

R = RX*RY
R = subs(R, [cos(a), cos(b), sin(a), sin(b)],[1,1,a, b]);
%R = subs(R, [cos(a), cos(b)],[1,1]);
R = subs(R, a*b, 0)

Vi0 =R* Vm0;
Vi1 =R* Vm1;
Vi2 =R* Vm2;
Vi3 =R* Vm3;
Vi01 =R* Vm01;
Vi11 =R* Vm11;
Vi21 =R* Vm21;
Vi31 =R* Vm31;


 Fz0 = Vi0(3)-Cz;
 Fz1 = Vi1(3)-Cz;
 Fz2 = Vi2(3)-Cz;
 Fz3 = Vi3(3)-Cz;
 Fz01 = Vi01(3)-Cz1;
 Fz11 = Vi11(3)-Cz1;
 Fz21 = Vi21(3)-Cz1;
 Fz31 = Vi31(3)-Cz1;

 SG =  [a  b Cz Cz1];
 
 (z0 - a*y0 - b*x0 -Cz)^2
 
 %F = collect(expand(Fxy^2), [x,y,z])

%  [KF, VARS] = coeffs(F, [ x, y,  z])

MV = collect(gradient((Vi0(3)-Cz)^2, SG)/2, SG) % НМК

 MV = collect(gradient(Fz0^2 + Fz1^2 +Fz01^2 + Fz11^2, SG)/2, SG) % НМК
 
 solve(MV,SG)
 
% MV1 =[(z - a*y - b*x)*y + (z1 - a*y1 - b*x1)*y1 - y*z - y1*z1 + b*(x*y + x1*y1) + a*(y^2 + y1^2);
%  (z - a*y - b*x)*x + (z1 - a*y1 - b*x1)*x1 - x*z - x1*z1 + a*(x*y + x1*y1) + b*(x^2 + x1^2)]
%                                             Cz = z - a*y - b*x;
%                                          Cz1 = z1 - a*y1 - b*x1;
% 
% MV1 = collect(MV1, [a, b])                                         
%  
%  [KF, VARS] = coeffs(F, [ x, y,  z])
%  
%  simplify(KF')
 

%VARS(:,[1,2,3,4,5,6,7,8,9,10]) = VARS(:,[1,2,5,3,6,8,4,7,9,10])
%KF(:,[1,2,3,4,5,6,7,8,9,10])   = KF(:,[1,2,5,3,6,8,4,7,9,10])
 
% KK = simplify(collect(KF', [ay, az]))
% 
% syms AX2 AY2 AZ2 SSS real
%KK = subs(KK, ax^2, AX2);
%KK = subs(KK, ay^2, AY2);
%KK = simplify(subs(KK, az^2, AZ2));
%KK = subs(KK, (dx + alpha*dy + betta*dz), SSS);



% syms        a    b   c   s1 s2  s3 s4 s5 s6 s7 s8 s9 lambda real
% syms        c   s1 s2  s3 s4 s5 s6 s7 s8 s9 lambda real
% syms        Sal  Sbt Sdx SAY Sgm  Sdy SAZ Sdz SR real
% S =      [1 Sal  Sbt Sdx SAY Sgm  Sdy SAZ Sdz SR]; %  S10 = -1  4ac - b^2 = 1 условие из теории
% SG =      [Sal  Sbt Sdx SAY Sgm  Sdy SAZ Sdz SR]; % 4ac - b^2 = 1 условие из теории
          
%S'*S;

%C = zeros(10,10);

%C(1, 5) = 2;
%C(5, 1) = 2;
%C(2, 2) = -1;

%lambda*C*S';

%S*C*S'-1; %  1    2    3   4   5    6   7   8   9
% VARS = [ x^2, x*y, x*z, x, y^2, y*z, y, z^2, z, 1]
%           1    2    5    3    6    8  4    7  9                   q
% VARS = [ x^2, x*y, y^2, x*z, y*z, z^2, x,  y, z, 1]
%
%[     x^4,   x^3*y,   x^3*z,   x^3, x^2*y^2, x^2*y*z, x^2*y, x^2*z^2, x^2*z, x^2]
%[   x^3*y, x^2*y^2, x^2*y*z, x^2*y,   x*y^3, x*y^2*z, x*y^2, x*y*z^2, x*y*z, x*y]
%[   x^3*z, x^2*y*z, x^2*z^2, x^2*z, x*y^2*z, x*y*z^2, x*y*z,   x*z^3, x*z^2, x*z]
%[     x^3,   x^2*y,   x^2*z,   x^2,   x*y^2,   x*y*z,   x*y,   x*z^2,   x*z,   x]
%[ x^2*y^2,   x*y^3, x*y^2*z, x*y^2,     y^4,   y^3*z,   y^3, y^2*z^2, y^2*z, y^2]
%[ x^2*y*z, x*y^2*z, x*y*z^2, x*y*z,   y^3*z, y^2*z^2, y^2*z,   y*z^3, y*z^2, y*z]
%[   x^2*y,   x*y^2,   x*y*z,   x*y,     y^3,   y^2*z,   y^2,   y*z^2,   y*z,   y]
%[ x^2*z^2, x*y*z^2,   x*z^3, x*z^2, y^2*z^2,   y*z^3, y*z^2,     z^4,   z^3, z^2]
%[   x^2*z,   x*y*z,   x*z^2,   x*z,   y^2*z,   y*z^2,   y*z,     z^3,   z^2,   z]
%[     x^2,     x*y,     x*z,     x,     y^2,     y*z,     y,     z^2,     z,   1]

% MV = collect(S*VARS'*VARS*S',[x,y,z])
% MV2 = collect(F^2',[x,y,z])
% MV = expand(gradient(MV, SG))/2 % НМК
% 
% MV = collect(MV, SG)
% 
% VARS'*VARS
% 
% [KF, VARS] = coeffs(MV, SG)
% 
% 
% KF = expand(KF)
% 
% KF = subs(KF,a^2, 0);
% KF = subs(KF,b^2, 0);
% KF = subs(KF,c^2, 0);
% 
% [KF, VARS] = coeffs(KF, SG)




%M = [m11 m12 m13 m14; m21 m22 m23 m24; m31 m32 m33 m34];
%M = sym('m',[3,4]);
%MR = sym('r',[3,4]);
%M = subs(M,m31, 0);
%M = subs(M,m32, 0);
%M = subs(M,m33, 1);
%M = subs(M,m21, 0);

%V = [x;y;z;1];

%Vi = M*V



%Xi = Vi(1);
%Yi = Vi(2);
%Zi = Vi(3);

%M1 = Vi/V

%MR = [mm11 mm12 mm13 mm14; mm21 mm22 mm23 mm24; mm31 mm32 mm33 mm34];

%solve(Vi = MR*V, MR)

%F = ((Xi^2 + Yi^2 + Zi^2) - 1)^2;

%F = collect(F,[x,y,z])

%[KF, VARS] = coeffs(F, [x,y,z])

%X = sym('x', size(VARS))

%dN =[m11, m22, m33, m12, m13, m23, m14, m24, m34];

%A = sym('a', [size(dN,2), size(VARS,2)]);

% for j=1:size(dN,2)
%    for i=1:size(VARS,2)
%       A(j, i)=diff(KF(1,i),dN(1,j));  
%     end    
% end
% A = expand(A)
% 
% A = subs(A,m12^2,0);
% A = subs(A,m12^3,0);
% 
% A = subs(A,m13^2,0);
% A = subs(A,m13^3,0);
% 
% A = subs(A,m23^2,0);
% A = subs(A,m23^3,0)

%A = subs(A, m13*m12,K1);

%A = subs(A, m23*m12,K2);
%A = subs(A, m23*m13,K3)

%R = solve(A*VARS', dN)

%solve('A*VARS'
%F = subs(F, VARS(1), X(1)) 

%F = expand(F)
%F = collect(F,[x,y,z])

%DF = gradient(F, [m11, m22, m12, m13, m23, m14, m24, m34, R]);

%KF1 = coeffs(DF,VARS)

%DF = DF / [x^4,y^4,z^4, x^3,y^3,z^3, x^2,y^2,z^2, x,y,z,1]