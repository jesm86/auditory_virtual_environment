function [] = realTimeConvAndOutput(h,Fs,blockSize,breakFunc)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

convBlocksize=blockSize+length(h)-1;

% recorder = audioDeviceReader(Fs, blockSize);
% player = audioDeviceWriter(Fs);

playRec = audioPlayerRecorder(Fs);

audioOverlap = zeros(convBlocksize,1);

output = zeros(blockSize,1);

h_fig = figure;
set(h_fig,'KeyPressFcn',@myfun);

kbhit = false;

function myfun(~, event)
    kbhit = true;
end

while ~kbhit
    % read a block of audio data and output the one processed before
    data = playRec(output);

    % shift old audioOverlap and append new data
    audioOverlap = [audioOverlap(blockSize+1:end);data];

    % Perform fast convolution on current block 
    overlapSaveReturn = fftConv(audioOverlap,h);     
    output = overlapSaveReturn(convBlocksize-blockSize+1:convBlocksize);

    pause(0.01)
end
release(playRec);
end