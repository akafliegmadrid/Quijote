function [ Cl, Cd, Cm ] = perfil( npaneles, foilname, rle, xt, yt,  ...
                                  bte, dzte, yle, xc, yc, ate, zte, ...
                                  b0, b2, b8, b15, b17, alpha, Re, Ma )
% PERFIL calcula las propiedades del perfil a partir de la geometria
%   Interfaz entre Matlab y Xfoil para determinar caracteristicas
%   aerodinamicas dada la forma del perfil
%
%   Participantes
%       - Andres Mateo Gabin

[x, y] = BP3434(npaneles, rle, xt, yt, bte, dzte, yle, xc, yc, ...
                ate, zte, b0, b2, b8, b15, b17);

% Se escribe el archivo del perfil (tambien vale para el modulo del ala)
wd  = fileparts(which(mfilename));
fid = fopen([wd filesep 'Xfoil' filesep foilname], 'w');
fprintf(fid, '%s\n', 'Foil_1');
fprintf(fid, '%9.5f   %9.5f\n', [x; y]);
fclose(fid);

% Llamada a Xfoil
polar = xfoil(foilname, alpha, Re, Ma);

% Valores de salida de la funcion
Cl = polar.CL;
Cd = polar.CD + polar.CDp;
Cm = polar.CM;

end
