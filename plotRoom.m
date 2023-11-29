function plotRoom(roomDimensions,receiverCoord,sourceCoord,figHandle)
% PLOTROOM Plot room, transmitter and receiver

figure(figHandle)
X = [0;roomDimensions(1);roomDimensions(1);0;0];
Y = [0;0;roomDimensions(2);roomDimensions(2);0];
Z = [0;0;0;0;0];
figure;
hold on;
plot3(X,Y,Z,"k","LineWidth",1.5);   % draw a square in the xy plane with z = 0
plot3(X,Y,Z+roomDimensions(3),"k","LineWidth",1.5); % draw a square in the xy plane with z = 1
set(gca,"View",[-28,35]); % set the azimuth and elevation of the plot
% Lx = roomDimensions(1);
% Ly = roomDimensions(2);
% Lz = roomDimensions(3);
% 
% xlim([-3*Lx,3*Lx]);
% ylim([-3*Ly,3*Ly]);
% zlim([-3*Lz,3*Lz]);
for k=1:length(X)-1
    plot3([X(k);X(k)],[Y(k);Y(k)],[0;roomDimensions(3)],"k","LineWidth",1.5);
end

grid on
xlabel("X (m)")
ylabel("Y (m)")
zlabel("Z (m)")
plot3(sourceCoord(1),sourceCoord(2),sourceCoord(3),"bx","LineWidth",2)

% % label = "Source-blueX";
% text(sourceCoord(1),sourceCoord(2),sourceCoord(3));
% % label = "Rec-Red";
% text(receiverCoord(1),receiverCoord(2),receiverCoord(3));
plot3(receiverCoord(1),receiverCoord(2),receiverCoord(3),"ro","LineWidth",2)
end
