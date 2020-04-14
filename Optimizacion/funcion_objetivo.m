function [ out ] = funcion_objetivo( nPerfil, foilname, nSecciones,  ...
                                     nPanelX, nPanelY, h, MTOM, Vcr, ...
                                     Vth, in )
% FUNCION_OBJETIVO combina linealmente los valores que se van a optimizar
%
%   Participantes:
%       - Andres Mateo Gabin

%% Extraer variables de diseño en 'in'
% Perfil
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

% Ala
bs = in(16:18);
cs = in(19:22);
fs = in(23:25);
ds = in(26:28);
ts = in(29:32);

%% Algunos parametros de la simulacion
% Numero de Mach
[rho, a, ~, mu] = ISAtmosphere(h);
Ma_cr = Vcr / a;
Ma_th = Vth / a;

% Nombres de los archivos (rutas absolutas)
wd  = fileparts(which(mfilename));
ind = strfind(wd, "/");
ind = ind(end);
wd  = wd(1:ind);
xfoilName   = [wd 'Perfil' filesep 'Xfoil' filesep ...
               foilname '_xfoil.dat'];
tornadoName = [wd 'Perfil' filesep 'Xfoil' filesep ...
               foilname '_tornado.dat'];

%% Funcion objetivo
% Carga alar
S  = 2.0 * sum( bs  .* (cs(1:end-1) + cs(2:end))/2.0 );
WS = MTOM / S * 9.81;

% Factor de eficiencia
AR = sum(bs)^2 / S;
k  = AR / (AR + 2.0) * 1.18;

% Cl del ala
CL_cr = WS / ( 0.5 * rho * Vcr^2 );
CL_th = WS / ( 0.5 * rho * Vth^2 );

% Cl del perfil
b     = 2.0 * sum(bs);
Cl_cr = CL_cr * S/b / cs(1) / k;
Cl_th = CL_th * S/b / cs(1) / k;

% Re del perfil (Cuerda en el encastre)
Re_cr = rho * Vcr * cs(1) / mu;
Re_th = rho * Vth * cs(1) / mu;

% Solucion del perfil
perfil_cr = perfil(nPerfil, xfoilName, tornadoName, rle, xt, yt, ...
                  bte, dzte, yle, xc, yc, ate, zte, b0, b2, b8, ...
                  b15, b17, Cl_cr, Re_cr, Ma_cr);
perfil_th = perfil(nPerfil, xfoilName, tornadoName, rle, xt, yt, ...
                  bte, dzte, yle, xc, yc, ate, zte, b0, b2, b8, ...
                  b15, b17, Cl_th, Re_th, Ma_th);

% Solucion del ala
if any(isempty(perfil_cr.CL)) || any(isempty(perfil_th.CL))
    
    % Funcion penalizada
    out = 100.0;
    
else

    % Caracteristicas del ala
    ala_cr = ala(nSecciones, nPanelX, nPanelY, tornadoName, ds, ts, ...
                 cs, fs, bs, Vcr, h, CL_cr, perfil_cr.alpha);
    ala_th = ala(nSecciones, nPanelX, nPanelY, tornadoName, ds, ts, ...
                 cs, fs, bs, Vth, h, CL_th, perfil_th.alpha);

    % Objetivos del perfil
    E_perfil_cr = perfil_cr.CL / perfil_cr.CD;
    E_perfil_th = perfil_th.CL / perfil_th.CD;
    trans_cr    = perfil_cr.Top_xtr;
    trans_th    = perfil_th.Top_xtr;
    
    % Objetivos del ala
    E_ala_cr = ala_cr.CL / (ala_cr.CD + ala_cr.CD0);
    E_ala_th = ala_th.CL / (ala_th.CD + ala_th.CD0);
    Mr_cr = ala_cr.MOMENTS(2);
    Mr_th = ala_th.MOMENTS(2);

    % Ponderacion final
    out = - E_perfil_cr * (1.0/30.0)  ...  % O(30)
          - E_perfil_th * (1.0/70.0)  ...  % O(70)
          - trans_cr    * (1.0)       ...  % O(1)
          - trans_th    * (1.0)       ...  % O(1)
          - E_ala_cr    * (1.0/30.0)  ...  % O(30)
          - E_ala_th    * (1.0/40.0)  ...  % O(40)
          - Mr_cr       * (1.0/40.0)  ...  % O(40)
          - Mr_th       * (1.0/200.0) ...  % O(200)
          + 10.0;                          % Valor cercano a 0

end

end
