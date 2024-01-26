%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: computeFinalHrir
%
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             18.10.23    J. Smith                       created
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% param[in]         ReceiverCoords              Coordinates of reiceiver
% param[in]         SourceCoords                 Courdinates of source
% param[in]         hrirFullSet                         Loaded set of HRIR filter
% param[in]         samplingFreq                    used sampling rate
%
% retval                [hrirLeft, hrirRight                HRIR filter pair
function [hrirLeft, hrirRight] = computeFinalHrir(ReceiverCoords, SourceCoords, hrirFullSet, samplingFreq)
    
    % Set the facing direction to x-direction and calculate elevation and
    % azimuth angles from coordinates together with facing direction
    facingDirection = [1, 0, 0];
    [currentElevation, CurrentAzimuth] = getElevationAndAzimuth(SourceCoords, ReceiverCoords, facingDirection);
    
    % Get the two elevation indices (one above and one below the actual
    % elevation angle, and the four azimuth indices (again one above one
    % bewlow for both elevations
    [elevationIndices(1), elevationIndices(2), azimuthIndices(1,1), azimuthIndices(1,2), azimuthIndices(1,3), azimuthIndices(1,4), elevalues, azimvalues(1,:)] = findHRIRindex(currentElevation, CurrentAzimuth);
    [~, ~, azimuthIndices(2,1), azimuthIndices(2,2), azimuthIndices(2,3), azimuthIndices(2,4), ~, azimvalues(2,:)] = findHRIRindex(currentElevation, (360 - CurrentAzimuth));       
    
    % interpolate the HRIR filters according to the actual angles. Take
    % the length of the provided filter (512), and the sampling frequencies
    % (44100 of the filters and "samplingFreq" of the one used in the
    % application into account for the number of samples in the final
    % interpolated HRIR result
    for i = 1:floor((512/(44100/samplingFreq)))
        hrirLeft(i) = interpolateN([hrirFullSet{elevationIndices(1)}{azimuthIndices(1,1)}(i), hrirFullSet{elevationIndices(1)}{azimuthIndices(1,2)}(i)],...
                                                              [hrirFullSet{elevationIndices(2)}{azimuthIndices(1,3)}(i), hrirFullSet{elevationIndices(2)}{azimuthIndices(1,4)}(i)],...
                                                              [elevalues(1), elevalues(2)],[azimvalues(1,1), azimvalues(1,2)], [azimvalues(1,3), azimvalues(1,4)], currentElevation, CurrentAzimuth);
        hrirRight(i) = interpolateN([hrirFullSet{elevationIndices(1)}{azimuthIndices(2,1)}(i), hrirFullSet{elevationIndices(1)}{azimuthIndices(2,2)}(i)],...
                                                              [hrirFullSet{elevationIndices(2)}{azimuthIndices(2,3)}(i), hrirFullSet{elevationIndices(2)}{azimuthIndices(2,4)}(i)],...
                                                              [elevalues(1), elevalues(2)],[azimvalues(2,1), azimvalues(2,2)], [azimvalues(2,3), azimvalues(2,4)], currentElevation, (360 - CurrentAzimuth));
    end 


end