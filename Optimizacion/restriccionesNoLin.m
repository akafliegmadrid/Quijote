function [ c, ceq ] = restriccionesNoLin ( modo, MTOM, in )
% RESTRICCIONESNOLIN impone restricciones no lineales (c <= 0) y (ceq = 0)
%
%   Participantes:
%       - Andres Mateo Gabin

% Numero de desigualdades: 1
c = [];

% Numero de igualdades: 1
ceq = [];

% Restriccion del metodo BP3434
if strcmp(modo, 'Completo') || strcmp(modo, 'Perfil')
    rle = in(1);
    xt  = in(2);
    yt  = in(3);
    b8  = in(13);
    c = [b8 - min( yt, sqrt(2.0*rle*xt/3.0) )];
end

% Restriccion de carga alar (WS = 42 kg/m^2)
if strcmp(modo, 'Ala')
    ceq = zeros(1, 1);
    bs = in(1:3);
    cs = in(4:7);
    S  = 2.0 * sum( bs  .* (cs(1:end-1) + cs(2:end))/2.0 );
    WS = MTOM / S;
    ceq = [WS - 42.0];
elseif strcmp(modo, 'Completo')
    ceq = zeros(1, 1);
    bs = in(16:18);
    cs = in(19:22);
    S  = 2.0 * sum( bs  .* (cs(1:end-1) + cs(2:end))/2.0 );
    WS = MTOM / S;
    ceq = [WS - 42.0];
end

end