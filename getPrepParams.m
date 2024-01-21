function [convBlocksize, zStart, zEnd] = getPrepParams(audio,h,blockSize)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

convBlocksize=blockSize+length(h)-1;

% zero pad beginning
zStart = convBlocksize - blockSize;

% zero pad end
zEnd = blockSize - mod(length(audio), blockSize);
if ( zEnd < zStart)
    zEnd = zEnd + convBlocksize - zStart;
end

end

