%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: prepareBlocks.m
%
%   Allocations and prepares the block necessary for real time overlap-save
%   based convolution.
%   
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             18.10.23    L. Gildenstern            initial version  
%   1.1             19.11.23    J.Smith                       functionality moved to individual module
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [overlapVector, outputVector] = prepareBlocks(blockSize, h)
% set convolution blocksize
convBlocksize=blockSize+length(h)-1;
% preallocate overlap
overlapVector = zeros(convBlocksize,1);

% preallocate output
outputVector = zeros(blockSize,1);
end

