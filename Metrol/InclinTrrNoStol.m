
syms R m11 m12 m13 m14 m21 m22 m23 m24 m31 m32 m33 m34 x y z K1 K2 K3 Kzx Kzy real 

assume(m11 > 0)
assume(m22 > 0)
assume(m33 > 0)

M = [m11 m12 m13 m14; m21 m22 m23 m24; m31 m32 m33 m34];
%M = sym('m',[3,4]);
%MR = sym('r',[3,4]);


M = subs(M,m31, Kzx);
M = subs(M,m32, Kzy);
%M = subs(M,m33, 1);
M = subs(M,m21, 0);

V = [x;y;z;1];

V*V'

Vi = M*V



Xi = Vi(1);
Yi = Vi(2);
Zi = Vi(3);

%M1 = Vi/V

%MR = [mm11 mm12 mm13 mm14; mm21 mm22 mm23 mm24; mm31 mm32 mm33 mm34];

%solve(Vi = MR*V, MR)

F = ((Xi^2 + Yi^2 + Zi^2) - 1)^2;

F = collect(F,[x,y,z])

[KF, VARS] = coeffs(F, [x,y,z])

%X = sym('x', size(VARS))

dN =[m11, m22, m33, m12, m13, m23, m14, m24, m34];

A = sym('a', [size(dN,2), size(VARS,2)]);

for j=1:size(dN,2)
   for i=1:size(VARS,2)
      A(j, i)=diff(KF(1,i),dN(1,j));  
    end    
end
A = expand(A)

A = subs(A,m12^2,0);
A = subs(A,m12^3,0);

A = subs(A,m13^2,0);
A = subs(A,m13^3,0);

A = subs(A,m23^2,0);
A = subs(A,m23^3,0)

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