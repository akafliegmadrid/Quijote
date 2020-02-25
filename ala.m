function[ E, V ] = ala (np, a_q, t_q, c_q, phi_q, b_q) %F[out]=nombre(in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALA calcula las propiedades del ala a partir de la geometria
%
%   Participantes:
%       - Andres Mateo Gabin
%       - Alesander Oteo Torres

% Variables para definir la geometria :
% np    -> nº de quiebros del ala
% a_q   -> diedro entre quiebros desde el encastre, np componentes
% t_q   -> torsion en cada quiebro desde el q0,np+1 componentes
% c_q   -> cuerda en cada quiebro, np+1 componentes
% phi_q -> flecha de los quiebros desde el encastre, np componentes
% b_q   -> longitud de cada quiebro, np componentes

% NOTA: para evitar confusiones, el 1 siempre hará referencia al encastre o
% al primer quiebro. si el ala tiene 3 quiebros, el c_q(1) será la cuerda
% en el encastre, y el b_q(1) será lo que mide el primer quiebro, es decir,
% desde c_q(1) hasta c_q2. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parametros iniciales geometria global

np    = 3;              % quiebros
a_q   = zeros(1,np);    %[º] diedro quiebros
t_q   = zeros(1,np+1);  %[º] torsion de cada quiebro
c_q   = ones(1,np+1);   %[m] cuerda de cada quiebro
phi_q = zeros(1,np);    %[º] flecha
b_q   = ones(1,np);     %[m] envergadura cada seccion

sx = 0.0;               % X de comienzo de las ala
sy = 0.0;               % Y de comienzo de las ala
sz = 0.0;               % Z de comienzo de las ala

F1 = 20;                 % Flecha del ala (c/4)
% D1 = 2.5;                % Diedro del ala
T1 = 0;                  % Torsion en el encastre
T2 = 0;                  % Torsion en la punta del ala

%% Calculo de variables

% Envergadura y diedro cada sección

b_total = 2*sum(b_q); %[m] envergadura total ala
b_medio = b_total/2;  %[m] semienvergadura ala

% Estrechamientos

est_total = c_q(length(c_q))/c_q(1); % estrachamiento del ala

est_q = ones(np,1); % estrechamiento de cada quiebro

for i=1,np
    
    est_q(i) = c_q(i+1)/c_q(i);
    
end

% Flecha    VER COMO DEFINIR ESTO...
phi   = zeros(1,np);
phi(1) = deg2rad(F1);
% phi(2) = atan((3.0/4.0*(C2-c_low)+b_q(1)*tand(F1))/b_q(1));
phi(3:end) = deg2rad(phi)*ones(1,np-2);


% Otros calculos previos
C1 = c_q(1);             % Cuerda en el plano de simetria
C2 = c_q(lenght(c_q));   % Cuerda en la punta del ala
b1 = b_medio;



% Structs iniciales para las funciones de Tornado

geo.meshtype  = ones(1,np);
latticetype   = 1;             % Standard horseshoe lattice
geo.symetric  = 1;             % 1: Ala entera,
geo.nwing     = 1;             % Numero de alas
geo.nelem     = np;            % Numero de particiones del ala
geo.ref_point = [0 0 0];       % Punto de referencia
geo.CG        = [0 0 0];       % Centro de gravedad del avion 
geo.c         = c_q1;          % Cuerda encastre
geo.b         = b_medio;       % Semienvergaduras del ala
geo.startx    = sx;            % Poiscion segun X del borde de ataque de la cuerda central del ala
geo.starty    = sy;            % Poiscion segun Y "..."
geo.startz    = sz;            % Poiscion segun Z "..."
% geo.dihed     = ; diedro total ala, VER COMO CALCULAR
geo.T = est_total;             % estrechamiento ala
geo.SW = phi;                  % flecha ala

% geo.TW(:,:,1) partition twist (3d array)<1 inboard, 2 outboard> revisar a
% ver que es esto... 
geo.TW(:,:,1) = [deg2rad(T1) deg2rad(T2)*ones(1,np-1)]; 
geo.TW(:,:,2) = [deg2rad(T2)*ones(1,np-1) deg2rad(a_in)];

% comprobar a ver por que los paneles tienen que ser un array 2D
geo.nx = nx*ones(1,np); % numero de paneles en eje cuerda
geo.ny = [ny(1) ones(1,np-2) ny(end)]; % numero paneles en eje ala

geo.flapped = zeros(1,np);       %No se utilizan flaps
geo.fsym = zeros(1,np);          %'...'
geo.fnx = zeros(1,np);           %'...'
geo.fc = zeros(1,np);            %'...'
geo.flap_vector= zeros(1,np);    %'...'

% poner el nombre del perfil que genere el modulo perfil
geo.foil(:,:,1)= repmat({'akm-01.dat'}, ,np);
geo.foil(:,:,2)= repmat({'akm-o1.dat'}, ,np);

% ajustar estos datos para ñas condiciones de cada analisis
state.AS =     40;        %Airspeed m/s
state.alpha =  0.05;      %Angle of attack, radians
state.betha =  0;         %Angle of sideslip, radians
state.P =      0;         %Rollrate, rad/s
state.Q =      0;         %pitchrate, rad/s
state.R =      0;         %yawrate, rad/s
state.adot =   0;         %Alpha time derivative rad/s
state.bdot =   0;         %Betha time derivative rad/s
state.ALT =    0;         %Altitude, m
state.rho =    1.225;     %Density, kg/m^3
state.pgcorr = 1;         %Apply prandtl glauert compressibility
                          %correction

% Calculo de la eficiencia maxima y el volumen
%Condiciones atmosfericas
[~, a, ~, ~] = ISAtmosphere(state.ALT);
Mach = state.AS/a;

%Mallado
[lattice, ref] = fLattice_setup2(geo, state, latticetype);

%Resistencia parasita, superficie mojada y volumen
[CD0_wing, results.Re, results.Swet, results.Vol] = zeroliftdragpred(Mach, state.ALT, geo, ref);

%Calculo de CL y CD (inducida)
Alpha = [alpha0, d_alpha, alphaf];
[CL_, CD_] = solverloop5(results, state, geo, Alpha);

%Calculo de la resistencia total
CD_ = CD_ + sum(CD0_wing);

V = sum(results.Vol(2:end));   %Volumen del winglet
E = max(CL_./CD_);             %Eficiencia maxima

%% Plots
geometryplot(lattice, geo, ref);
end function
