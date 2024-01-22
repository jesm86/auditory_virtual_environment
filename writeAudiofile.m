%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: writeAudiofile.m
%
%   This module writes audiodata to a file and stores it on the hard disk
%   of the computer. It can store the data in *.flac or *.wav file format
%   or play the audiodata via speaker.
%   One of the function parameters is a string which determines which
%   format will be used. If successfully written, a boolean flag with value
%   true will be returned. If unsuccessful its value will be false. This
%   function uses the matlab built-in audiowrite function to write the
%   audiodata. If the input string indicates so, the data will not be
%   written to the hard disk, but be played by a speaker connected to the
%   PC.
%
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             16.10.23    J.Smith                      initial version  
%   1.1             04.11.23    J.Smith                      comments added, changed variable names  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   param[in]       format           String who determines how audiodata is written
%   param[in]       audio             audiodata to be written to file
%   param[in]       f_s                 Sampling frequency of audiodata to be written
%   retval             boStatusFlag boolean flag indicating success of file writing
function [boStatusFlag] = writeAudiofile(format, audio, f_s)

    % Check string to decide in which format the data should be written or
    % if it should be played by the speaker
    if "flac" == format
        try
            audiowrite("output.flac", audio, f_s, 'BitsPerSample', 24, 'Comment', "Flac output file");
            boStatusFlag = true;
        catch
            boStatusFlag = false;
        end
    elseif "wav" == format
            try
                audio_normalized = audio / max(abs(audio));
                audiowrite("output.wav", audio_normalized, f_s);
                boStatusFlag = true;
            catch
                boStatusFlag = false;
            end

    elseif "speaker" == format
            try
                soundsc(audio, f_s);
                boStatusFlag = true;
            catch
                boStatusFlag = false;   
            end
    end
end

