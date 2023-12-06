%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: plotImageSources.m
%
%   This module plots rendered image sources in a 3d plot.  Depending on
%   the last boolean parameter, plotting of raytraces from all image
%   sources to the receiver can be enabled.
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             26.11.23    T.Warnakulasooriya    created
%   1.1             05.12.23    J.Smith                       comments added
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   param[in]       roomDimensions  Dimensions of the room for rendering [x, y, z] in m
%   param[in]       receiverCoord       Coordinates of receiver in room [x, y, z] in m
%   param[in]       sourceCoord         Coordinates of sound source in room [x, y, z] in mndering walls 
%   param[in]       isourceCoord        Coordinates of rendered image sources
%   param[in]       RaytraceOn          Boolean to enable or disable the rays from image sources to receiver
%
%   retval             fig                          3d plot of initial room, source, receiver and image sources

function fig = plotImageSources(roomDimensions, receiverCoord, sourceCoord, isourceCoord, RaytraceOn)


fig = figure;

% Plot initial 3d room
X = [0; roomDimensions(1); roomDimensions(1); 0; 0];
Y = [0; 0; roomDimensions(2); roomDimensions(2); 0];
Z = [0; 0; 0; 0; 0];

hold on;
plot3(X, Y, Z, 'k', 'LineWidth', 1.5);  
plot3(X, Y, Z + roomDimensions(3), 'k', 'LineWidth', 1.5); 

% Set initial the azimuth and elevation of the plot
set(gca, 'View', [-28, 35]); 
Lx = roomDimensions(1);
Ly = roomDimensions(2);
Lz = roomDimensions(3);

% Extending x,y,z axis limit.
xlim([-3 * Lx, 3 * Lx]);
ylim([-3 * Ly, 3 * Ly]);
zlim([-3 * Lz, 3 * Lz]);

for k = 1:length(X) - 1
    plot3([X(k); X(k)], [Y(k); Y(k)], [0; roomDimensions(3)], 'k', 'LineWidth', 1.5);
end

grid on
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')

% Plot Source Cordinates.
plot3(sourceCoord(1), sourceCoord(2), sourceCoord(3), 'bx', 'LineWidth', 6)
text(sourceCoord(1), sourceCoord(2), sourceCoord(3), 'Source', 'FontSize', 8);

% Plot reciver cordinates.
plot3(receiverCoord(1), receiverCoord(2), receiverCoord(3), 'ro', 'LineWidth', 6)
text(receiverCoord(1), receiverCoord(2), receiverCoord(3), 'Receiver', 'FontSize', 8);

% Plot the 3D vectors specified by isourceCoord
scatter3(isourceCoord(:, 1), isourceCoord(:, 2), isourceCoord(:, 3), 'r', 'filled');

% Connect isourceCoord to receiverCoord if RaytraceOn is true
if RaytraceOn
    for i = 1:size(isourceCoord, 1)
        plot3([receiverCoord(1), isourceCoord(i, 1)], ...
            [receiverCoord(2), isourceCoord(i, 2)], ...
            [receiverCoord(3), isourceCoord(i, 3)], 'g--');
    end
end

% Additional customization if needed
title('Image Sources Plot');
%legend('Room', 'Source', 'Receiver', 'Image Sources');
end
