function [ A, b, Aeq, beq ] = restriccionesLin ( bw, in )
% RESTRICCIONESLIN impone restricciones que puedan expresarse: Aeq*x = beq
%
%   Participantes:
%       - Andres Mateo Gabin

% Numero de desigualdades lineales: 5
A = zeros(5, length(in));
b = zeros(5,1);

% Numero de igualdades lineales: 1
Aeq = zeros(1, length(in));
beq = zeros(1, 1);

% Envergadura siempre igual a 'b'
Aeq(1,16:18) = 1.0;
beq(1)       = bw/2.0;

% Consistencia en parametros BP3434
% b8 < yt
A(1,13) = 1.0;
A(1,3)  = -1.0;

% b15 > xt
A(2,14) = -1.0;
A(2,2)  = 1.0;

% b0 < b2
A(3,11) = 1.0;
A(3,12) = -1.0;

% b2 < xc
A(4,12) = 1.0;
A(4,7)  = -1.0;

% b17 > xc
A(5,15) = -1.0;
A(5,7)  = 1.0;

end
