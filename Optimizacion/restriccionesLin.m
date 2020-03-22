function [ Aeq, beq ] = restriccionesLin ( b, in)
% RESTRICCIONESLIN impone restricciones que puedan expresarse: Aeq*x = beq
%
%   Participantes:
%       - Andres Mateo Gabin

% Numero de restricciones lineales: 1
Aeq = zeros(1, length(in));
beq = zeros(1, 1);

% Envergadura siempre igual a 'b'
Aeq(1,16:18) = 1.0;
beq(1)       = b/2.0;

end
