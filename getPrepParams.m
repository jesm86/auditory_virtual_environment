%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: getPrepParams.m
%
%   This function computes the parameters that are necessary for the
%   preparation of the block-processing based convolution
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             19.1.24        L.Gildenstern             created
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [convBlocksize, zStart, zEnd] = getPrepParams(audio,h,blockSize)


convBlocksize=blockSize+length(h)-1;

% zero pad beginning
zStart = convBlocksize - blockSize;

% zero pad end
zEnd = blockSize - mod(length(audio), blockSize);
if ( zEnd < zStart)
    zEnd = zEnd + convBlocksize - zStart;
end

end

