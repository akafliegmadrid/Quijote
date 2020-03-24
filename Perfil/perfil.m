function [ Cl, Cd, Cm ] = perfil( npaneles, xfoilName, tornadoName,    ...
                                  rle, xt, yt, bte, dzte, yle, xc, yc, ...
                                  ate, zte, b0, b2, b8, b15, b17,      ...
                                  alpha, Re, Ma )
% PERFIL calcula las propiedades del perfil a partir de la geometria
%   Interfaz entre Matlab y Xfoil para determinar caracteristicas
%   aerodinamicas dada la forma del perfil
%
%   Participantes
%       - Andres Mateo Gabin

% Coordenadas a partir de variables de diseño
[x, yu, yl] = BP3434(npaneles, rle, xt, yt, bte, dzte, yle, xc, yc, ...
                     ate, zte, b0, b2, b8, b15, b17);

% Se escribe el archivo del perfil para Xfoil
fid = fopen(xfoilName, 'w');
fprintf(fid, '%9.5f  %9.5f\n', [fliplr(x) x(2:end); fliplr(yl) yu(2:end)]);
fclose(fid);

% Se escribe el archivo del perfil para Tornado
fid = fopen(tornadoName, 'w');
fprintf(fid, '%9.5f  %9.5f\n', length(yu), length(yl));
fprintf(fid, '%9.5f  %9.5f\n', [x; yu]);
fprintf(fid, '%9.5f  %9.5f\n', [x; yl]);
fclose(fid);

% Llamada a Xfoil
%polar = xfoil(xfoilName, alpha, Re, Ma);

% Valores de salida de la funcion
%Cl = polar.CL;
%Cd = polar.CD + polar.CDp;
%Cm = polar.CM;

% DEBUG
Cl = 1.2;
Cd = 0.004;
Cm = -0.01;

end
