%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: imageSourceAnd3dSpatialisationOffline.m
%
%   This module takes a given audio file and recorded movement
%   vectors of source and receiver coordinates and computes 3D-spatialized
%   sound using the Image Source Method and given HRIR sets.
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             21.01.24    L.Gildenstern            created
%   1.1             23.01.24    J. Smith                    added HRIR computation, adjusted to be usable in GUI, added progress bar
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   param[in]       audio               audio file (mono or stereo)
%   param[in]       Fs                  sample frequency of audio file
%   param[in]       blockSize           block size for use in overlap save
%   param[in]       roomDimensions      dimensions of the room for rendering [x, y, z] in m
%   param[in]       sourceCoords         vector of coordinates of sound source in room [[x, y, z][x, y, z]] in m
%   param[in]       receiverCoords       vector of coordinates of receiver in room [[x, y, z][x, y, z]] in m
%   param[in]       directionFacing     vector of directions the receiver is facing [[x, y, z][x, y, z]] in m
%   param[in]       maxReverb           maximal reverberation time for rendering walls 
%   param[in]       wallCoef            wall absorption coeffitient [left, right, front, back, floor, ceiling], range[0:1]
%   param[in]       HRIR_set           HRIR filter set
%   param[in]       Gauge               Gauge used in GUI to show progress [%]
%
%   retval          output              vector containing the rendered  audio output
function [output] = imageSourceAnd3dSpatialisationOffline(audio,Fs,blockSize,roomDimensions,sourceCoords, receiverCoords, directionFacing, maxReverb, wallCoef, HRIR_set, Gauge)
Gauge.Value = 0;


zEnd = blockSize - mod(length(audio),blockSize);
if 2 == width(audio)
    audio = [audio; zeros(zEnd,width(audio))];
else
    audio = [audio, audio; zeros(zEnd,2)];
end

% preallocate output (audio, HRIR, h/maxreverb)
output = zeros(length(audio)+maxReverb*Fs,width(audio)); 

% get the index of the last recorded source and receiver positions
lastIndexCoords = numel(sourceCoords(:,1));

% create two output channels (stereo
for ch = 1:2

    %for loop over blocks of complete audio signal
    runs = ((length(audio))/blockSize)-1;
    for r = 0:runs
        % extract current block
        start = blockSize*r+1; 
        stop = start+blockSize-1;  
        block = audio(start:stop,ch);
        
        if runs ~= 0
            if 2 == ch
                Gauge.Value = (r + runs) / (2 * runs) * 100;
            elseif 1 == ch
                Gauge.Value = r / (2 * runs) * 100;
            end
        end

        % Create image sources (and delay + coeffs) for recorded source and
        % receiver positions. If end is reached, continue to use last
        % recorded data
        if lastIndexCoords < (r+1)
            [~,isourceCoord,delay,~,coefs] = IRfromCuboid(roomDimensions,sourceCoords(lastIndexCoords,:),receiverCoords(lastIndexCoords,:),maxReverb,wallCoef,Fs);
        else
            [~,isourceCoord,delay,~,coefs] = IRfromCuboid(roomDimensions,sourceCoords(r+1,:),receiverCoords(r+1,:),maxReverb,wallCoef,Fs);
        end

    
        %for loop over image source rays
            for i = 1:length(delay)
            % shift and dampen block
            singleImageBlock = [zeros(delay(i),width(block));block]*coefs(i);
            
            % Compute HRIR for position of receiver and current image
            % source and resample to used sample rate
            if lastIndexCoords < (r+1)
                [HRIR(:,1), HRIR(:,2)] = computeFinalHrir(receiverCoords(lastIndexCoords, :), isourceCoord(i, :), HRIR_set, Fs); 
            else
                [HRIR(:,1), HRIR(:,2)] = computeFinalHrir(receiverCoords(r+1, :), isourceCoord(i, :), HRIR_set, Fs); 
            end
            resample(HRIR(:,ch), Fs, 44100);


            % Prepare block
            [convBlockSize, ~ ,zEnd]=getPrepParams(singleImageBlock,HRIR(:,ch),blockSize);
            singleImageBlock = [singleImageBlock; zeros(zEnd,width(singleImageBlock))];
    
            % set first overlap to zero
            overlap = zeros(convBlockSize,1);

            % for loop and overlap save over one shifted and dampened block
            blockRuns = ((length(singleImageBlock))/blockSize)-1;
            pause(0.0000001);
            for b = 0:blockRuns
                %extract current convolution block
                startConv = blockSize*b+1;                                                    
                stopConv = startConv+blockSize-1;                                      
                convBlock = singleImageBlock(startConv:stopConv);
    
                %do overlap save
                [tempOutput,overlap]=realTimeConvAndOutput(convBlock,overlap,HRIR(:,ch),blockSize);
                
                % add tempOut to output
                currentStart = start + blockSize * b;    
                currentStop = stop + blockSize * b;     
                if length(output(:,1)) < currentStop
                    output = [output; zeros(currentStop-length(output), width(output))];
                end
                output(currentStart:currentStop,ch) = output(currentStart:currentStop,ch) + tempOutput;    
            end
             
        end
    
    end

end
end