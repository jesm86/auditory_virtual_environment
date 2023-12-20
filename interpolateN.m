function finalInterHrtf = interpolateN(Vhrtf1, Vhrtf2, eleValues, azimuthVecLEL, azimuthVecHEL,targetEleva,targetAzimtuh)
    % Interpolate with respect to the azimuVhrtf1ths in low and high elevation
    % low eleveation: interpltargetElevaVectorating the low and hiogh azimuths of the low 
% azimuthVecLEL = [5,10];
% azimuthVecHEL =[6, 12];

% ELEVATION 
    tempInterpolationLowE = interp1(azimuthVecLEL,Vhrtf1,targetAzimtuh);
        % high eleveation: interplating the low and hiogh azimuths of the
        % high
    % ELEVATION 
    tempInterpolationHighE = interp1(azimuthVecHEL,Vhrtf2,targetAzimtuh);

    tempVect =[tempInterpolationHighE,tempInterpolationLowE];

    
    finalInterHrtf = interp1( [eleValues(1), eleValues(2)], tempVect, targetEleva);
  end