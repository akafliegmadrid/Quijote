function[ CL, CD ] = ala (d_q, t_q, c_q, phi_q, b_q, vinf, h, alpha)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALA calcula las propiedades del ala a partir de la geometria
%
%   Participantes:
%       - Andres Mateo Gabin
%       - Alesander Oteo Torres

% Variables para definir la geometria:
% d_q   -> diedro entre quiebros desde el encastre, NSECCIONES componentes
% t_q   -> torsion en cada quiebro desde el q0, NSECCIONES+1 componentes
% c_q   -> cuerda en cada quiebro, NSECCIONES+1 componentes
% phi_q -> flecha 1/4 de los quiebros desde el encastre, NSECCIONES comps.
% b_q   -> longitud de cada quiebro, NSECCIONES componentes

% Variables para definir las condiciones de vuelo:
% vinf  -> velocidad de vuelo en m/s
% h     -> altitud de vuelo en m
% alpha -> rango de AoA a analizar [min delta max] en grados

% NOTA: para evitar confusiones, el 1 siempre hara referencia al encastre o
% al primer quiebro. si el ala tiene 3 quiebros, el c_q(1) sera la cuerda
% en el encastre, y el b_q(1) sera lo que mide el primer quiebro, es decir,
% desde c_q(1) hasta c_q(2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parametros globales
global NSECCIONES NPANELX NPANELY

% Punto de referencia
xRef = 0.25 * c_q(1);
yRef = 0.0;
zRef = 0.0;

% Centro de masas
% TODO: calcularlo en funcion de la forma de las alas
xCG = xRef;
yCG = yRef;
zCG = zRef;

% Estrechamientos
taperRatio = c_q(2:end) / c_q(1:end-1);

% Structs iniciales para las funciones de Tornado
geo.meshtype  = ones(1,NSECCIONES);
latticetype   = 1;                 % Standard horseshoe lattice
geo.symetric  = 1;                 % 1: Ala entera,
geo.nwing     = 1;                 % Numero de alas
geo.nelem     = NSECCIONES;        % Numero de particiones del ala
geo.ref_point = [xRef yRef zRef];  % Punto de referencia
geo.CG        = [xCG yCG zCG];     % Centro de gravedad del avion 
geo.c         = c_q(1);            % Cuerda encastre
geo.b         = b_q;               % Semienvergaduras del ala
geo.startx    = 0.0;               % Posicion segun X del BA del encastre
geo.starty    = 0.0;               % Posicion segun Y "..."
geo.startz    = 0.0;               % Posicion segun Z "..."
geo.dihed     = d_q;               % Diedro total ala
geo.T = taperRatio;                % Estrechamiento ala
geo.SW = phi_q;                    % Flecha ala
geo.TW(:,:,1) = t_q(1:end-1);      % TODO: por que hay dos dimensiones? 
geo.TW(:,:,2) = t_q(2:end);
geo.nx = NPANELX*ones(1,NSECCIONES);   % No. de paneles en la direccion X
geo.ny = NPANELY;                      % No. de paneles en la direccion Y

geo.flapped = zeros(1,NSECCIONES);     % No se utilizan flaps
geo.fsym = zeros(1,NSECCIONES);        % '...'
geo.fnx = zeros(1,NSECCIONES);         % '...'
geo.fc = zeros(1,NSECCIONES);          % '...'
geo.flap_vector= zeros(1,NSECCIONES);  % '...'

% poner el nombre del perfil que genere el modulo perfil
geo.foil(:,:,1)= repmat({'akm-01.dat'}, 1, NSECCIONES);
geo.foil(:,:,2)= repmat({'akm-01.dat'}, 1, NSECCIONES);

% Condiciones atmosfericas
[rho, a, ~, ~] = ISAtmosphere(h);
Mach = vinf/a;

% Condiciones de vuelo
alpha    = deg2rad(alpha);
alphaAvg = (alpha(1)+alpha(3)) / 2.0;

state.AS     = vinf;      % Airspeed m/s
state.alpha  = alphaAvg;  % Angle of attack, radians
state.betha  = 0;         % Angle of sideslip, radians
state.P      = 0;         % Rollrate, rad/s
state.Q      = 0;         % pitchrate, rad/s
state.R      = 0;         % yawrate, rad/s
state.adot   = 0;         % Alpha time derivative rad/s
state.bdot   = 0;         % Betha time derivative rad/s
state.ALT    = 0;         % Altitude, m
state.rho    = rho;       % Density, kg/m^3
state.pgcorr = 0;         % Apply prandtl glauert compressibility
                          % correction

% Calculo de la eficiencia maxima

% Mallado
[~, ref] = fLattice_setup2(geo, state, latticetype);

% Resistencia parasita, superficie mojada y volumen
[CD0_wing, results.Re, results.Swet, results.Vol] = zeroliftdragpred(Mach, state.ALT, geo, ref);

% Calculo de CL y CD (inducida)
[CL, CD] = solverloop5(results, state, geo, alpha);

% Calculo de la resistencia total
CD = CD + sum(CD0_wing);

end
