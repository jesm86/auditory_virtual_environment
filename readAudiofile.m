%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: readAudiofile.m
%
%   This module reads in audiofile (*.wav, *.mp3, *.flac formats) from the
%   hard disk of the computer. This is done using the built-in uigetfile
%   function of matlab. This function will prompt a new window in which the
%   user has to select an appropriate file. The name and the path of this
%   file will be stored in variables. If no file is successfully selected
%   (i.e. file == 0), the boolean flag boSuccess is set to false and the
%   function returns. In case the file selection is successful, using the
%   try-catch structure the functions calls upon matlabs built-in audioread
%   function to read the selected file and store the audiodata and the sampling rate of the file. 
%   If successful the boolean flag boSuccess is set to true, otherwise it is set to false.
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             16.10.23    J.Smith                      initial version  
%   1.1             04.11.23    J.Smith                      comments added, variable names fixed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   retval      boSuccess          boolean flag to indicate the success of the audiofile reading
%   retval      audiodata     read-in audiodata from the selected file
%   retval      f_s                       sampling rate of the read-in file
function [boSuccess, audiodata, f_s] = readAudiofile()

    %Promt new window for file selection and store filename and -path
    [file,path] = uigetfile({'*.wav; *.mp3; *.flac', 'Audio files (*.wav, *.mp3, *.flac)'});
    if isequal(file, 0)
        boSuccess = false;
        f_s = 0;
        audiodata = zeros();
    else
        try
            [audiodata, f_s] = audioread(fullfile(path,file));
            boSuccess = true;
        catch 
            boSuccess = false;
            f_s = 0;
            audiodata = zeros();
        end     
    end
end

