%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: overlapSaveRecorded.m
%
%   This module performs fast FFT-based convolution using the overlap-save
%   block-processing method. This enables more memory efficient fast
%   convolution processing.
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             01.11.23    L. Gildenstern           initial version  
%   1.1             04.11.23    J.Smith                      comments added
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% param[in]             audio           vector containing audio data
% param[in]             h                  impulse response to convolve with
% param[in]             blocksize     desired blocksize
% retval                    audioConv  convolution result
function [audioConv] = overlapSaveRecorded(audio,h,blocksize)

% block length of total signal for convolution
convBlocksize=blocksize+length(h)-1;

% append zeros at beginning to audio
audio = cat(1,zeros(convBlocksize-blocksize,1),audio);

% preallocate vector for output to increase performance
audioConv = zeros(length(audio)+length(h)-1,1);

runs=ceil(length(audio)/blocksize);
for i = 0:runs
    try
        start=blocksize*i+1;                                                    % Calculate start index of current block
        stop=start+convBlocksize-1;                                       % Calculate end index of current block
        overlapSaveReturn = fftConv(audio(start:stop),h);     % Perform fast convolution on current block 
        
        % Store result in preallocated return vector
        audioConv(start:start+blocksize-1) = overlapSaveReturn(convBlocksize-blocksize+1:convBlocksize);
    catch
        % append zeros at the end until start > len(audio)
        while (stop > length(audio) && start <= length(audio))
            audio = cat(1,audio,0);
        end
        overlapSaveReturn = fftConv(audio(start:stop),h);
        audioConv(start:start+blocksize-1) = overlapSaveReturn(convBlocksize-blocksize+1:convBlocksize);
    end
    
end


end