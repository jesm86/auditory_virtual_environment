%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: realTimeConvAndOutput.m
%
%   This module reads the whole HRIR set (provided by MIT) and stores them
%   in a cell matrix. SET{a}{b}, where a is the index separating the
%   folders and b the index for the files inside these folders. a seperates
%   different elevation levels while b separates azimuth angles.
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             18.12.23    L.Gildenstern            initial version  
%   1.1             19.12.23    J.Smith                      moved most of the functionality to other files. Infinite while 
%                                                                         loop for real time processing now in GUI (otherwise whole system
%                                                                         will get blocked and is stuck inside this module
%   1.2             20.12.23    J.Smith                      process both channels separately, by 2 separate 
%                                                                         calls of this function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output, audioOverlap] = realTimeConvAndOutput(input, audioOverlap, h,blockSize)

% % set convolution blocksize
 convBlocksize=blockSize+length(h)-1;

audioOverlap = [audioOverlap(blockSize+1:end);input];

% Perform fast convolution on current block 
overlapSaveReturnLeft = fftConv(audioOverlap,h(:,1)');
output = overlapSaveReturnLeft(convBlocksize-blockSize+1:convBlocksize,:);


end