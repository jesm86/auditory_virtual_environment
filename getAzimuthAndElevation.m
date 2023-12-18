function [AzimuthInDegrees, ElevationInDegrees] = getAzimuthAndElevation(sourceCoord, receiverCoord, directionFacing)
    % source and receiver are 3D coordinates [x, y, z]
    % receiverFacing is the facing direction of the receiver [x, y, z]
    % returns Elevation angle (-90,90)
    % returns Azimuth angle [0,360] in clockwise direction

    sourceReceiverVector=receiverCoord-sourceCoord;
    
    %azimuthProjection
    xDir=[1,0,0];
    yDir=[0,1,0];
    sourceReceiverAP = xDir*dot(xDir,sourceReceiverVector)+yDir*dot(yDir,sourceReceiverVector);
    directionFacingAP = xDir*dot(xDir,directionFacing)+yDir*dot(yDir,directionFacing);
    
    %azimuth angle
    AzimuthInDegrees = atan2d(sourceReceiverAP(2), sourceReceiverAP(1)) - atan2d(directionFacingAP(2), directionFacingAP(1));
    if AzimuthInDegrees < 0
        AzimuthInDegrees = AzimuthInDegrees + 360;
    end

    %elevation angle
    distanceXY = norm(sourceReceiverVector(1:2)); % Distance in the XY plane
    ElevationInRad = atan2(sourceReceiverVector(3), distanceXY);
    ElevationInDegrees=rad2deg(ElevationInRad);
end