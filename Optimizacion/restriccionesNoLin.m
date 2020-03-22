function [ c, ceq ] = restriccionesNoLin ( in )
% RESTRICCIONESNOLIN impone restricciones no lineales (c <= 0) y (ceq = 0)
%
%   Participantes:
%       - Andres Mateo Gabin

% Numero de desigualdades: 1
c = zeros(1, 1);
% Numero de igualdades: 0
ceq = -1.0;

% Restriccion del metodo BP3434
rle = in(1);
xt  = in(2);
yt  = in(3);
b8  = in(13);
c(1) = b8 - min( yt, sqrt(2.0*rle*xt/3.0) );

end