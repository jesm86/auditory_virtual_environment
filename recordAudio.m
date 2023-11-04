%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: recordAudio.m
%
%   This module stores audiodate recorded with a connected microphone. It
%   needs the reference to an object of class audiorecorder as a parameter,
%   as well as the desired sampling frequency of the recording and a
%   boolean flag that indicates whether a recording has already been
%   started. If the boolean is false (i.e. the object is not yet
%   recording), the recording is started and the boolean flag is set to
%   true. If the boolean parameter was true (i.e. object is already in a
%   recording state), the recording is stopped and the flag is set toy
%   false.
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             16.10.23    J.Smith                      initial version  
%   1.1             04.11.23    J.Smith                      comments added, changed variable names  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   param[in]       recorderObj          Object of class audiorecorder that has has been initialized 
%                                                      in the superior module.
%   param[in]       samplingFreq       Sampling frequency of the recording 
%   param[in/out] boRecordingFlag  boolean Flag indicating whether the obj is already recording 
%   retval             boRecordingState boolean Flag indicating recording state of obj after function 
function [boRecordingState] = recordAudio(recorderObj, samplingFreq, boRecordingFlag)

boRecordingState = boRecordingFlag;

% Check recording state flag and depending on its value start or stop the recording
if false == boRecordingState
    try
        record(recorderObj, samplingFreq);
        boRecordingState = true;
    catch
        boRecordingState = false;
    end
elseif true == boRecordingState
    try
        stop(recorderObj);
        boRecordingState = false;
    catch
        boRecordingState = true;
    end
end
end

