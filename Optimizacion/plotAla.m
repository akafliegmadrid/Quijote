function [ stop ] = plotAla( nSecciones, nPanelX, nPanelY, foilname, in )
%PLOTALA Dibuja las tres vistas del ala definida en 'in'
%   Divide el ala en 'nSecciones' secciones, usando 'nPanelX' paneles a lo
%   largo de la cuerda y 'nPanelY' paneles a lo largo de la envergadura.
%   'foilName' es el nombre del archivo donde se define el perfil del ala
%
%   Participantes:
%       - Andres Mateo Gabin

stop = false;

%% Se extraen las variables del ala
b_q   = in(16:18);
c_q   = in(19:22);
phi_q = in(23:25);
d_q   = in(26:28);
t_q   = in(29:32);

%% Parametros del ala y malla
% Archivo del perfil
tornadoName = [pwd filesep 'Perfil' filesep 'Xfoil' filesep ...
               foilname '_tornado.dat'];

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
geo.foil(:,:,1)= repmat({tornadoName}, 1, nSecciones);
geo.foil(:,:,2)= repmat({tornadoName}, 1, nSecciones);

% Condiciones de vuelo
state.AS     = 1.0;    % Airspeed m/s
state.alpha  = 0.0;    % 
state.betha  = 0;      % Angle of sideslip, radians
state.P      = 0;      % Rollrate, rad/s
state.Q      = 0;      % pitchrate, rad/s
state.R      = 0;      % yawrate, rad/s
state.adot   = 0;      % Alpha time derivative rad/s
state.bdot   = 0;      % Betha time derivative rad/s
state.ALT    = 0;      % Altitude, m
state.rho    = 1.0;    % Density, kg/m^3
state.pgcorr = 0;      % Apply prandtl glauert compressibility
                       % correction

% Malla
[lattice, ref] = fLattice_setup2(geo, state, latticetype);

%% Plots
hold off
% subplot(2,2,1);
    h2=plot3(lattice.XYZ(:,:,1)',lattice.XYZ(:,:,2)',lattice.XYZ(:,:,3)','k');
%     set(gca,'Position',[0.05 0.55 0.40 0.40]);
    axis equal,hold on,axis off, view([0 0]);
    title('Side')
    grid on
    h=line([ref.mac_pos(1) ref.mac_pos(1)+ref.C_mac],[ref.mac_pos(2) ref.mac_pos(2)],[ref.mac_pos(3) ref.mac_pos(3)]);
    set(h,'LineWidth',5);
    a=plot3(geo.ref_point(1),geo.ref_point(2),geo.ref_point(3),'r+');
    set(a,'MarkerSize',15);
    a=plot3(geo.ref_point(1),geo.ref_point(2),geo.ref_point(3),'ro');
    set(a,'MarkerSize',15);
  
% subplot(2,2,2);
%     h2=plot3(lattice.XYZ(:,:,1)',lattice.XYZ(:,:,2)',lattice.XYZ(:,:,3)','k');
%     set(gca,'Position',[0.55 0.55 0.40 0.40]);
%     axis equal,hold on,axis off,view([-90 0]);
%     title('Front')
%     grid on
%     h=line([ref.mac_pos(1) ref.mac_pos(1)+ref.C_mac],[ref.mac_pos(2) ref.mac_pos(2)],[ref.mac_pos(3) ref.mac_pos(3)]);
%     set(h,'LineWidth',5);
%     a=plot3(geo.ref_point(1),geo.ref_point(2),geo.ref_point(3),'r+');
%     set(a,'MarkerSize',15);
%     a=plot3(geo.ref_point(1),geo.ref_point(2),geo.ref_point(3),'ro');
%     set(a,'MarkerSize',15);
% 
% subplot(2,2,3)
%     h2=plot3(lattice.XYZ(:,:,1)',lattice.XYZ(:,:,2)',lattice.XYZ(:,:,3)','k');
%     set(gca,'Position',[0.025 0.025 0.45 0.45]);
%     axis equal,hold on,axis off,view([0 90]);
%     title('Top')
%     grid on
%     h=line([ref.mac_pos(1) ref.mac_pos(1)+ref.C_mac],[ref.mac_pos(2) ref.mac_pos(2)],[ref.mac_pos(3) ref.mac_pos(3)]);
%     set(h,'LineWidth',5);
%     a=plot3(geo.ref_point(1),geo.ref_point(2),geo.ref_point(3),'r+');
%     set(a,'MarkerSize',15);
%     a=plot3(geo.ref_point(1),geo.ref_point(2),geo.ref_point(3),'ro');
%     set(a,'MarkerSize',15);
% 
% subplot(2,2,4)
%     h2=plot3(lattice.XYZ(:,:,1)',lattice.XYZ(:,:,2)',lattice.XYZ(:,:,3)','k');
%     set(gca,'Position',[0.525 0.025 0.45 0.45]);
%     axis equal,hold on, axis off,view([45 45]);
%     title('ISO')
%     grid on
%     h=line([ref.mac_pos(1) ref.mac_pos(1)+ref.C_mac],[ref.mac_pos(2) ref.mac_pos(2)],[ref.mac_pos(3) ref.mac_pos(3)]);
%     set(h,'LineWidth',5);
%     a=plot3(geo.ref_point(1),geo.ref_point(2),geo.ref_point(3),'r+');
%     set(a,'MarkerSize',15);
%     a=plot3(geo.ref_point(1),geo.ref_point(2),geo.ref_point(3),'ro');
%     set(a,'MarkerSize',15);

end