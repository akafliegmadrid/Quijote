function [ x, yu, yl ] = BP3434( npaneles, rle, xt, yt, bte, dzte, yle,...
                                 xc, yc, ate, zte, b0, b2, b8, b15, b17 )
% BP3434 calcula 'n' nodos a lo largo del perfil a partir de 15 parametros
%   Basado en el articulo:
%   Derksen, R. W. & Rogalsky, T. Bezier-PARSEC: An optimized aerofoil
%   parameterization for design. Adv. Eng. Softw. 41, 923–930 (2010).
%
%   Participantes:
%       - Andres Mateo Gabin

% La seccion frontal de la curva de espesor se lleva un numero de puntos
% proporcional a la posicion de 'xt'
nlt = ceil((ceil(npaneles/2)+1)*xt);
ntt = ceil(npaneles/2)+1 - nlt + 1;   % Luego se elimina para evitar dups.
tlt = linspace(0.0, 1.0, nlt);
ttt = linspace(0.0, 1.0, ntt);  ttt = ttt(2:end);

% Vectores con los puntos de control
xc3 = zeros(4, 1);
yc3 = zeros(4, 1);
xc4 = zeros(5, 1);
yc4 = zeros(5, 1);

%% Espesor (borde de ataque)
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
[Cx, Cy] = bezier(xc3, yc3);
xlt      = polyval(Cx, tlt);
ylt      = polyval(Cy, tlt);

%% Espesor (borde de salida)
% Puntos de control
xc4(1) = xt;
xc4(2) = (7.0*xt - 9.0*b8^2 / (2.0*rle)) / 4.0;
xc4(3) = 3.0*xt - 15.0*b8^2 / (4.0*rle);
xc4(4) = b15;
xc4(5) = 1.0;

yc4(1) = yt;
yc4(2) = yt;
yc4(3) = (yt + b8) / 2.0;
yc4(4) = dzte + (1.0 - b15) * tan(bte);
yc4(5) = dzte;

% Posicion de los nodos (equiespaciados)
[Cx, Cy] = bezier(xc4, yc4);
xtt      = polyval(Cx, ttt);
ytt      = polyval(Cy, ttt);

%% Espesor total
xat = [ xlt, xtt ];
yat = [ ylt, ytt ];

%% Curvatura (borde de ataque)
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
[Cx, Cy] = bezier(xc3, yc3);
xlc = xat(xat<xc);
tlc = zeros(1, length(xlc));
for i = 2: length(xlc)-1
    Cxt = [Cx(1:end-1) Cx(end)-xlc(i)];
    sol = roots(Cxt);
    sol = sol(imag(sol)==0.0);
    tlc(i) = sol(and(sol>=0.0, sol<=1.0));
end
tlc(end) = 1.0;
ylc = polyval(Cy, tlc);

%% Curvatura (borde de salida)
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
[Cx, Cy] = bezier(xc4, yc4);
xtc = xat(xat>=xc);
ttc = zeros(1, length(xtc));
for i = 2: length(xtc)-1
    Cxt = [Cx(1:end-1) Cx(end)-xtc(i)];
    sol = roots(Cxt);
    sol = sol(imag(sol)==0.0);
    ttc(i) = sol(and(sol>=0.0, sol<=1.0));
end
ttc(end) = 1.0;
ytc = polyval(Cy, ttc);

%% Curvatura total
% xac = [ xlc, xtc ];  % Debe coincidir con 'xat'
yac = [ ylc, ytc ];

%% Definicion del perfil
x  = xat;
yu = yac + yat;
yl = yac - yat;

end
