% Dirige la optimizacion de la funcion objetivo
%
% TODO
%   - ¿Uno o varios perfiles a lo largo del ala?
%
%   Participantes:
%       - Andres Mateo Gabin

close all
clear
clc

%% PARAMETROS

% Parametros de la simulacion
h          = 1000.0;          % Altura de vuelo [m]
MTOM       = 400.0;           % Masa del avion [kg]
Vcr        = 120.0;           % Velocidad de crucero [km/s]
Vth        = 80.0;            % Velocidad en termica [km/s]
nPerfil    = 200;             % Numero de paneles en el perfil
foilName   = 'Airfoil';       % Archivo con las coordenadas del perfil
bAla       = 20.0;            % Envergadura total en metros
nSecciones = 3;               % Numero de secciones del ala
nPanelX    = 3;               % No. de paneles en la direccion de la cuerda
nPanelY    = [10 5 3];        % No. de paneles en la direccion de la env.

% Parametros del perfil BP3434 (min, inicial, max)
rle  = [ 0.05 0.154220 0.2   ];  % [c^-1]
xt   = [ 0.15 0.313441 0.5   ];  % [c^-1]
yt   = [ 0.1  0.258317 0.3   ];  % [c^-1]
bte  = [ 0.0  16.28610 25.0  ];  % [deg]
dzte = [ 0.0  0.010206 0.015 ];  % [c^-1]
yle  = [ 0.0  18.75216 25.0  ];  % [deg]
xc   = [ 0.1  0.238723 0.4   ];  % [c^-1]
yc   = [ -0.1 0.041030 0.2   ];  % [c^-1]
ate  = [ 0.0  3.021284 20.0  ];  % [deg]
zte  = [ -0.1 0.001621 0.1   ];  % [c^-1]
b0   = [ 0.05 0.130598 0.2   ];  % [c^-1]
b2   = [ 0.1  0.134234 0.3   ];  % [c^-1]
b8   = [ 0.05 0.108945 0.2   ];  % [c^-1]
b15  = [ 0.4  0.592340 0.7   ];  % [c^-1]
b17  = [ 0.8  0.910983 0.97  ];  % [c^-1]

% Parametros del ala (min, inicial, max)
bs = [ 6.0  8.0  9.0; ...    % Envergadura [m]
       0.5  1.0  1.2; ...
       0.5  1.0  1.2  ];
cs = [ 0.5  0.9  1.5; ...    % Cuerda      [m]
       0.2  0.5  1.0; ...
       0.2  0.4  0.8; ...
       0.2  0.3  0.5  ];
fs = [ -4.0  -1.0  1.0; ...  % Flecha 1/4  [deg]
       -2.0   0.0  1.0; ...
        0.0   1.0  4.0  ];
ds = [ 0.0  2.0  5.0;  ...   % Diedro      [deg]
       0.0  5.0  10.0; ...
       0.0  7.0  10.0  ];
ts = [ -5.0  2.0  5.0;  ...  % Torsion     [deg]
        0.0  2.0  8.0;  ...
        0.0  2.0  10.0; ...
        0.0  2.0  10.0  ];

%% INPUTS DEL ALGORITMO

% Conversion a radianes
bte   = deg2rad(bte);
yle   = deg2rad(yle);
ate   = deg2rad(ate);
fs    = deg2rad(fs);
ds    = deg2rad(ds);
ts    = deg2rad(ts);

% Conversion a m/s
Vcr    = Vcr / 3.6;
Vth    = Vth / 3.6;

% Vector de estado
x0 = [rle(2) xt(2) yt(2) bte(2) dzte(2) yle(2) xc(2) yc(2)   ...  % Perfil
      ate(2) zte(2) b0(2) b2(2) b8(2) b15(2) b17(2)          ...  % Perfil
      bs(:,2)' cs(:,2)' fs(:,2)' ds(:,2)' ts(:,2)'];              % Ala

% Limites inferiores
lb = [rle(1) xt(1) yt(1) bte(1) dzte(1) yle(1) xc(1) yc(1)   ...  % Perfil
      ate(1) zte(1) b0(1) b2(1) b8(1) b15(1) b17(1)          ...  % Perfil
      bs(:,1)' cs(:,1)' fs(:,1)' ds(:,1)' ts(:,1)'];              % Ala

% Limites superiores
ub = [rle(3) xt(3) yt(3) bte(3) dzte(3) yle(3) xc(3) yc(3)   ...  % Perfil
      ate(3) zte(3) b0(3) b2(3) b8(3) b15(3) b17(3)          ...  % Perfil
      bs(:,3)' cs(:,3)' fs(:,3)' ds(:,3)' ts(:,3)'];              % Ala

% Restricciones lineales
[A, b, Aeq, beq] = restriccionesLin(bAla, x0);

% Handle de la funcion objetivo
obj = @(x) funcion_objetivo(nPerfil, foilName, nSecciones, nPanelX, ...
                            nPanelY, h, MTOM, Vcr, Vth, x);

% Handle de la funcion de restricciones no lineales
nonLin = @(x) restriccionesNoLin(MTOM, x);

% Opciones de la optimizacion
pltPerFcn = @(x, optimValues, state) plotPerfil(nPerfil, [x; x0], [], 1);
pltAlaFcn = @(x, optimValues, state) plotAla(nSecciones, nPanelX,  ...
                                             nPanelY, foilName, x);
algorithmOptions = optimoptions('fmincon',                         ...
                                'MaxIterations', 1000,             ...
                                'PlotFcn',       {'optimplotfval', ...
                                                  pltPerFcn,       ...
                                                  pltAlaFcn},      ...
                                'UseParallel',   false             );

%% OPTIMIZACION

% Comienzo del cronometro
tic

% Plot del perfil inicial
figure()
plotPerfil(nPerfil, x0, [], 1);
figure()
plotAla(nSecciones, nPanelX, nPanelY, foilName, x0);
pause
close all

% Optimizacion
geometry = fmincon(obj, x0, A, b, Aeq, beq, lb, ub, ...
                   nonLin, algorithmOptions);

% Fin del cronometro
toc

%% PLOTS
figure();
plotPerfil(nPerfil, [geometry; x0], [], 1)
figure()
plotAla(nSecciones, nPanelX, nPanelY, foilName, geometry);
