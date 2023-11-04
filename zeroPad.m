%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: zeroPad.m
%
%   This module performs the necessary zero padding on two input vectors as
%   preparation for the Fast Fourier Transform. There are two requirements
%   for the length of the padded vectors: a) They have a length of at least
%   the sum of the individual unpadded input vectors minus 1 and b) The
%   length should be a power of 2 so that the built-in FFT function of
%   matlab really uses the FFT and not uses the slower DFT instead.
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             18.10.23    L. Gildenstern           initial version  
%   1.1             04.11.23    J.Smith                      comments added
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% param[in]        vector1      first input vector to be zero padded
% param[in]        vector2      second input vector to be zero padded
% retval              newV1       zero padded version of first input vector
% retval              newV2       zero padded version of second input vector
function [newV1,newV2] = zeroPad(vector1,vector2)
    
    % Calculate the necessary length of the zero padded vectors, which is
    % the next power of 2 value above the sum of them - 1.
    len = length(vector1) + length(vector2) - 1;
    pot = ceil(log2(len));
    len = pow2(pot);

    % Preallocation of the necessary memory for the two padded versions of
    % the vectors
    newV1=zeros(len, 1);
    newV2=zeros(len, 1);

    % Storing the values of the values of the input vectors at the
    % beginning of the according result vectors
    newV1(1:length(vector1))=vector1;
    newV2(1:length(vector2))=vector2;
end