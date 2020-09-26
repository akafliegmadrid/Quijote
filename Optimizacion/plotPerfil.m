function [ stop ] = plotPerfil( n, inBP3434, inPts, bold )
%PLOTPERFIL Dibuja los perfiles en 'in' (uno por fila)
%   Emplea los parametros BP3434 para representar tantos perfiles como
%   filas existan en 'in', usando 'n' paneles en total. Devuelve 'stop'
%   para ser compatible con la funcion 'fmincon'.
%
%   Participantes
%       - Andres Mateo Gabin

stop = false;

%% Se extraen los valores de 'in'
if size(inBP3434,1) ~= 0

    rle  = inBP3434(:,1);
    xt   = inBP3434(:,2);
    yt   = inBP3434(:,3);
    bte  = inBP3434(:,4);
    dzte = inBP3434(:,5);
    yle  = inBP3434(:,6);
    xc   = inBP3434(:,7);
    yc   = inBP3434(:,8);
    ate  = inBP3434(:,9);
    zte  = inBP3434(:,10);
    b0   = inBP3434(:,11);
    b2   = inBP3434(:,12);
    b8   = inBP3434(:,13);
    b15  = inBP3434(:,14);
    b17  = inBP3434(:,15);

%% Polinomios de Bezier
    x = zeros(length(rle), n+1);
    y = zeros(length(rle), n+1);
    for i = 1: length(rle)
        [xp, yu, yl] = BP3434(n, rle(i), xt(i), yt(i), bte(i), dzte(i),    ...
                              yle(i), xc(i), yc(i), ate(i), zte(i), b0(i), ...
                              b2(i), b8(i), b15(i), b17(i));
        x(i,:) = [fliplr(xp) xp(2:end)];
        y(i,:) = [fliplr(yl) yu(2:end)];
    end

%% Plots
    % El primer perfil se dibuja en linea continua si 'bold==1'
    hold off
    if bold == 1
        plot(x(1,:), y(1,:), 'linewidth', 1)
        hold on;
        % Todos los demas, en linea discontinua
        for i = 2: length(rle)
            plot(x(i,:), y(i,:), '-.')
            hold on
        end
    else
        % Todos en linea continua
        hold off
        for i = 1: length(rle)
            plot(x(i,:), y(i,:), 'linewidth', 1)
            hold on
        end
    end

end

% Ahora los perfiles dados como puntos
if size(inPts,1) ~= 0

    % El primero en linea continua si 'bold==2'
    if bold == 2
        plot(inPts(1,:), inPts(2,:), 'linewidth', 1)
        hold on
        % Los demas, en linea discontinua
        for i = init: size(inPts,1)/2
            plot(inPts(2*i-1,:), inPts(2*i,:), '-.')
            hold on
        end
    else
        % Todos en linea continua
        for i = 1: size(inPts,1)/2
            plot(inPts(2*i-1,:), inPts(2*i,:), 'linewidth', 1)
            hold on
        end
    end

end

% Realistic axes
axis equal
hold off
    
end
