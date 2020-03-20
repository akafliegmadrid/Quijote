function [ x, y ] = BP3434( npaneles, rle, xt, yt, bte, dzte, yle,...
                            xc, yc, ate, zte, b0, b2, b8, b15, b17 )
% BP3434 calcula 'n' nodos a lo largo del perfil a partir de 15 parametros
%   Basado en el articulo:
%   Derksen, R. W. & Rogalsky, T. Bezier-PARSEC: An optimized aerofoil
%   parameterization for design. Adv. Eng. Softw. 41, 923–930 (2010).
%
%   Participantes:
%       - Andres Mateo Gabin

% Si cada seccion se lleva la mitad de los puntos
t = linspace(0.0, 1.0, floor(npaneles/2));

% Vectores con los puntos de control
xc3 = zeros(4, 1);
yc3 = zeros(4, 1);
xc4 = zeros(5, 1);
yc4 = zeros(5, 1);

% Espesor (borde de ataque)
% Puntos de control
xc3(1) = 0.0;
yc3(1) = 0.0;
xc3(2) = 0.0;
yc3(2) = b8;
xc3(3) = 3.0 * b8^2 / (2.0 * rle);
yc3(3) = yt;
xc3(4) = xt;
yc3(4) = yt;

% Posicion de los nodos (equiespaciados)
[xlt, ylt] = bezier(t, xc3, yc3);

% Curvatura (borde de ataque)
% Puntos de control
xc3(1) = 0.0;
yc3(1) = 0.0;
xc3(2) = b0;
yc3(2) = b0 * tan(yle);
xc3(3) = b2;
yc3(3) = yc;
xc3(4) = xc;
yc3(4) = yc;

% Posicion de los nodos (equiespaciados)
% Hay que buscar las 'tt' que dan los mismos valores de x que antes
tt = fsolve(@(t) bezier(t, xc3, yc3) - xlt, xlt);
[xlc, ylc] = bezier(tt, xc3, yc3);

% Espesor (borde de salida)
% Puntos de control
xc4(1) = xt;
yc4(1) = yt;
xc4(2) = (7.0*xt + 9.0*b8^2 / (2.0*rle)) / 4.0;
yc4(2) = yt;
xc4(3) = 3.0*xt + 15.0*b8^2 / (4.0*rle);
yc4(3) = (yt + b8) / 2.0;
xc4(4) = b15;
yc4(4) = dzte + (1.0 - b15) * tan(bte);
xc4(5) = 1.0;
yc4(5) = dzte;

% Posicion de los nodos (equiespaciados)
[xtt, ytt] = bezier(t, xc4, yc4);

% Curvatura (borde de salida)
% Puntos de control
xc4(1) = xc;
yc4(1) = yc;
xc4(2) = (3.0*xc - yc*cot(yle)) / 2.0;
yc4(2) = yc;
xc4(3) = (-8.0*yc*cot(yle) + 13.0*xc) / 6.0;
yc4(3) = 5.0 * yc / 6.0;
xc4(4) = b17;
yc4(4) = zte - (1.0 - b17) * tan(ate);
xc4(5) = 1.0;
yc4(5) = zte;

% Posicion de los nodos (equiespaciados)
% Hay que buscar las 'tt' que dan los mismos valores de x que antes
tt = fsolve(@(t) bezier(t, xc4, yc4) - xtt, xtt);
[xtc, ytc] = bezier(tt, xc4, yc4);

% Definicion de las cuatro partes del perfil (sentido horario)
xlu = xlc;                   ylu = ylc + ylt;
xtu = xtc(2:end);            ytu = ytc(2:end) + ytt(2:end);
xtd = fliplr(xtc(1:end-1));  ytd = fliplr(ytc(1:end-1) - ytt(1:end-1));
xld = fliplr(xlc(2:end-1));  yld = fliplr(ylc(2:end-1) - ylt(2:end-1));

% Y se concatenan los puntos para formar 'x' e 'y'
x = [ xtd, xld, xlu, xtu ];
y = [ ytd, yld, ylu, ytu ];

end
