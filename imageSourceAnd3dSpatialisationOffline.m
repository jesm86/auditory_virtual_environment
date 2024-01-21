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
%
%   retval          output              vector containing the rendered
%   audio output
function [output] = imageSourceAnd3dSpatialisationOffline(audio,Fs,blockSize,roomDimensions,sourceCoords, receiverCoords, directionFacing, maxReverb, wallCoef, HRIR)

[convBlockSize,zStart,zEnd]=getPrepParams(audio,HRIR,blockSize);
audio = [audio; zeros(zEnd,width(audio))];

% preallocate output (audio, HRIR, h/maxreverb)
output = zeros(length(audio)+maxReverb*Fs,width(audio)); %+length(HRIR)-1

for ch = 1:width(audio)

    %for loop over blocks of complete audio signal
    runs = ((length(audio))/blockSize)-1;
    for r = 0:runs
        % extract current block
        start = blockSize*r+1; 
        stop = start+blockSize-1;  
        block = audio(start:stop,ch);
    
        % get current positions and dimensions somehow
        sourceCoord = mean(sourceCoords(start:stop,:));
        receiverCoord = mean(receiverCoords(start:stop,:));
        
        [iR,isourceCoord,delay,dist,coefs] = IRfromCuboid(roomDimensions,sourceCoord,receiverCoord,maxReverb,wallCoef,Fs);
        %delay=[1;2;1000; 0.2*Fs; 0.4*Fs];
        %coefs=[1;1;0.1; 1; 1];
    
        %for loop over image source rays
        for i = 1:length(delay)
            % shift and dampen block
            singleImageBlock = [zeros(delay(i),width(block));block]*coefs(i);
            
            % get elevation and azimuth
            [elev,azim] = getElevationAndAzimuth(sourceCoord,receiverCoord,directionFacing);
    
            % get corresponding HRIR
            % getHRIR(elev,azim,ch);
            
            % prep block
            [convBlockSize,zStart,zEnd]=getPrepParams(singleImageBlock,HRIR,blockSize);
            singleImageBlock = [singleImageBlock; zeros(zEnd,width(singleImageBlock))];%[zeros(zStart ,width(singleImageBlock)); singleImageBlock; zeros(zEnd,width(singleImageBlock))];
    
            % set first overlap to zero
            overlap = zeros(convBlockSize,1);
    
            % for loop and overlap save over one shifted and dampened block
            blockRuns = ((length(singleImageBlock))/blockSize)-1;
            for b = 0:blockRuns
                %extract current convolution block
                startConv = blockSize*b+1;                                                    
                stopConv = startConv+blockSize-1;                                      
                convBlock = singleImageBlock(startConv:stopConv);
    
                %do overlap save
                [tempOutput,overlap]=realTimeConvAndOutput(convBlock,overlap,HRIR,blockSize);
                
                % add tempOut to output
                currentStart = start + blockSize * b;    %start-1+startConv;
                currentStop = stop + blockSize * b;     %currentStart+blockSize-1;
                if length(output) < currentStop
                    output = [output; zeros(currentStop-length(output), width(output))];
                end
                output(currentStart:currentStop,ch) = output(currentStart:currentStop,ch) + tempOutput;
    
            end
             
        end
    
    end

end
end