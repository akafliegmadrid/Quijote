function [ out ] = function_objetivo( in )
% FUNCION_OBJETIVO combina linealmente los valores que se van a optimizar
%
%   Participantes:
%       - Andres Mateo Gabin

% Extraer valores en 'in'
rle  = in(1);
xt   = in(2);
yt   = in(3);
bte  = in(4);
dzte = in(5);
yle  = in(6);
xc   = in(7);
yc   = in(8);
ate  = in(9);
zte  = in(10);
b0   = in(11);
b2   = in(12);
b8   = in(13);
b15  = in(14);
b17  = in(15);
bs   = in(16:18);
cs   = in(19:21);
fs   = in(22:24);
ds   = in(25:27);
ts   = in(28:31);

% TODO
% Llamadas a funciones 'perfil' y 'ala'

% Funcion objetivo
%out = -CL^(3.0/2.0)/CD - CL/CD;

end function
