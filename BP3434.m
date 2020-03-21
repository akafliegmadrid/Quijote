function [ x, y ] = BP3434( npaneles, rle, xt, yt, bte, dzte, yle,...
                            xc, yc, ate, zte, b0, b2, b8, b15, b17 )
% BP3434 calcula 'n' nodos a lo largo del perfil a partir de 15 parametros
%   Basado en el articulo:
%   Derksen, R. W. & Rogalsky, T. Bezier-PARSEC: An optimized aerofoil
%   parameterization for design. Adv. Eng. Softw. 41, 923–930 (2010).
%
%   Participantes:
%       - Andres Mateo Gabin

% Si cada seccion se lleva la mitad de los paneles, hace falta dividir
% el eje X en N/2+1 puntos
xp = linspace(0.0, 1.0, floor(npaneles/2)+1);

% Vectores con los puntos de control
xc3 = zeros(4, 1);
yc3 = zeros(4, 1);
xc4 = zeros(5, 1);
yc4 = zeros(5, 1);

% Espesor (borde de ataque)
% Puntos de control
xc3(1) = 0.0;
xc3(2) = 0.0;
xc3(3) = 3.0 * b8^2 / (2.0 * rle);  % Modificado
xc3(4) = xt;

yc3(1) = 0.0;
yc3(2) = b8;
yc3(3) = yt;
yc3(4) = yt;

% Posicion de los nodos (equiespaciados)
xlt = xp(xp<xt);
t0  = linspace(0.0, 1.0, length(xlt));
t   = fsolve(@(t) bezier(t, xc3, yc3) - xlt, t0);
[~, ylt] = bezier(t, xc3, yc3);

% Curvatura (borde de ataque)
% Puntos de control
xc3(1) = 0.0;
xc3(2) = b0;
xc3(3) = b2;
xc3(4) = xc;

yc3(1) = 0.0;
yc3(2) = b0 * tan(yle);
yc3(3) = yc;
yc3(4) = yc;

% Posicion de los nodos (equiespaciados)
xlc = xp(xp<xc);
t0  = linspace(0.0, 1.0, length(xlc));
t   = fsolve(@(t) bezier(t, xc3, yc3) - xlc, t0);
[~, ylc] = bezier(t, xc3, yc3);

% Espesor (borde de salida)
% Puntos de control
xc4(1) = xt;
xc4(2) = (7.0*xt + 9.0*b8^2 / (2.0*rle)) / 4.0;
xc4(3) = 3.0*xt + 15.0*b8^2 / (4.0*rle);
xc4(4) = b15;
xc4(5) = 1.0;

yc4(1) = yt;
yc4(2) = yt;
yc4(3) = (yt + b8) / 2.0;
yc4(4) = dzte + (1.0 - b15) * tan(bte);
yc4(5) = dzte;

% Posicion de los nodos (equiespaciados)
xtt = xp(xp>=xt);
t0  = linspace(0.0, 1.0, length(xtt));
t   = fsolve(@(t) bezier(t, xc4, yc4) - xtt, t0);
[~, ytt] = bezier(t, xc4, yc4);

% Curvatura (borde de salida)
% Puntos de control
xc4(1) = xc;
xc4(2) = (3.0*xc - yc*cot(yle)) / 2.0;
xc4(3) = (-8.0*yc*cot(yle) + 13.0*xc) / 6.0;
xc4(4) = b17;
xc4(5) = 1.0;

yc4(1) = yc;
yc4(2) = yc;
yc4(3) = 5.0 * yc / 6.0;
yc4(4) = zte + (1.0 - b17) * tan(ate);
yc4(5) = zte;

% Posicion de los nodos (equiespaciados)
xtc = xp(xp>=xc);
t0  = linspace(0.0, 1.0, length(xtc));
t = fsolve(@(t) bezier(t, xc4, yc4) - xtc, t0);
[~, ytc] = bezier(t, xc4, yc4);

% Definicion del perfil
xt = [ xlt, xtt ];  % Tambien valdria [xlc, xtc]
yt = [ ylt, ytt ];
yc = [ ylc, ytc ];
yu = yc + yt;
yd = yc - yt;

% Y se concatenan los puntos para formar 'x' e 'y'
x = [ fliplr(xt), xt(2:end-1) ];
y = [ fliplr(yd), yu(2:end-1) ];

end
