function [ bp3434params ] = perfilBP3434( )
clear
close all
clc

%% Parametros
% Perfil a convertir a BP3434
filename = 'FX_S_02_196.dat';
nPuntos  = 100;

% Valores iniciales
rle  = 0.041231;  % [c^-1]
xt   = 0.383689;  % [c^-1]
yt   = 0.171271;  % [c^-1]
bte  = 10.313873;  % [deg]
dzte = 0.000334;  % [c^-1]
yle  = 5.294366;  % [deg]
xc   = 0.576906;  % [c^-1]
yc   = 0.046107;  % [c^-1]
ate  = 9.812179;  % [deg]
zte  = 0.000744;  % [c^-1]
b0   = -0.012642;  % [c^-1]
b2   = 0.126858;  % [c^-1]
b8   = 0.070114;  % [c^-1]
b15  = 0.748244;  % [c^-1]
b17  = 0.629577;  % [c^-1]

%% Setup
% Degrees to radians
bte = deg2rad(bte);
yle = deg2rad(yle);
ate = deg2rad(ate);

% Initial state vector
x0 = [rle xt yt bte dzte yle xc yc ate zte b0 b2 b8 b15 b17];

% Se cargan los puntos
pts = load(filename);
nu  = pts(1,1);
xfu = pts(2:nu+1,1);   yfu = pts(2:nu+1,2);
xfl = pts(nu+2:end,1); yfl = pts(nu+2:end,2);

% Paso inicial
[xp,ypu,ypl] = BP3434(nPuntos, rle, xt, yt, bte, dzte, yle, ...
                      xc, yc, ate, zte, b0, b2, b8, b15, b17);
                  
% Y plot inicial
xf = [xfu; flipud(xfl)];
yf = [yfu; flipud(yfl)];

hold on;
plot([xp fliplr(xp)], [ypu fliplr(ypl)],  'b');
plot(xf, yf, 'r');
legend('Perfil inicial', 'Perfil objetivo');
hold off;
pause;
close;

%% Optimizacion
% "Binding" de la funcion a optimizar
obj       = @(x) diferencia(nPuntos, x, xfu, yfu, xfl, yfl);
pltPerFcn = @(x, optimValues, state) plotPerfil(nPuntos, x, [xf'; yf'], 1);
opt = optimoptions('fminunc',                                  ...
                   'MaxFunctionEvaluations', 1e4,              ...
                   'PlotFcn',                {'optimplotfval', ...
                                              pltPerFcn}       );

% bp3434params = fmincon(obj, x0, [], [], [], [], [], [], [], opt);
bp3434params = fminunc(obj, x0, opt);

% Plot de la solucion
figure();
plotPerfil(nPuntos, bp3434params, [xf'; yf'], 1);
legend('Perfil solucion', 'Perfil objetivo');

% Angulos a grados
bp3434params(4) = rad2deg(bp3434params(4));
bp3434params(6) = rad2deg(bp3434params(6));
bp3434params(9) = rad2deg(bp3434params(9));

% Solucion lista para copiar
printSolution(bp3434params);

end

function [ dy ] = diferencia(np, in, xfu, yfu, xfl, yfl)
% DIFERENCIA estima la diferencia entre el perfil definido por '(xfu,yfu)'
% y '(xfl,yfl)'. El error se calcula como la norma L2 de la diferencia.

% Valores en 'in'
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

% Coordenadas correspondientes a los parametros de 'in'
try
    [xp,ypu,ypl] = BP3434(np, rle, xt, yt, bte, dzte, yle, ...
                          xc, yc, ate, zte, b0, b2, b8, b15, b17);

    % Interpolacion y calculo de la diferencia
    yiu = pchip(xfu, yfu, xp);
    yil = pchip(xfl, yfl, xp);
    dy  = sum((yiu-ypu).^2 + (yil-ypl).^2);

% Cualquier error se penaliza
catch
    dy = 10.0;  % Deberia ser suficientemente grande...
end

end

function [] = printSolution(x)

fprintf('rle  = %f;  %% [c^-1]\n', x(1));
fprintf('xt   = %f;  %% [c^-1]\n', x(2));
fprintf('yt   = %f;  %% [c^-1]\n', x(3));
fprintf('bte  = %f;  %% [deg]\n',  x(4));
fprintf('dzte = %f;  %% [c^-1]\n', x(5));
fprintf('yle  = %f;  %% [deg]\n',  x(6));
fprintf('xc   = %f;  %% [c^-1]\n', x(7));
fprintf('yc   = %f;  %% [c^-1]\n', x(8));
fprintf('ate  = %f;  %% [deg]\n',  x(9));
fprintf('zte  = %f;  %% [c^-1]\n', x(10));
fprintf('b0   = %f;  %% [c^-1]\n', x(11));
fprintf('b2   = %f;  %% [c^-1]\n', x(12));
fprintf('b8   = %f;  %% [c^-1]\n', x(13));
fprintf('b15  = %f;  %% [c^-1]\n', x(14));
fprintf('b17  = %f;  %% [c^-1]\n', x(15));

end