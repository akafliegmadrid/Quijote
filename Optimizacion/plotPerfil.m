function [ stop ] = plotPerfil( n, in )
%PLOTPERFIL Dibuja los perfiles en 'in' (uno por fila)
%   Emplea los parametros BP3434 para representar tantos perfiles como
%   filas existan en 'in', usando 'n' paneles en total. Devuelve 'stop'
%   para ser compatible con la funcion 'fmincon'.
%
%   Participantes
%       - Andres Mateo Gabin

stop = false;

%% Se extraen los valores de 'in'
rle  = in(:,1);
xt   = in(:,2);
yt   = in(:,3);
bte  = in(:,4);
dzte = in(:,5);
yle  = in(:,6);
xc   = in(:,7);
yc   = in(:,8);
ate  = in(:,9);
zte  = in(:,10);
b0   = in(:,11);
b2   = in(:,12);
b8   = in(:,13);
b15  = in(:,14);
b17  = in(:,15);

%% Polinomios de Bezier
x = zeros(length(rle), n+1);
y = zeros(length(rle), n+1);
for i = 1: length(rle)
    [xp, yu, yl] = BP3434(n, rle(i), xt(i), yt(i), bte(i), dzte(i),    ...
                          yle(i), xc(i), yc(i), ate(i), zte(i), b0(i), ...
                          b2(i), b8(i), b15(i), b17(i));
    x(i,:) = [fliplr(xp) xp(2:end)];
    y(i,:) = [fliplr(yl) yu(2:end)];
end

%% Plots
hold off
% Todos los perfiles en linea discontinua
for i = 2: length(rle)
    plot(x(i,:), y(i,:), '-.')
    hold on
end

% Excepto el primero, que se dibuja en linea continua
plot(x(1,:), y(1,:))
axis equal
hold off

end

