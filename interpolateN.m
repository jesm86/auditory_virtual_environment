function finalInterHrtf = interpolateN(Vhrtf1, Vhrtf2, eleValues, azimuthVecLEL, azimuthVecHEL,targetEleva,targetAzimtuh)
    % Interpolate with respect to the azimuVhrtf1ths in low and high elevation
    % low eleveation: interpltargetElevaVectorating the low and hiogh azimuths of the low 
% azimuthVecLEL = [5,10];
% azimuthVecHEL =[6, 12];

% ELEVATION 
if azimuthVecLEL(1) ~= azimuthVecLEL(2)
    tempInterpolationLowE = interp1(azimuthVecLEL,Vhrtf1,targetAzimtuh);
else
    tempInterpolationLowE = Vhrtf1(1);
end
        % high eleveation: interplating the low and hiogh azimuths of the
        % high
    % ELEVATION 
    if azimuthVecHEL(1) ~= azimuthVecHEL(2)
        tempInterpolationHighE = interp1(azimuthVecHEL,Vhrtf2,targetAzimtuh);
    else
        tempInterpolationHighE = Vhrtf2(1);
    end
    
    tempVect =[tempInterpolationHighE,tempInterpolationLowE];

    if eleValues(1) ~= eleValues(2)
        finalInterHrtf = interp1( [eleValues(1), eleValues(2)], tempVect, targetEleva);
    else
        finalInterHrtf = tempVect(1);
    end
  end