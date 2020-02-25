function[ CL, CD ] = ala (d_q, t_q, c_q, phi_q, b_q)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALA calcula las propiedades del ala a partir de la geometria
%
%   Participantes:
%       - Andres Mateo Gabin
%       - Alesander Oteo Torres

% Variables para definir la geometria :
% d_q   -> diedro entre quiebros desde el encastre, np componentes
% t_q   -> torsion en cada quiebro desde el q0,np+1 componentes
% c_q   -> cuerda en cada quiebro, np+1 componentes
% phi_q -> flecha 1/4 de los quiebros desde el encastre, np componentes
% b_q   -> longitud de cada quiebro, np componentes

% NOTA: para evitar confusiones, el 1 siempre hará referencia al encastre o
% al primer quiebro. si el ala tiene 3 quiebros, el c_q(1) será la cuerda
% en el encastre, y el b_q(1) será lo que mide el primer quiebro, es decir,
% desde c_q(1) hasta c_q(2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Numero de paneles
np = 3;           % no. de quiebros
nx = 10;          % direccion de la cuerda
ny = [40 20 10];  % direccion de la envergadura

% Punto de referencia
xRef = 0.25 * c_q(1)
yRef = 0.0
zRef = 0.0

% Centro de masas
% TODO: calcularlo en funcion de la forma de las alas
xCG = xRef
yCG = yRef
zCG = zRef

% Estrechamientos
taperRatio = c_q(2:end) / c_q(1:end-1)

% Structs iniciales para las funciones de Tornado
geo.meshtype  = ones(1,np);
latticetype   = 1;                 % Standard horseshoe lattice
geo.symetric  = 1;                 % 1: Ala entera,
geo.nwing     = 1;                 % Numero de alas
geo.nelem     = np;                % Numero de particiones del ala
geo.ref_point = [xRef yRef zRef];  % Punto de referencia
geo.CG        = [xCG yCG zCG];     % Centro de gravedad del avion 
geo.c         = c_q(1);            % Cuerda encastre
geo.b         = b_q;               % Semienvergaduras del ala
geo.startx    = 0.0;               % Poiscion segun X del BA del perfil central
geo.starty    = 0.0;               % Posicion segun Y "..."
geo.startz    = 0.0;               % Posicion segun Z "..."
geo.dihed     = d_q;               % Diedro total ala
geo.T = taperRatio;                % Estrechamiento ala
geo.SW = phi_q;                    % Flecha ala
geo.TW(:,:,1) = t_q(1:end-1);      % TODO: por que hay dos dimensiones? 
geo.TW(:,:,2) = t_q(2:end);
geo.nx = nx*ones(1,np);            % No. de paneles en la direccion X
geo.ny = ny;                       % No. de paneles en la direccion Y

geo.flapped = zeros(1,np);         % No se utilizan flaps
geo.fsym = zeros(1,np);            % '...'
geo.fnx = zeros(1,np);             % '...'
geo.fc = zeros(1,np);              % '...'
geo.flap_vector= zeros(1,np);      % '...'

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
[CL, CD] = solverloop5(results, state, geo, Alpha);

%Calculo de la resistencia total
CD = CD + sum(CD0_wing);

end function
