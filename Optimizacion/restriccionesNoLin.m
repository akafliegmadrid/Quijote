function [ c, ceq ] = restriccionesNoLin ( MTOM, in )
% RESTRICCIONESNOLIN impone restricciones no lineales (c <= 0) y (ceq = 0)
%
%   Participantes:
%       - Andres Mateo Gabin

% Numero de desigualdades: 1
c = zeros(1, 1);
% Numero de igualdades: 1
ceq = zeros(1, 1);

% Restriccion del metodo BP3434
rle = in(1);
xt  = in(2);
yt  = in(3);
b8  = in(13);
c(1) = b8 - min( yt, sqrt(2.0*rle*xt/3.0) );

% Restriccion de carga alar
bs = in(16:18);
cs = in(19:22);
S  = 2.0 * sum( bs  .* (cs(1:end-1) + cs(2:end))/2.0 );
WS = MTOM / S * 9.81;
ceq(1) = WS - 42.0;

end