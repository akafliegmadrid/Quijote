function[ CL, CD, CMa ] = ala ( nSecciones, nPanelX, nPanelY, foilname, ...
                           d_q, t_q, c_q, phi_q, b_q, vinf, h, alpha )

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
% alpha -> AoA a analizar, en grados

% NOTA: para evitar confusiones, el 1 siempre hara referencia al encastre o
% al primer quiebro. si el ala tiene 3 quiebros, el c_q(1) sera la cuerda
% en el encastre, y el b_q(1) sera lo que mide el primer quiebro, es decir,
% desde c_q(1) hasta c_q(2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
taperRatio = c_q(2:end) ./ c_q(1:end-1);

% Structs iniciales para las funciones de Tornado
geo.meshtype  = ones(1,nSecciones);
latticetype   = 1;                 % Standard horseshoe lattice
geo.symetric  = 1;                 % 1: Ala entera,
geo.nwing     = 1;                 % Numero de alas
geo.nelem     = nSecciones;        % Numero de particiones del ala
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
geo.nx = nPanelX*ones(1,nSecciones);   % No. de paneles en la direccion X
geo.ny = nPanelY;                      % No. de paneles en la direccion Y

geo.flapped = zeros(1,nSecciones);     % No se utilizan flaps
geo.fsym = zeros(1,nSecciones);        % '...'
geo.fnx = zeros(1,nSecciones);         % '...'
geo.fc = zeros(1,nSecciones);          % '...'
geo.flap_vector= zeros(1,nSecciones);  % '...'

% poner el nombre del perfil que genere el modulo perfil
geo.foil(:,:,1)= repmat({foilname}, 1, nSecciones);
geo.foil(:,:,2)= repmat({foilname}, 1, nSecciones);

% Condiciones atmosfericas
[rho, a, ~, ~] = ISAtmosphere(h);
Mach = vinf/a;

% Condiciones de vuelo
state.AS     = vinf;   % Airspeed m/s
state.betha  = 0;      % Angle of sideslip, radians
state.P      = 0;      % Rollrate, rad/s
state.Q      = 0;      % pitchrate, rad/s
state.R      = 0;      % yawrate, rad/s
state.adot   = 0;      % Alpha time derivative rad/s
state.bdot   = 0;      % Betha time derivative rad/s
state.ALT    = 0;      % Altitude, m
state.rho    = rho;    % Density, kg/m^3
state.pgcorr = 0;      % Apply prandtl glauert compressibility
                       % correction

% Calculo de la eficiencia maxima

% Mallado
state.alpha = 0.0;  % No importa el valor aqui
[~, ref] = fLattice_setup2(geo, state, latticetype);

% Resistencia parasita, superficie mojada y volumen
[CD0_wing, results.Re, results.Swet, results.Vol] = zeroliftdragpred(Mach, state.ALT, geo, ref);

% Calculo de CL y CD (inducida)
% Barrido en alpha
CL  = zeros(size(alpha));
CD  = zeros(size(alpha));
CMa = zeros(size(alpha));
for i = 1: length(alpha)
    state.alpha    = alpha(i);
    [lattice, ref] = fLattice_setup2(geo, state, latticetype);
    results        = solver9(results, state, geo, lattice, ref);
    results        = coeff_create3(results, lattice, state, ref, geo);
    results.alpha_sweep(i) = state.alpha;	
    CL(i)  = results.CL;
    CD(i)  = results.CD; 
    CMa(i) = results.Cm_a;
end

% Calculo de la resistencia total
CD = CD + sum(CD0_wing);

end
