%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: interpolateN.m
%
%   Function to perform interpolation between four points (azimuth pair
%   in lower elevation level + azimuth pair on uper elevation level).
%   Interpolation is first performed in the between both azimuth pairs on
%   the same elevation leval. The two results are then interpolated with
%   respect to the two elevation levels.
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             19.12.23    T.Warnak, J. Smith    created
%   1.1             20.12.23    J.Smith                      fix (catch non-unique sample points error)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   param[in]       Vhrtf1                  HRIR pair corresponding to lower elevation 
%   param[in]       Vhrtf2                  HRIR pair corresponding to upper elevation 
%   param[in]       eleValues            elevation boundaries between which we interpolate
%   param[in]       azimuthVecLEL   azimuth pair of lower elevation, between we interpolate
%   param[in]       azimuthVecHEL  azimuth pair of upper elevation, between we interpolate
%   param[in]       targetEleva         actual elevation angle (query point)
%   param[in]       targetAzimuth     actual azimuth angle (query point)

function finalInterHrtf = interpolateN(Vhrtf1, Vhrtf2, eleValues, azimuthVecLEL, azimuthVecHEL,targetEleva,targetAzimtuh)
    % interpolation between azimuth pair on lower elevation level
    if azimuthVecLEL(1) ~= azimuthVecLEL(2)
        tempInterpolationLowE = interp1(azimuthVecLEL,Vhrtf1,targetAzimtuh);
    else
        tempInterpolationLowE = Vhrtf1(1);
    end
           
    % interpolation between azimuth pair on upper elevation level
    if azimuthVecHEL(1) ~= azimuthVecHEL(2)
        tempInterpolationHighE = interp1(azimuthVecHEL,Vhrtf2,targetAzimtuh);
    else
        tempInterpolationHighE = Vhrtf2(1);
    end
    
    % combine both azimuth interpolations
    tempVect =[tempInterpolationHighE,tempInterpolationLowE];
    
    % interpolation between elevation levels
    if eleValues(1) ~= eleValues(2)
        finalInterHrtf = interp1( eleValues, tempVect, targetEleva);
    else
        finalInterHrtf = tempVect(1);
    end
end