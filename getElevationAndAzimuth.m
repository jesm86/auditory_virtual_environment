%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: getElevationAndAzimuth.m
%
%   Given the coordinates of source and receiver, this module calculates
%   elevation and azimuth angle.
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             19.12.23    L.Gildenstern            created
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ElevationInDegrees, AzimuthInDegrees] = getElevationAndAzimuth(sourceCoord, receiverCoord, directionFacing)
    % source and receiver are 3D coordinates [x, y, z]
    % receiverFacing is the facing direction of the receiver [x, y, z]
    % returns Elevation angle (-90,90)
    % returns Azimuth angle [0,360] in clockwise direction

    sourceReceiverVector = receiverCoord - sourceCoord;
    
    % azimuthProjection
    xDir = [1, 0, 0];
    yDir = [0, 1, 0];
    sourceReceiverAP = xDir * dot(xDir, sourceReceiverVector) + yDir * dot(yDir, sourceReceiverVector);
    directionFacingAP = xDir * dot(xDir, directionFacing) + yDir * dot(yDir, directionFacing);
    
    % azimuth angle
    AzimuthInRadians = atan2(sourceReceiverAP(2), sourceReceiverAP(1)) - atan2(directionFacingAP(2), directionFacingAP(1));
    AzimuthInDegrees = mod(rad2deg(AzimuthInRadians), 360);

    % elevation angle
    distanceXY = norm(sourceReceiverVector(1:2)); % Distance in the XY plane
    ElevationInRadians = atan2(sourceReceiverVector(3), distanceXY);
    ElevationInDegrees = rad2deg(ElevationInRadians);
end