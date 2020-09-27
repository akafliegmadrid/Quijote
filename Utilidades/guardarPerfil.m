function [] = guardarPerfil( filename, BP3434coords, pointCoords, draw )
%GUARDARPERFIL Dibuja el perfil y lo guarda tras la confirmacion
%
%   Participantes:
%       - Andres Mateo Gabin

%% Se calculan los puntos del perfil
if size(BP3434coords) ~= 0

    rle  = BP3434coords(1);
    xt   = BP3434coords(2);
    yt   = BP3434coords(3);
    bte  = BP3434coords(4);
    dzte = BP3434coords(5);
    yle  = BP3434coords(6);
    xc   = BP3434coords(7);
    yc   = BP3434coords(8);
    ate  = BP3434coords(9);
    zte  = BP3434coords(10);
    b0   = BP3434coords(11);
    b2   = BP3434coords(12);
    b8   = BP3434coords(13);
    b15  = BP3434coords(14);
    b17  = BP3434coords(15);
    
    [xp, yu, yl] = BP3434(100, rle, xt, yt, bte, dzte,  yle, xc, yc, ...
                          ate, zte, b0, b2, b8, b15, b17);
    x = [fliplr(xp) xp(2:end)];
    y = [fliplr(yl) yu(2:end)];

elseif size(pointCoords) ~= 1
    
    x = pointCoords(:,1);
    y = pointCoords(:,2);
    
end

%% Plot del perfil y guardado en archivo
proceed = true;
if draw

    plot(x, y, 'linewidth', 1)
    axis equal

    % Ask for confirmation
    proceed = questdlg(['¿Quieres guardar el perfil en ',filename,'?'], ...
                       '','Sí', 'No', 'Sí');
    if ~strcmp(proceed, "Sí")
        proceed = false;
    end
end

if proceed
    fid = fopen(filename, 'w');
    fprintf(fid, '%9.5f  %9.5f\n', [x; y]);
    fclose(fid);
    close gcf
end