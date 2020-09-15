function [ out ] = funcion_objetivo( modo, nPerfil, foilname,         ...
                                     nSecciones, nPanelX, nPanelY, h, ...
                                     MTOM, Vcr, Vth, in )
% FUNCION_OBJETIVO combina linealmente los valores que se van a optimizar
%
%   Participantes:
%       - Andres Mateo Gabin

%% Extraer variables de diseño en 'in'
% Perfil
if strcmp(modo, 'Completo') || strcmp(modo, 'Perfil')
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
end

% Ala
if strcmp(modo, 'Ala')
    bs = in(1:3);
    cs = in(4:7);
    fs = in(8:10);
    ds = in(11:13);
    ts = in(14:17);

elseif strcmp(modo, 'Completo')
    bs = in(16:18);
    cs = in(19:22);
    fs = in(23:25);
    ds = in(26:28);
    ts = in(29:32);
end

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

xfoilName   = [];
tornadoName = [wd 'Perfil' filesep 'Xfoil' filesep ...
               foilname '_tornado.dat'];
if strcmp(modo, 'Completo') || strcmp(modo, 'Perfil')
    xfoilName = [wd 'Perfil' filesep 'Xfoil' filesep ...
                 foilname '_xfoil.dat'];
end

%% Funcion objetivo
% Carga alar
if strcmp(modo, 'Perfil')
    WS = 42.0 * 9.81;
    S  = MTOM * 9.81 / WS;
    b  = 20.0;
    c_perfil = 1.0;
else
    S  = 2.0 * sum( bs  .* (cs(1:end-1) + cs(2:end))/2.0 );
    WS = MTOM / S * 9.81;
    b  = 2.0 * sum(bs);
    c_perfil = cs(1);
end

% Factor de eficiencia
AR = b^2 / S;
k  = AR / (AR + 2.0);

% Cl del ala
CL_cr = WS / ( 0.5 * rho * Vcr^2 );
CL_th = WS / ( 0.5 * rho * Vth^2 );

% Cl del perfil
Cl_cr = CL_cr * S/b / c_perfil / k;
Cl_th = CL_th * S/b / c_perfil / k;

% Re del perfil (Cuerda en el encastre)
Re_cr = rho * Vcr * c_perfil / mu;
Re_th = rho * Vth * c_perfil / mu;

% Inicializacion de la funcion objetivo
out = 0.0;

% Solucion del perfil
if strcmp(modo, 'Completo') || strcmp(modo, 'Perfil')

    % Archivos de coordenadas y ejecucion de Xfoil
    perfil_cr = perfil(nPerfil, xfoilName, tornadoName, rle, xt, yt, ...
                       bte, dzte, yle, xc, yc, ate, zte, b0, b2, b8, ...
                       b15, b17, Cl_cr, Re_cr, Ma_cr);
    perfil_th = perfil(nPerfil, xfoilName, tornadoName, rle, xt, yt, ...
                       bte, dzte, yle, xc, yc, ate, zte, b0, b2, b8, ...
                       b15, b17, Cl_th, Re_th, Ma_th);

    % Funcion penalizada
    if any(isempty(perfil_cr.CL)) || any(isempty(perfil_th.CL))
        out = NaN;
        return;
    end

    % Objetivos del perfil
    E_perfil_cr = perfil_cr.CL / perfil_cr.CD;
    E_perfil_th = perfil_th.CL / perfil_th.CD;
    trans_cr    = perfil_cr.Top_xtr;
    trans_th    = perfil_th.Top_xtr;

    % Funcion objetivo del perfil
    out = out - E_perfil_cr * (2.0/40.0)  ...  % O(10)
              - E_perfil_th * (1.0/100.0) ...  % O(100)
              - trans_cr    * (3.0/0.6)   ...  % O(1)
              - trans_th    * (5.0/0.6);       % O(1)

end

% Solucion del ala
if strcmp(modo, 'Completo') || strcmp(modo, 'Ala')

    % Caracteristicas del ala
    ala_cr = ala(nSecciones, nPanelX, nPanelY, tornadoName, ds, ts, ...
                 cs, fs, bs, Vcr, h, CL_cr);
    ala_th = ala(nSecciones, nPanelX, nPanelY, tornadoName, ds, ts, ...
                 cs, fs, bs, Vth, h, CL_th);

    % Objetivos del ala
    E_ala_cr = ala_cr.CL / (ala_cr.CD + ala_cr.CD0);
    E_ala_th = ala_th.CL / (ala_th.CD + ala_th.CD0);
    Mr_cr = ala_cr.MOMENTS(2);
    Mr_th = ala_th.MOMENTS(2);

    % Funcion objetivo del ala
    out = out - E_ala_cr    * (5.0/40.0)  ...  % O(10)
              - E_ala_th    * (1.0/50.0)  ...  % O(10)
              + abs(Mr_cr)  * (2.0/350.0) ...  % O(100)
              + abs(Mr_th)  * (2.0/40.0);     % O(10)

end

% Offset para obtener un valor cercano a la unidad
out = out + 10.0;

end
