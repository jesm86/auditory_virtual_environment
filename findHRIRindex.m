%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: findHRIRindex.m
%
%   Given an elevation and azimuth angle, this function calculates the
%   necessary indices for accessing the correct HRIR by MIT corresponding to the actual values.
%   When the fullset of HRIR is read and saved into the matlab project, the
%   ordering will always be the same. Since Matlab ordered the folders
%   according to their folder name ("-" is put in front of numeric
%   symbols), the ordering and indexing will be as follows (w.r.t. the elevation): -10,
%   -20, -30, -40, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90.
%   With increasing absolute value of the elevation, the azimuth step size,
%   for which HRIR are provided increases. A special case is the absolut
%   azimuth value of 40. The stepsize is alternating between 6 und 7. This
%   problem has been solved by hardcoding the indices in these cases and
%   then comparing inside a while loop. In the end the indices and the
%   interval bounderies where the actual elevation and azimuth lies in are
%   returned. Naming convention: lEhAindex: low Elevation high Azimuth
%   index in the saved HRIRset. The naming may be subject to later changes.
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             19.12.23    J.Smith                      initial version  
%   1.1             20.11.23    J.Smith                      added missing assignments inside loops
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [lEindex, hEindex, lElAindex, lEhAindex, hElAindex, hEhAindex, eValues, aValues] = findHRIRindex(elevation, azimuth)
    % Elevation indexing
    if (-40 >= elevation)
        azimuthPattern = [0, 6, 13, 19, 26, 32, 39, 45, 51, 58, 64, 71, 77, 84, 90, ...
                                    96, 103, 109, 116, 122, 129, 135, 141, 148, 154, 161, 167, ...
                                    174, 180, 186, 193, 199, 206, 212, 219, 225, 231, 238, 244, ...
                                    251, 257, 264, 270, 276, 283, 289, 296, 304, 309, 315, 321, ...
                                    328, 334, 341, 347, 354];        
        lEindex = 4;
        hEindex = 4;
        
        if azimuth >= azimuthPattern(end)
            lElAindex = length(azimuthPattern);
            lEhAindex = length(azimuthPattern);
            hElAindex = length(azimuthPattern);  
            hEhAindex = length(azimuthPattern);  
            aValues(1) = 354;
            aValues(2) = 354;
            aValues(3) = 345;
            aValues(4) = 345;
        else
            for index = 1:length(azimuthPattern)-1
                if (azimuth >= azimuthPattern(index)) && (azimuth < azimuthPattern(index + 1))
                    lElAindex = index;
                    lEhAindex = index + 1;
                    hElAindex = index;
                    hEhAindex = index + 1;
                    aValues(1) = azimuthPattern(index);
                    aValues(2) = azimuthPattern(index+1);
                    aValues(3) = aValues(1);
                    aValues(4) = aValues(2);
                    break; 
                end
            end
        end

        eValues(1) = -40;
        eValues(2) = -40;

    elseif ((-40 < elevation) && (-30 >= elevation))
        azimuthPattern = [0, 6, 13, 19, 26, 32, 39, 45, 51, 58, 64, 71, 77, 84, 90, ...
                                    96, 103, 109, 116, 122, 129, 135, 141, 148, 154, 161, 167, ...
                                    174, 180, 186, 193, 199, 206, 212, 219, 225, 231, 238, 244, ...
                                    251, 257, 264, 270, 276, 283, 289, 296, 304, 309, 315, 321, ...
                                    328, 334, 341, 347, 354];        
        lEindex = 4;
        hEindex = 3;
        
        if azimuth >= azimuthPattern(end)
            lElAindex = length(azimuthPattern);
            lEhAindex = length(azimuthPattern);
            aValues(1) = 354;
            aValues(2) = 354;
        else
            for index = 1:length(azimuthPattern)-1
                if (azimuth >= azimuthPattern(index)) && (azimuth < azimuthPattern(index + 1))
                    lElAindex = index;
                    lEhAindex = index + 1;
                    aValues(1) = azimuthPattern(index);
                    aValues(2) = azimuthPattern(index+1);
                    break; 
                end
            end
        end

        hElAindex = floor(azimuth / 6) + 1;
        hEhAindex = hElAindex + 1;
        eValues(1) = -40;
        eValues(2) = -30;
        aValues(3) = (hElAindex - 1) * 6;
        aValues(4) = hElAindex * 6;

    elseif ((-30 < elevation) && (-20 >= elevation))
        lEindex = 3;
        hEindex = 2;
        lElAindex = floor(azimuth / 6) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = floor(azimuth / 5) + 1;
        hEhAindex = hElAindex + 1;

        eValues(1) = -30;
        eValues(2) = -20;
        aValues(1) = (lElAindex - 1) * 6;
        aValues(2) = lElAindex * 6;
        aValues(3) = (hElAindex - 1) * 5;
        aValues(4) = hElAindex * 5;
    elseif ((-20 < elevation) && (-10 >= elevation))
        lEindex = 2;
        hEindex = 1;
        lElAindex = floor(azimuth / 5) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = lElAindex;
        hEhAindex = lEhAindex;

        eValues(1) = -20;
        eValues(2) = -10;
        aValues(1) = (lElAindex - 1) * 5;
        aValues(2) = lElAindex * 5;
        aValues(3) = (hElAindex - 1) * 5;
        aValues(4) = hElAindex * 5;
    elseif ((-10 < elevation) && (0 >= elevation))
        lEindex = 1;
        hEindex = 5;
        lElAindex = floor(azimuth / 5) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = lElAindex;
        hEhAindex = lEhAindex;
        eValues(1) = -10;
        eValues(2) = 0;
        aValues(1) = (lElAindex - 1) * 5;
        aValues(2) = lElAindex * 5;
        aValues(3) = (hElAindex - 1) * 5;
        aValues(4) = hElAindex * 5;
    elseif ((0 < elevation) && (10 >= elevation))
        lEindex = 5;
        hEindex = 6;
        lElAindex = floor(azimuth / 5) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = lElAindex;
        hEhAindex = lEhAindex;

        eValues(1) = 0;
        eValues(2) = 10;
        aValues(1) = (lElAindex - 1) * 5;
        aValues(2) = lElAindex * 5;
        aValues(3) = (hElAindex - 1) * 5;
        aValues(4) = hElAindex * 5;
    elseif ((10 < elevation) && (20 >= elevation))
        lEindex = 6;
        hEindex = 7;
        lElAindex = floor(azimuth / 5) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = lElAindex;
        hEhAindex = lEhAindex;

        eValues(1) = 10;
        eValues(2) = 20;
        aValues(1) = (lElAindex - 1) * 5;
        aValues(2) = lElAindex * 5;
        aValues(3) = (hElAindex - 1) * 5;
        aValues(4) = hElAindex * 5;
    elseif ((20 < elevation) && (30 >= elevation))
        lEindex = 7;
        hEindex = 8;
        lElAindex = floor(azimuth / 5) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = floor(azimuth / 6) + 1;
        hEhAindex = hElAindex + 1;

        eValues(1) = 20;
        eValues(2) = 30;
        aValues(1) = (lElAindex - 1) * 5;
        aValues(2) = lElAindex * 5;
        aValues(3) = (hElAindex - 1) * 6;
        aValues(4) = hElAindex * 6;
    elseif ((30 < elevation) && (40 >= elevation))
        azimuthPattern = [0, 6, 13, 19, 26, 32, 39, 45, 51, 58, 64, 71, 77, 84, 90, ...
                                    96, 103, 109, 116, 122, 129, 135, 141, 148, 154, 161, 167, ...
                                    174, 180, 186, 193, 199, 206, 212, 219, 225, 231, 238, 244, ...
                                    251, 257, 264, 270, 276, 283, 289, 296, 304, 309, 315, 321, ...
                                    328, 334, 341, 347, 354];
        lEindex = 8;
        hEindex = 9;
        lElAindex = floor(azimuth / 6) + 1;
        lEhAindex = lElAindex + 1;
        
        if azimuth >= azimuthPattern(end)
            hElAindex = length(azimuthPattern);
            hEhAindex = length(azimuthPattern);
            aValues(3) = 354;
            aValues(4) = 354;
        else
            for index = 1:length(azimuthPattern)-1
                if (azimuth >= azimuthPattern(index)) && (azimuth < azimuthPattern(index + 1))
                    hElAindex = index;
                    hEhAindex = index + 1;
                    aValues(3) = azimuthPattern(index);
                    aValues(4) = azimuthPattern(index+1);
                    break; 
                end
            end
        end

        eValues(1) = 30;
        eValues(2) = 40;
        aValues(1) = (lElAindex - 1) * 6;
        aValues(2) = lElAindex * 6;
    elseif ((40 < elevation) && (50 >= elevation))
        azimuthPattern = [0, 6, 13, 19, 26, 32, 39, 45, 51, 58, 64, 71, 77, 84, 90, ...
                                    96, 103, 109, 116, 122, 129, 135, 141, 148, 154, 161, 167, ...
                                    174, 180, 186, 193, 199, 206, 212, 219, 225, 231, 238, 244, ...
                                    251, 257, 264, 270, 276, 283, 289, 296, 304, 309, 315, 321, ...
                                    328, 334, 341, 347, 354];
        lEindex = 9;
        hEindex = 10;
        
        if azimuth >= azimuthPattern(end)
            lElAindex = length(azimuthPattern);
            lEhAindex = length(azimuthPattern);
            aValues(1) = 354;
            aValues(2) = 354;
        else
            for index = 1:length(azimuthPattern)-1
                if (azimuth >= azimuthPattern(index)) && (azimuth < azimuthPattern(index + 1))
                    lElAindex = index;
                    lEhAindex = index + 1;
                    aValues(1) = azimuthPattern(index);
                    aValues(2) = azimuthPattern(index+1);
                    break;                   
                end
            end
        end

        hElAindex = floor(azimuth / 8) + 1;
        hEhAindex = hElAindex + 1;

        eValues(1) = 40;
        eValues(2) = 50;
        aValues(3) = (hElAindex - 1) * 8;
        aValues(4) = hElAindex * 8;
    elseif ((50 < elevation) && (60 >= elevation))
        lEindex = 10;
        hEindex = 11;
        lElAindex = floor(azimuth / 8) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = floor(azimuth / 10) + 1;
        hEhAindex = hElAindex + 1;

        eValues(1) = 50;
        eValues(2) = 60;
        aValues(1) = (lElAindex - 1) * 8;
        aValues(2) = lElAindex * 8;
        aValues(3) = (hElAindex - 1) * 10;
        aValues(4) = hElAindex * 10;
    elseif ((60 < elevation) && (70 >= elevation))
        lEindex = 11;
        hEindex = 12;
        lElAindex = floor(azimuth / 10) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = floor(azimuth / 15) + 1;
        hEhAindex = hElAindex + 1;

        eValues(1) = 60;
        eValues(2) = 70;
        aValues(1) = (lElAindex - 1) * 10;
        aValues(2) = lElAindex * 10;
        aValues(3) = (hElAindex - 1) * 15;
        aValues(4) = hElAindex * 15;
    elseif ((70 < elevation) && (80 >= elevation))
        lEindex = 12;
        hEindex = 13;
        lElAindex = floor(azimuth / 15) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = floor(azimuth / 30) + 1;
        hEhAindex = hElAindex + 1;

        eValues(1) = 70;
        eValues(2) = 80;
        aValues(1) = (lElAindex - 1) * 15;
        aValues(2) = lElAindex * 15;
        aValues(3) = (hElAindex - 1) * 30;
        aValues(4) = hElAindex * 30;
    elseif ((80 < elevation) && (90 > elevation))
        lEindex = 13;
        hEindex = 14;
        lElAindex = floor(azimuth / 30) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = 1;
        hEhAindex = 1;

        eValues(1) = 80;
        eValues(2) = 90;
        aValues(1) = (lElAindex - 1) * 30;
        aValues(2) = lElAindex * 30;
        aValues(3) = 0;
        aValues(4) = 0;
    elseif (90 <= elevation)
        lEindex = 14;
        hEindex = 14;
        lElAindex = 1;
        lEhAindex = 1;
        hElAindex = 1;
        hEhAindex = 1;

        eValues(1) = 90;
        eValues(2) = 90;
        aValues(1) = 0;
        aValues(2) = 0;
        aValues(3) = 0;
        aValues(4) = 0;
    end

