function [hrirLeft, hrirRight] = computeFinalHrir(ReceiverCoords, SourceCoords, hrirFullSet, samplingFreq)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    facingDirection = [1, 0, 0];
    [currentElevation, CurrentAzimuth] = getElevationAndAzimuth(SourceCoords, ReceiverCoords, facingDirection);
    
    [elevationIndices(1), elevationIndices(2), azimuthIndices(1,1), azimuthIndices(1,2), azimuthIndices(1,3), azimuthIndices(1,4), elevalues, azimvalues(1,:)] = findHRIRindex(currentElevation, CurrentAzimuth);
    [~, ~, azimuthIndices(2,1), azimuthIndices(2,2), azimuthIndices(2,3), azimuthIndices(2,4), ~, azimvalues(2,:)] = findHRIRindex(currentElevation, (360 - CurrentAzimuth));       
        
    for i = 1:floor((512/(44100/samplingFreq)))
        hrirLeft(i) = interpolateN([hrirFullSet{elevationIndices(1)}{azimuthIndices(1,1)}(i), hrirFullSet{elevationIndices(1)}{azimuthIndices(1,2)}(i)],...
                                                              [hrirFullSet{elevationIndices(2)}{azimuthIndices(1,3)}(i), hrirFullSet{elevationIndices(2)}{azimuthIndices(1,4)}(i)],...
                                                              [elevalues(1), elevalues(2)],[azimvalues(1,1), azimvalues(1,2)], [azimvalues(1,3), azimvalues(1,4)], currentElevation, CurrentAzimuth);
        hrirRight(i) = interpolateN([hrirFullSet{elevationIndices(1)}{azimuthIndices(2,1)}(i), hrirFullSet{elevationIndices(1)}{azimuthIndices(2,2)}(i)],...
                                                              [hrirFullSet{elevationIndices(2)}{azimuthIndices(2,3)}(i), hrirFullSet{elevationIndices(2)}{azimuthIndices(2,4)}(i)],...
                                                              [elevalues(1), elevalues(2)],[azimvalues(2,1), azimvalues(2,2)], [azimvalues(2,3), azimvalues(2,4)], currentElevation, (360 - CurrentAzimuth));
    end 


end