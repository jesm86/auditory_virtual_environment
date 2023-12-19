function [lEindex, hEindex, lElAindex, lEhAindex, hElAindex, hEhAindex] = findHRIRindex(elevation, azimuth)
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
            hElAindex = length(azimuthPattern);  % Additional variable
            hEhAindex = length(azimuthPattern);  % Additional variable
        else
            for index = 1:length(azimuthPattern)-1
                if (azimuth >= azimuthPattern(index)) && (azimuth < azimuthPattern(index + 1))
                    lElAindex = index;
                    lEhAindex = index + 1;
                    hElAindex = index;
                    hEhAindex = index + 1;
                    break; 
                end
            end
        end

    elseif ((-40 < elevation) && (30 >= elevation))
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
        else
            for index = 1:length(azimuthPattern)-1
                if (azimuth >= azimuthPattern(index)) && (azimuth < azimuthPattern(index + 1))
                    lElAindex = index;
                    lEhAindex = index + 1;
                    break; 
                else
                    lElAindex = length(azimuthPattern);
                    lEhAindex = length(azimuthPattern);
                    break;                
                end
            end
        end

        hElAindex = floor(azimuth / 6) + 1;
        hEhAindex = hElAindex + 1;
    elseif ((-30 < elevation) && (-20 >= elevation))
        lEindex = 3;
        hEindex = 2;
        lElAindex = floor(azimuth / 6) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = floor(azimuth / 5) + 1;
        hEhAindex = hElAindex + 1;
    elseif ((-20 < elevation) && (-10 >= elevation))
        lEindex = 2;
        hEindex = 1;
        lElAindex = floor(azimuth / 5) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = lElAindex;
        hEhAindex = lEhAindex;
    elseif ((-10 < elevation) && (0 >= elevation))
        lEindex = 1;
        hEindex = 5;
        lElAindex = floor(azimuth / 5) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = lElAindex;
        hEhAindex = lEhAindex;
    elseif ((0 < elevation) && (10 >= elevation))
        lEindex = 5;
        hEindex = 6;
        lElAindex = floor(azimuth / 5) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = lElAindex;
        hEhAindex = lEhAindex;
    elseif ((10 < elevation) && (20 >= elevation))
        lEindex = 6;
        hEindex = 7;
        lElAindex = floor(azimuth / 5) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = lElAindex;
        hEhAindex = lEhAindex;
    elseif ((20 < elevation) && (30 >= elevation))
        lEindex = 7;
        hEindex = 8;
        lElAindex = floor(azimuth / 5) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = floor(azimuth / 6) + 1;
        hEhAindex = hElAindex + 1;
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
        else
            for index = 1:length(azimuthPattern)-1
                if (azimuth >= azimuthPattern(index)) && (azimuth < azimuthPattern(index + 1))
                    hElAindex = index;
                    hEhAindex = index + 1;
                    break; 
                end
            end
        end
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
        else
            for index = 1:length(azimuthPattern)-1
                if (azimuth >= azimuthPattern(index)) && (azimuth < azimuthPattern(index + 1))
                    lElAindex = index;
                    lEhAindex = index + 1;
                    break;                   
                end
            end
        end

        hElAindex = floor(azimuth / 8) + 1;
        hEhAindex = hElAindex + 1;
    elseif ((50 < elevation) && (60 >= elevation))
        lEindex = 10;
        hEindex = 11;
        lElAindex = floor(azimuth / 8) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = floor(azimuth / 10) + 1;
        hEhAindex = hElAindex + 1;
    elseif ((60 < elevation) && (70 >= elevation))
        lEindex = 11;
        hEindex = 12;
        lElAindex = floor(azimuth / 10) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = floor(azimuth / 15) + 1;
        hEhAindex = hElAindex + 1;
    elseif ((70 < elevation) && (80 >= elevation))
        lEindex = 12;
        hEindex = 13;
        lElAindex = floor(azimuth / 15) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = floor(azimuth / 30) + 1;
        hEhAindex = hElAindex + 1;
    elseif ((80 < elevation) && (90 > elevation))
        lEindex = 13;
        hEindex = 14;
        lElAindex = floor(azimuth / 30) + 1;
        lEhAindex = lElAindex + 1;
        hElAindex = 1;
        hEhAindex = 1;
    elseif (90 <= elevation)
        lEindex = 14;
        hEindex = 14;
        lElAindex = 1;
        lEhAindex = 1;
        hElAindex = 1;
        hEhAindex = 1;
    end
end