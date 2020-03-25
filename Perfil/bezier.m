function [ Cx, Cy ] = bezier( xc, yc )
% BEZIER Calcula n puntos '(x,y)' a lo largo de la curva dada por '(xc,yc)'
%   Cx -> coeficientes del polinomio de Bezier para 'x'
%   Cy -> coeficientes del polinomio de Bezier para 'y'
%   xc -> coordenada 'x' de los puntos de control
%   yc -> coordenada 'y' de los puntos de control
%
%   Basado en el la definicion dada en Wikipedia:
%   https://en.wikipedia.org/wiki/B%C3%A9zier_curve#Polynomial_form
%
%   Participantes:
%       - Andres Mateo Gabin

% Orden del polinomio Bezier
p = length(xc)-1;

% Calculo de los puntos del polinomio
Cx = zeros(1, p+1);
Cy = zeros(1, p+1);
for j = 0: p
    for i = 0: j
        sum = (-1.0)^(i+j) / (factorial(i) * factorial(j-i));
        Cx(j+1) = Cx(j+1) + sum * xc(i+1);
        Cy(j+1) = Cy(j+1) + sum * yc(i+1);
    end
    prod    = factorial(p) / factorial(p - j);
    Cx(j+1) = Cx(j+1) * prod;
    Cy(j+1) = Cy(j+1) * prod;
end

% Se invierten los vectores para que puedan ser usados como polinomios
Cx = fliplr(Cx);
Cy = fliplr(Cy);

end
