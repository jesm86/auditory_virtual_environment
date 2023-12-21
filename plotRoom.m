function plotRoom(roomDimensions, receiverCoord, sourceCoord, axis)

% Plot initial 3d room
X = [0; roomDimensions(1); roomDimensions(1); 0; 0];
Y = [0; 0; roomDimensions(2); roomDimensions(2); 0];
Z = [0; 0; 0; 0; 0];

hold(axis, 'on');
plot3(axis, X, Y, Z, 'k', 'LineWidth', 1.5);  
plot3(axis, X, Y, Z + roomDimensions(3), 'k', 'LineWidth', 1.5); 

% Set initial the azimuth and elevation of the plot
%set(axis, gca, 'View', [-28, 35]);
 %view(axis, [-28, 35]); 

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


