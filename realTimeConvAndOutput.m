function [output, audioOverlap] = realTimeConvAndOutput(input, audioOverlap, h,blockSize)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% % set convolution blocksize
 convBlocksize=blockSize+length(h)-1;

audioOverlap = [audioOverlap(blockSize+1:end);input];

% Perform fast convolution on current block 
overlapSaveReturnLeft = fftConv(audioOverlap,h(:,1));
%overlapSaveReturnRight = fftConv(audioOverlap,h(:,2));
output = overlapSaveReturnLeft(convBlocksize-blockSize+1:convBlocksize,:);
%output(:,2) = overlapSaveReturnRight(convBlocksize-blockSize+1:convBlocksize,:);

end