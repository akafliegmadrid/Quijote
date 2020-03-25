function [ out ] = funcion_objetivo( nPerfil, foilname, nSecciones,    ...
                                     nPanelX, nPanelY, vinf, h, alpha, ...
                                     Re, in )
% FUNCION_OBJETIVO combina linealmente los valores que se van a optimizar
%
%   Participantes:
%       - Andres Mateo Gabin

%% Extraer variables de diseño en 'in'
% Perfil
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

% Ala
bs   = in(16:18);
cs   = in(19:22);
fs   = in(23:25);
ds   = in(26:28);
ts   = in(29:32);

%% Algunos parametros de la simulacion
% Numero de Mach
[~, a, ~, ~] = ISAtmosphere(h);
Ma = vinf / a;

% Nombres de los archivos (rutas absolutas)
xfoilName   = [pwd filesep 'Perfil' filesep 'Xfoil' filesep foilname '_xfoil.dat'];
tornadoName = [pwd filesep 'Perfil' filesep 'Xfoil' filesep foilname '_tornado.dat'];

%% Funciones 'perfil' y 'ala'
[Cl, Cd, Cm] = perfil(nPerfil, xfoilName, tornadoName, rle, xt, yt, ...
                      bte, dzte, yle, xc, yc, ate, zte, b0, b2, b8, ...
                      b15, b17, alpha, Re, Ma);

%[CL, CD] = ala(nSecciones, nPanelX, nPanelY, tornadoName, ds, ts, ...
%               cs, fs, bs, vinf, h, alpha);

%% Funcion objetivo
alcance    = max(Cl.^(3.0/2.0)./Cd);
eficiencia = max(Cl./Cd);
out = -alcance - eficiencia - max(abs(Cm));

end
