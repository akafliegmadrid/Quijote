% Dirige la optimizacion de la funcion objetivo
%
% TODO
%   - ¿Uno o varios perfiles a lo largo del ala?
%
%   Participantes:
%       - Andres Mateo Gabin

% Parametros del perfil
n    = 200;
rle  = 0.1;
xt   = 0.25;
yt   = 0.05;
bte  = deg2rad(15.0);
dzte = 0.02;
yle  = deg2rad(15.0);
xc   = 0.2;
yc   = 0.05;
ate  = deg2rad(10.0);
zte  = 0.01;
b0   = 0.1;
b2   = 0.2;
b8   = 0.05;
b15  = 0.1;
b17  = 0.9;

% Parametros del ala
b2 = [8.0, 1.0, 1.0];
c  = [0.9, 0.5, 0.2];
f  = deg2rad([-1.0, 0.0, 1.0]);
d  = deg2rad([2.0, 5.0, 7.0]);
t  = deg2rad([2.0, 2.0, 2.0, 2.0]);
