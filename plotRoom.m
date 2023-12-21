%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: plotRoom.m
%
%   This module plots the 3d room (cuboid) together with the source and
%   receiver. 
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             20.11.23    J.Smith                     based on plotImageSources.m module
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function plotRoom(roomDimensions, receiverCoord, sourceCoord, axis)

% Plot initial 3d room
X = [0; roomDimensions(1); roomDimensions(1); 0; 0];
Y = [0; 0; roomDimensions(2); roomDimensions(2); 0];
Z = [0; 0; 0; 0; 0];

hold(axis, 'on');
plot3(axis, X, Y, Z, 'k', 'LineWidth', 1.5);  
plot3(axis, X, Y, Z + roomDimensions(3), 'k', 'LineWidth', 1.5); 

Lx = roomDimensions(1);
Ly = roomDimensions(2);
Lz = roomDimensions(3);

% Extending x,y,z axis limit.
xlim(axis, [-3 * Lx, 3 * Lx]);
ylim(axis, [-3 * Ly, 3 * Ly]);
zlim(axis, [-3 * Lz, 3 * Lz]);

for k = 1:length(X) - 1
    plot3(axis, [X(k); X(k)], [Y(k); Y(k)], [0; roomDimensions(3)], 'k', 'LineWidth', 1.5);
end

grid(axis, 'on');
xlabel(axis, 'X (m)')
ylabel(axis, 'Y (m)')
zlabel(axis, 'Z (m)')

% Plot Source Cordinates.
plot3(axis, sourceCoord(1), sourceCoord(2), sourceCoord(3), 'bx', 'LineWidth', 6)
text(axis, sourceCoord(1), sourceCoord(2), sourceCoord(3), 'Source', 'FontSize', 8);

% Plot reciver cordinates.
plot3(axis, receiverCoord(1), receiverCoord(2), receiverCoord(3), 'ro', 'LineWidth', 6)
text(axis, receiverCoord(1), receiverCoord(2), receiverCoord(3), 'Receiver', 'FontSize', 8);
end


