
syms ax ay az dx dy dz alpha betta gamma R x y z xN yN zN Kzx Kzy Cz real 

assume(ax > 0)
assume(ay > 0)
assume(az > 0)

% Vm = [x;y;z];
% Amp = diag([1 ay az]) 
% Vd = [dx;dy;dz]
% Ku = [1 alpha betta; 0 1 gamma; 0 0 1]
% 
% Vi = Ku*(Amp*(Vm + Vd))

M = [1 alpha betta dx; 0 ay gamma dy; Kzx Kzy az dz]

Vi = M* [x;y;z;1]

Viz = M* [xN;yN;zN;1]

%inv(Ku*Amp)
F = Vi' * Vi - R^2 % уравнение сферы
Fz = Viz(3)-Cz

collect(Fz^2,[xN yN zN])

[KF, VARS] = coeffs(F, [ x, y,  z])

%VARS(:,[1,2,3,4,5,6,7,8,9,10]) = VARS(:,[1,2,5,3,6,8,4,7,9,10])
%KF(:,[1,2,3,4,5,6,7,8,9,10])   = KF(:,[1,2,5,3,6,8,4,7,9,10])
 


KK = simplify(collect(KF', [ay, az]))

syms AX2 AY2 AZ2 SSS real
%KK = subs(KK, ax^2, AX2);
%KK = subs(KK, ay^2, AY2);
%KK = simplify(subs(KK, az^2, AZ2));
%KK = subs(KK, (dx + alpha*dy + betta*dz), SSS);



syms        a    b   c   s1 s2  s3 s4 s5 s6 s7 s8 s9 lambda real
syms        c   s1 s2  s3 s4 s5 s6 s7 s8 s9 lambda real
syms        Sal  Sbt Sdx SAY Sgm  Sdy SAZ Sdz SR real
S =      [Kzx Sal  Sbt Sdx SAY Sgm  Sdy SAZ Sdz SR]; %  S10 = -1  4ac - b^2 = 1 условие из теории
SG =      [Kzx Sal  Sbt Sdx SAY Sgm  Sdy SAZ Sdz SR Kzy Cz]; % 4ac - b^2 = 1 условие из теории
          
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

MV = collect(S*VARS'*VARS*S' + (Fz)^2,[x,y,z])
MV2 = collect(F^2',[x,y,z])
MV = expand(gradient(MV, SG))/2 % НМК

MV = collect(MV, SG)

VARS'*VARS

[KF, VARS] = coeffs(MV, SG)


KF = expand(KF)

KF = subs(KF,a^2, 0);
KF = subs(KF,b^2, 0);
KF = subs(KF,c^2, 0);

[KF, VARS] = coeffs(KF, SG)




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