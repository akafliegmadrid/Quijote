function [ x, y ] = bezier( t, xc, yc )
% BEZIER Calcula n puntos '(x,y)' a lo largo de la curva dada por '(xc,yc)'
%   x  -> coordenada 'x' de los puntos correspondientes a 't'
%   y  -> coordenada 'y' de los puntos correspondientes a 't'
%   t  -> posiciones donde se calculan '(x,y)', entre [0,1]
%   xc -> coordenada 'x' de los puntos de control
%   yc -> coordenada 'y' de los puntos de control
%
%   Basado en el la definicion dada en Wikipedia:
%   https://en.wikipedia.org/wiki/B%C3%A9zier_curve#Explicit_definition
%
%   Participantes:
%       - Andres Mateo Gabin

% Orden del polinomio Bezier
p = length(xc)-1;

% Calculo del polinomio
x = zeros('like', t);
y = zeros('like', t);
for i = 0: p
    C = nchoosek(p,i);
    x = x + C * (1-t).^(p-i) .* t.^i * xc(i+1);
    y = y + C * (1-t).^(p-i) .* t.^i * yc(i+1);
end

end
