function [sourceCoord,receiverCoord] = circularMovement(roomDimensions,Fs,samples)

sourceCoord = zeros(samples,3);
receiverCoord = zeros(samples,3);

% place receiver in the middle of the room
receiverCoord(:,1)=roomDimensions(1)/2;
receiverCoord(:,2)=roomDimensions(2)/2;
receiverCoord(:,3)=roomDimensions(3)/2;

% set distance to halfway between receiver and closest wall
dist = roomDimensions(1)/4;
if(roomDimensions(2)/4 < dist)
    dist=roomDimensions(2)/4;
end

step = 360/(Fs*10);
angles=0:step:360;
angles=angles(1:end-1);

times=floor(samples/length(angles));
modulo=mod(samples,length(angles));

tempAngles=angles;
for t = 1:times-1
    angles=[angles,tempAngles];
end
angles=[angles,angles(1:modulo)];

% Parametric equations of a circle
sourceCoord(:,1) = receiverCoord(:,1) + dist * cos(angles');
sourceCoord(:,2) = receiverCoord(:,2) + dist * sin(angles');
sourceCoord(:,3) = receiverCoord(:,3);

end