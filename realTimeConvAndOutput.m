function [] = realTimeConvAndOutput(h,Fs,blockSize,breakFunc)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% set convolution blocksize
convBlocksize=blockSize+length(h)-1;

% initialize playerRecorder object
playRec = audioPlayerRecorder(Fs);

% preallocate overlap
audioOverlap = zeros(convBlocksize,1);

% preallocate output
output = zeros(blockSize,1);

while ~breakFunc()
    % read a block of audio data and output the one processed before
    data = playRec(output);

    % shift old audioOverlap and append new data
    audioOverlap = [audioOverlap(blockSize+1:end);data];

    % Perform fast convolution on current block 
    overlapSaveReturn = fftConv(audioOverlap,h);     
    output = overlapSaveReturn(convBlocksize-blockSize+1:convBlocksize);
    
    % pause to allow parallel functions to work
    pause(0.001)
end
release(playRec);
end