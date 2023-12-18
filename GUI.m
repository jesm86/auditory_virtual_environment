%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: GUI.m
%
%   Graphical User Interface.
%   The user has the possibility to call all of the function (audiofile
%   read-in, microphone recording, linear+fast convolution and saving +
%   playing the audio) using drop-down menus and buttons. For demonstrating
%   convolution, the GUI provides to build-in impulse responses: A simple echo, that is
%   implemented directly in this m-file and a impulse response of St
%   Andrews Church London. Additionaly different convolution methods
%   (linear, fft-based and overlap-save-blockprocessing-based) can be
%   chosen. If the image source method is chosen, the convolution type will
%   automatically be set to blockprocessing. The user has to set the block
%   size himself. Default value is 2**20 = 1048576.
%   This GUI was created using the built-in AppDesigner functionality of
%   Matlab. 
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.1             18.10.23    J.Smith                    initial version  
%   1.1             04.11.23    J.Smith                    clean up + comments
%   2.0             05.12.23    J.Smith                   update for second deliverables (image source rendering)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        ShowraytracesCheckBox     matlab.ui.control.CheckBox
        PlotimagesourcesCheckBox  matlab.ui.control.CheckBox
        Render                    matlab.ui.control.Button
        ResampleIR                matlab.ui.control.Button
        ResampleInput             matlab.ui.control.Button
        BlocksizeEditField        matlab.ui.control.NumericEditField
        BlocksizeLabel            matlab.ui.control.Label
        ConvolutionTimeField      matlab.ui.control.EditField
        InputDropDown_3           matlab.ui.control.DropDown
        ConvolutiontypeLabel      matlab.ui.control.Label
        ConvolutionField          matlab.ui.control.EditField
        InputDropDown_2           matlab.ui.control.DropDown
        Inputsource2Label         matlab.ui.control.Label
        ReadAudioField_2          matlab.ui.control.EditField
        ReadAudioButton_2         matlab.ui.control.Button
        ConvolutionButton         matlab.ui.control.Button
        StartStopRecordingButton  matlab.ui.control.Button
        WriteAudioField           matlab.ui.control.EditField
        ReadAudioField            matlab.ui.control.EditField
        WriteAudioButton          matlab.ui.control.Button
        ReadAudioButton           matlab.ui.control.Button
        OutputDropDown            matlab.ui.control.DropDown
        OutputDropDownLabel       matlab.ui.control.Label
        InputDropDown             matlab.ui.control.DropDown
        InputsourceDropDownLabel  matlab.ui.control.Label
        FreqDomainAxes_2          matlab.ui.control.UIAxes
        TimeDomainAxes_2          matlab.ui.control.UIAxes
        FreqDomainAxes            matlab.ui.control.UIAxes
        TimeDomainAxes            matlab.ui.control.UIAxes
    end

        properties (Access = private)
        audioData                                       % vector with audiodata of input source (mic or file)
        F_s                                                 % sampling frequency of input data
        impulseResponseData                   % vector with data of impulse response 
        F_s_2                                             % sampling frequency of impulse response
        convolvedSignalData                     % result of convolution of input & impulse response
        F_s_3                                             % sampling frequency of result
        boRecordingFlag1 = false;             % boolean indicating if system is recording
        recorder = audiorecorder(44100, 16, 1); % Object of class audiorecorder for recording audio
                                                                        % with microphone. Sampling rate will be 44,1kHz
                                                                        % 16 bit quantization and 1 channel
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Callback function for "Read audio" button 1
        function ReadAudioButtonPushed(app, event)
            [boFileRead, timeDomain, f_s] = readAudiofile;  % call function to read audio file
            if true == boFileRead                                           % if successful: save data and f_s          
                    app.ReadAudioField.Value = 'file read';       % display "file read" in text field

                    % Plot audio signal in time and frequency domain
                    app.audioData= timeDomain;
                    app.F_s = f_s;            
                    L = length(app.audioData);
                    t=(0:L-1)*(1/app.F_s);            
                    plot(app.TimeDomainAxes, t, app.audioData); 
                    y_freqDomain = fft(app.audioData);                                
                    plot(app.FreqDomainAxes, (0:L-1)*(app.F_s/L), abs(fftshift(y_freqDomain)));
                    app.ConvolutionField.Value = "ready";
            else 
                app.ReadAudioField.Value = 'failed';
            end
        end

        % Callback function for "Write audio button"
        function WriteAudioButtonPushed(app, event)
            % If convolution was successfuly performed, use this instead
            try                                         
                if "finished" == app.ConvolutionField.Value
                    audio = app.convolvedSignalData;
                else
                    audio = app.audioData;
                end
                % Depending on dropdown menu, write audio to speaker, as flac file or as wav file 
                if "Speaker" == app.OutputDropDown.Value
                    boStatus = writeAudiofile("speaker", audio, app.F_s);
                    if true == boStatus
                        app.WriteAudioField.Value = "played.";
                    else
                        app.WriteAudioField.Value = "failed";
                    end
                elseif "Free Lossless Audio Codec (flac)" == app.OutputDropDown.Value
                    boStatus = writeAudiofile("flac", audio, app.F_s);
                    if true == boStatus
                        app.WriteAudioField.Value = "flac file created";
                    else
                        app.WriteAudioField.Value = "failed";
                    end
                elseif "Microsoft WAVE sound (wav)" == app.OutputDropDown.Value
                    boStatus = writeAudiofile("wav", audio, app.F_s);
                    if true == boStatus
                        app.WriteAudioField.Value = "wav file created";
                    else
                        app.WriteAudioField.Value = "failed";
                    end
                end
            catch
                app.WriteAudioField.Value = "failed";
            end
        end

        % Callback for input source dropdown menu value change event
        function InputDropDownValueChanged(app, event)
            % If dropdown value was changed to 'Microphone': Only show
            % "Record" button, make "Read file" button invisible
            if "Microphone" == app.InputDropDown.Value
                app.StartStopRecordingButton.Visible = "on";
                app.ReadAudioButton.Visible = "off";
            % In other cases reverse visibility of the two buttons
            else
                app.StartStopRecordingButton.Visible = "off";
                app.ReadAudioButton.Visible = "on";
            end
            app.ReadAudioField.Value = "";
            cla(app.TimeDomainAxes);
            cla(app.FreqDomainAxes);
            clearvars
        end

        % Value changed function: OutputDropDown
        function OutputDropDownValueChanged(app, event)
            app.WriteAudioField.Value = "";            
        end

        % Button pushed function: StartStopRecordingButton
        function StartStopRecordingButtonPushed(app, event)
            % Use recordAudio module to record audio from mic using the
            % initialized object of class audiorecorder. Check recording
            % flag to either start or stop recording procedure. Also plot
            % signal in time and frequency domain
            if false == app.boRecordingFlag1
                app.F_s = 44100;
                app.boRecordingFlag1 = recordAudio(app.recorder, app.F_s, app.boRecordingFlag1);
                app.ReadAudioField.Value = "recording...";                
            elseif true == app.boRecordingFlag1
                app.boRecordingFlag1 = recordAudio(app.recorder, app.F_s, app.boRecordingFlag1);
                app.ReadAudioField.Value = "record finished";
                app.audioData= getaudiodata(app.recorder);
                
                % Create plot of time domain signal and its spectrum
                L = length(app.audioData);
                t=(0:L-1)*(1/app.F_s);
                plot(app.TimeDomainAxes, t, app.audioData);                
                y_freqDomain = fft(app.audioData);
                plot(app.FreqDomainAxes, (0:L-1)*(app.F_s/L), abs(fftshift(y_freqDomain)));
                app.ConvolutionField.Value = "ready";
            end
        end

        % Button pushed function: ConvolutionButton
        function ConvolutionButtonPushed(app, event)
            %Functionality to convolve the audiosignal with the impule
            %response. "Fast convolution" uses fftConv.m module directly.
            %"Time Domain convolution" performs convolution in time domain,
            %while "Overlap-Save FFT-Conv" using the fftConv.m module in
            %conjunction with overlap-save block processing implemented in
            %the overlapSaveRecorded.m module. Computation time measured using tic toc
            try
               audio1 = mean(app.audioData, 2);
               audio2 = mean(app.impulseResponseData, 2);
               if "Fast convolution" == app.InputDropDown_3.Value
                   tic
                   app.convolvedSignalData = fftConv(audio1,audio2);
                   time = num2str(toc);
                   app.ConvolutionTimeField.Value = strcat("Time: ", time,"s");
               elseif "Time Domain Convolution" == app.InputDropDown_3.Value
                   tic
                   app.convolvedSignalData = conv(audio1,audio2);
                   time = num2str(toc);
                   app.ConvolutionTimeField.Value = strcat("Time: ", time,"s");
               elseif "Overlap-Save FFT-Conv." == app.InputDropDown_3.Value
                   tic
                   app.convolvedSignalData = overlapSaveRecorded(audio1, audio2, app.BlocksizeEditField.Value);
                   time = num2str(toc);
                   app.ConvolutionTimeField.Value = strcat("Time: ", time,"s");
               end
               app.ConvolutionField.Value = "finished";
            catch
               app.ConvolutionField.Value = "failed";
            end
          % Create plots (time domain and spectrum)
          L = length(app.convolvedSignalData);
          t=(0:L-1)*(1/app.F_s);
          plot(app.TimeDomainAxes, t, app.convolvedSignalData);
          y_freqDomain = fft(app.convolvedSignalData);
          plot(app.FreqDomainAxes, (0:L-1)*(app.F_s/L), abs(fftshift(y_freqDomain)));
        end

        % Callback: Read impulse response button
        function ReadAudioButton_2Pushed(app, event)
            % Functionality to read in impulse response from a file. Analog
            % to file reading of audio signal above
            if "File" == app.InputDropDown_2.Value
                [file_2,path_2] = uigetfile({'*.wav; *.mp3; *.flac', 'Audio files (*.wav, *.mp3, *.flac)'});
                if isequal(file_2, 0)
                    app.ReadAudioField_2.Value = 'cancelled';
                else
                    try
                       [app.impulseResponseData, app.F_s_2] = audioread(fullfile(path_2,file_2));
                       app.ReadAudioField_2.Value = 'file read';
                       L = length(app.impulseResponseData);
                       t=(0:L-1)*(1/app.F_s_2);
                        
                       plot(app.TimeDomainAxes_2, t, app.impulseResponseData);
                        
                       y_freqDomain = fft(app.impulseResponseData);
                       plot(app.FreqDomainAxes_2, (0:L-1)*(app.F_s_2/L), abs(fftshift(y_freqDomain)));
                    catch
                        app.ReadAudioField_2.Value = 'failed';
                    end
                end
            end
        end

        % Value changed function: InputDropDown_2
        function InputDropDown_2ValueChanged(app, event)
            %Implementation of impulse response drop down menu callback.
            %File asks the user to select a file, "St. Andrews London"
            %automatically reads in the impulse response file from "St
            %Andrews London Church" and echo created a simple echo impulse
            %response
            if "File" == app.InputDropDown_2.Value
                app.ReadAudioButton_2.Visible = "on";
                app.InputDropDown_3.Visible = "on";
                app.Render.Visible = "off";
                app.ShowraytracesCheckBox.Visible = "off";
                app.PlotimagesourcesCheckBox.Visible = "off";
            elseif "St. Andrews London" == app.InputDropDown_2.Value
                app.ReadAudioButton_2.Visible = "off";
                app.InputDropDown_3.Visible = "on";
                app.Render.Visible = "off";
                app.ShowraytracesCheckBox.Visible = "off";
                app.PlotimagesourcesCheckBox.Visible = "off";
                [app.impulseResponseData, app.F_s_2] = audioread(fullfile("./impulse_responses", "st-andrews-church.wav"));
            elseif "Echo" == app.InputDropDown_2.Value
                app.ReadAudioButton_2.Visible = "off";
                app.InputDropDown_3.Visible = "on";
                app.Render.Visible = "off";
                app.ShowraytracesCheckBox.Visible = "off";
                app.PlotimagesourcesCheckBox.Visible = "off";
                if ~isempty(app.audioData)
                    last=length(app.audioData);
                    app.impulseResponseData = zeros(last,1);
                    app.impulseResponseData(1) = 1;
                    app.impulseResponseData(last-1) = 1;
                    app.F_s_2 = app.F_s;
                else
                    msgbox("No input signal to create echo", "Error", "modal");
                end
            elseif "Image Source Method" == app.InputDropDown_2.Value
                % Implementation of image source rendering functionality
                app.InputDropDown_3.Visible = "off";
                app.BlocksizeEditField.Visible = "on";
                app.BlocksizeLabel.Visible = "on";
                app.Render.Visible = "on";
                app.ShowraytracesCheckBox.Visible = "on";
                app.PlotimagesourcesCheckBox.Visible = "on";
                app.InputDropDown_3.Value = "Overlap-Save FFT-Conv.";
                app.ReadAudioButton_2.Visible = "off";
            end

            if ~isempty(app.impulseResponseData)
                app.ReadAudioField_2.Value = "";
                L = length(app.impulseResponseData);
                t=(0:L-1)*(1/app.F_s_2);
                
                plot(app.TimeDomainAxes_2, t, app.impulseResponseData);
                
                y_freqDomain = fft(app.impulseResponseData);
                plot(app.FreqDomainAxes_2, (0:L-1)*(app.F_s_2/L), abs(fftshift(y_freqDomain)));
            end
        end

        % Value changed function: InputDropDown_3
        function InputDropDown_3ValueChanged(app, event)
            if "Fast convolution" == app.InputDropDown_3.Value
                app.BlocksizeEditField.Visible = "off";
                app.BlocksizeLabel.Visible = "off";
            elseif "Time Domain Convolution" == app.InputDropDown_3.Value
                app.BlocksizeEditField.Visible = "off";
                app.BlocksizeLabel.Visible = "off";
            elseif "Overlap-Save FFT-Conv." == app.InputDropDown_3.Value
                app.BlocksizeEditField.Visible = "on";
                app.BlocksizeLabel.Visible = "on";
                app.BlocksizeEditField.Value = 2^20;
            end
        end

        % Button down function: TimeDomainAxes
        function TimeDomainAxesButtonDown(app, event)
            
        end

        % Value changed function: BlocksizeEditField
        function BlocksizeEditFieldValueChanged(app, event)
            value = app.BlocksizeEditField.Value;
            
        end

        % Callback function for "Resample" Button
        % Popup window to enter target sampling frequency
        function ResampleInputButtonPushed(app, event)
            promt = 'Enter sample rate for resampling of input signal:';
            title = "Resampling of input signal";
            dims = [1 60];
            defaultValue = {''};
            inputValue = inputdlg(promt, title, dims, defaultValue);
            
            % If a target frequency has been entered, resampling is done
            % and the two plots are updated
            % resample(input_signal, p, q). Resampled to p/q * sample_rate.
            % If p is target_rate and q old_rate, then:
            % new_rate = old_rate * (target_rate/old_rate) = target_rate
            if isempty(inputValue)
            else
                targetFreq =  str2double(inputValue);
                app.audioData = resample(app.audioData, targetFreq, app.F_s);
                app.F_s = targetFreq;

                L = length(app.audioData);
                t=(0:L-1)*(1/app.F_s);            
                plot(app.TimeDomainAxes, t, app.audioData); 
                y_freqDomain = fft(app.audioData);                              
                plot(app.FreqDomainAxes, (0:L-1)*(app.F_s/L), abs(fftshift(y_freqDomain)));
            end

        end

        % Callback function for "Resample" Button of impulse response
        % Functionality analogue to other resampling
        function ResampleIRButtonPushed(app, event)
            promt = 'Enter sample rate for resampling of impulse response';
            title = "Resampling of impulse response";
            dims = [1 60];
            defaultValue = {''};
            inputValue = inputdlg(promt, title, dims, defaultValue);

            if isempty(inputValue)
            else
                targetFreq =  str2double(inputValue);
                app.impulseResponseData = resample(app.impulseResponseData, targetFreq, app.F_s_2);
                app.F_s_2 = targetFreq;
                
                L = length(app.impulseResponseData);
                t=(0:L-1)*(1/app.F_s_2);
                
                plot(app.TimeDomainAxes_2, t, app.impulseResponseData);   
                y_freqDomain = fft(app.impulseResponseData);
                plot(app.FreqDomainAxes_2, (0:L-1)*(app.F_s_2/L), abs(fftshift(y_freqDomain)));
            end

        end

        % Callback function for "Render" Button
        % Creates popup windows and asks the user to enter parameters of
        % image source rendering
        function RenderButtonPushed(app, event)
            % get room dimensions
            promt = {"Room length:", "Room width:", "Room height:"};
            title = "Enter room dimensions";
            dims = [1 80];
            defaultValues = {'', '', ''};

            inputs = inputdlg(promt, title, dims, defaultValues);
            if ~isempty(inputs)
            roomDimensions = [str2double(inputs(1)), str2double(inputs(2)), str2double(inputs(3))];
            end
            
            % get source position
            promt = {"Source x coord:", "Source y coord:", "Source z coord:"};
            title = "Source location in room";
            dims = [1 80];
            defaultValues = {'', '', ''};

            inputs = inputdlg(promt, title, dims, defaultValues);
            if ~isempty(inputs)
            Source = [str2double(inputs(1)), str2double(inputs(2)), str2double(inputs(3))];
            end

            % get source position
            promt = {"Receiver x coord:", "Receiver y coord:", "Receiver z coord:"};
            title = "Receiver location in room";
            dims = [1 80];
            defaultValues = {'', '', ''};

            inputs = inputdlg(promt, title, dims, defaultValues);
            if ~isempty(inputs)
            Receiver = [str2double(inputs(1)), str2double(inputs(2)), str2double(inputs(3))];
            end

            % get Wall coefficients
            promt = {"Left wall:", "Right wall:", "Front wall:", "Back wall:", "Floor:", "Ceiling:"};
            title = "Absorption coefficients of walls";
            dims = [1 80];
            defaultValues = {'', '', '', '', '', ''};

            inputs = inputdlg(promt, title, dims, defaultValues);
            if ~isempty(inputs)
            WallCoeff = [str2double(inputs(1)), str2double(inputs(2)), str2double(inputs(3)), str2double(inputs(4)), str2double(inputs(5)), str2double(inputs(6))];
            end

            % get max reverb. time and sampling rate
            promt = {"max reverb. time:", "sampling rate:"};
            title = "Max reverb. time and sampling rate";
            dims = [1 80];
            defaultValues = {'', ''};

            inputs = inputdlg(promt, title, dims, defaultValues);
            if ~isempty(inputs)
            maxReverbTime = str2double(inputs(1));
            samplingRate = str2double(inputs(2));
            end
            
            % Check if all parameters have been entered and call
            % IRfromCuboid funtion
            if ~isempty(roomDimensions) && ~isempty(Source) && ~isempty(Receiver) && ~isempty(WallCoeff) && ~isempty(maxReverbTime) && ~isempty(samplingRate)
                 [IRdata, imageSourceCoords]  = IRfromCuboid(roomDimensions, Source, Receiver, maxReverbTime, WallCoeff, samplingRate);
                 app.impulseResponseData = IRdata;
                 app.F_s_2 = samplingRate;
                
                 % Update impulse response time-domain plot and spectrum
                 % plot of main GUI
                 if ~isempty(app.impulseResponseData)
                    L = length(app.impulseResponseData);
                    t=(0:L-1)*(1/app.F_s_2);
                    
                    plot(app.TimeDomainAxes_2, t, app.impulseResponseData);
                    
                    y_freqDomain = fft(app.impulseResponseData);
                    plot(app.FreqDomainAxes_2, (0:L-1)*(app.F_s_2/L), abs(fftshift(y_freqDomain)));
                 end
                
                 % If box for image source plotting is ticked, call
                 % plotImagesources() function
                 if app.PlotimagesourcesCheckBox.Value
                    plotImageSources(roomDimensions, Receiver, Source, imageSourceCoords, app.ShowraytracesCheckBox.Value);
                 end
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 857 709];
            app.UIFigure.Name = 'MATLAB App';

            % Create TimeDomainAxes
            app.TimeDomainAxes = uiaxes(app.UIFigure);
            title(app.TimeDomainAxes, 'Time domain')
            xlabel(app.TimeDomainAxes, 't / s')
            ylabel(app.TimeDomainAxes, 'Amplitude')
            zlabel(app.TimeDomainAxes, 'Z')
            app.TimeDomainAxes.XGrid = 'on';
            app.TimeDomainAxes.YGrid = 'on';
            app.TimeDomainAxes.ButtonDownFcn = createCallbackFcn(app, @TimeDomainAxesButtonDown, true);
            app.TimeDomainAxes.Position = [24 241 300 185];

            % Create FreqDomainAxes
            app.FreqDomainAxes = uiaxes(app.UIFigure);
            title(app.FreqDomainAxes, 'Frequency domain')
            xlabel(app.FreqDomainAxes, 'f / Hz')
            ylabel(app.FreqDomainAxes, 'Magnitude')
            zlabel(app.FreqDomainAxes, 'Z')
            app.FreqDomainAxes.XGrid = 'on';
            app.FreqDomainAxes.YGrid = 'on';
            app.FreqDomainAxes.Position = [493 241 300 185];

            % Create TimeDomainAxes_2
            app.TimeDomainAxes_2 = uiaxes(app.UIFigure);
            title(app.TimeDomainAxes_2, 'Time domain - Impulse Response')
            xlabel(app.TimeDomainAxes_2, 't / s')
            ylabel(app.TimeDomainAxes_2, 'Amplitude')
            zlabel(app.TimeDomainAxes_2, 'Z')
            app.TimeDomainAxes_2.XGrid = 'on';
            app.TimeDomainAxes_2.YGrid = 'on';
            app.TimeDomainAxes_2.Position = [23 38 300 185];

            % Create FreqDomainAxes_2
            app.FreqDomainAxes_2 = uiaxes(app.UIFigure);
            title(app.FreqDomainAxes_2, 'Frequency domain - impulse response')
            xlabel(app.FreqDomainAxes_2, 'f / Hz')
            ylabel(app.FreqDomainAxes_2, 'Magnitude')
            zlabel(app.FreqDomainAxes_2, 'Z')
            app.FreqDomainAxes_2.XGrid = 'on';
            app.FreqDomainAxes_2.YGrid = 'on';
            app.FreqDomainAxes_2.Position = [492 38 300 185];

            % Create InputsourceDropDownLabel
            app.InputsourceDropDownLabel = uilabel(app.UIFigure);
            app.InputsourceDropDownLabel.HorizontalAlignment = 'right';
            app.InputsourceDropDownLabel.FontWeight = 'bold';
            app.InputsourceDropDownLabel.Position = [32 644 77 22];
            app.InputsourceDropDownLabel.Text = 'Input source';

            % Create InputDropDown
            app.InputDropDown = uidropdown(app.UIFigure);
            app.InputDropDown.Items = {'Audiofile', 'Microphone'};
            app.InputDropDown.ValueChangedFcn = createCallbackFcn(app, @InputDropDownValueChanged, true);
            app.InputDropDown.Position = [21 623 100 22];
            app.InputDropDown.Value = 'Audiofile';

            % Create OutputDropDownLabel
            app.OutputDropDownLabel = uilabel(app.UIFigure);
            app.OutputDropDownLabel.HorizontalAlignment = 'right';
            app.OutputDropDownLabel.FontWeight = 'bold';
            app.OutputDropDownLabel.Position = [48 502 48 22];
            app.OutputDropDownLabel.Text = 'Output ';

            % Create OutputDropDown
            app.OutputDropDown = uidropdown(app.UIFigure);
            app.OutputDropDown.Items = {'Speaker', 'Free Lossless Audio Codec (flac)', 'Microsoft WAVE sound (wav)'};
            app.OutputDropDown.ValueChangedFcn = createCallbackFcn(app, @OutputDropDownValueChanged, true);
            app.OutputDropDown.Position = [22 472 100 22];
            app.OutputDropDown.Value = 'Speaker';

            % Create ReadAudioButton
            app.ReadAudioButton = uibutton(app.UIFigure, 'push');
            app.ReadAudioButton.ButtonPushedFcn = createCallbackFcn(app, @ReadAudioButtonPushed, true);
            app.ReadAudioButton.Position = [139 622 100 23];
            app.ReadAudioButton.Text = 'Read audio';

            % Create WriteAudioButton
            app.WriteAudioButton = uibutton(app.UIFigure, 'push');
            app.WriteAudioButton.ButtonPushedFcn = createCallbackFcn(app, @WriteAudioButtonPushed, true);
            app.WriteAudioButton.Position = [140 471 100 23];
            app.WriteAudioButton.Text = 'Write audio';

            % Create ReadAudioField
            app.ReadAudioField = uieditfield(app.UIFigure, 'text');
            app.ReadAudioField.Position = [256 623 100 22];

            % Create WriteAudioField
            app.WriteAudioField = uieditfield(app.UIFigure, 'text');
            app.WriteAudioField.Position = [257 471 100 22];

            % Create StartStopRecordingButton
            app.StartStopRecordingButton = uibutton(app.UIFigure, 'push');
            app.StartStopRecordingButton.ButtonPushedFcn = createCallbackFcn(app, @StartStopRecordingButtonPushed, true);
            app.StartStopRecordingButton.Visible = 'off';
            app.StartStopRecordingButton.Position = [139 622 100 23];
            app.StartStopRecordingButton.Text = 'Start / Stop ';

            % Create ConvolutionButton
            app.ConvolutionButton = uibutton(app.UIFigure, 'push');
            app.ConvolutionButton.ButtonPushedFcn = createCallbackFcn(app, @ConvolutionButtonPushed, true);
            app.ConvolutionButton.Position = [555 575 100 23];
            app.ConvolutionButton.Text = 'Convolution';

            % Create ReadAudioButton_2
            app.ReadAudioButton_2 = uibutton(app.UIFigure, 'push');
            app.ReadAudioButton_2.ButtonPushedFcn = createCallbackFcn(app, @ReadAudioButton_2Pushed, true);
            app.ReadAudioButton_2.Position = [139 579 100 23];
            app.ReadAudioButton_2.Text = 'Read audio';

            % Create ReadAudioField_2
            app.ReadAudioField_2 = uieditfield(app.UIFigure, 'text');
            app.ReadAudioField_2.Position = [256 580 100 22];

            % Create Inputsource2Label
            app.Inputsource2Label = uilabel(app.UIFigure);
            app.Inputsource2Label.HorizontalAlignment = 'right';
            app.Inputsource2Label.FontWeight = 'bold';
            app.Inputsource2Label.Position = [17 601 107 22];
            app.Inputsource2Label.Text = 'Impulse response';

            % Create InputDropDown_2
            app.InputDropDown_2 = uidropdown(app.UIFigure);
            app.InputDropDown_2.Items = {'File', 'Echo', 'St. Andrews London', 'Image Source Method'};
            app.InputDropDown_2.ValueChangedFcn = createCallbackFcn(app, @InputDropDown_2ValueChanged, true);
            app.InputDropDown_2.Position = [21 580 100 22];
            app.InputDropDown_2.Value = 'File';

            % Create ConvolutionField
            app.ConvolutionField = uieditfield(app.UIFigure, 'text');
            app.ConvolutionField.Position = [705 618 100 22];

            % Create ConvolutiontypeLabel
            app.ConvolutiontypeLabel = uilabel(app.UIFigure);
            app.ConvolutiontypeLabel.HorizontalAlignment = 'right';
            app.ConvolutiontypeLabel.FontWeight = 'bold';
            app.ConvolutiontypeLabel.Position = [552 638 103 28];
            app.ConvolutiontypeLabel.Text = 'Convolution type';

            % Create InputDropDown_3
            app.InputDropDown_3 = uidropdown(app.UIFigure);
            app.InputDropDown_3.Items = {'Fast convolution', 'Overlap-Save FFT-Conv.', 'Time Domain Convolution'};
            app.InputDropDown_3.ValueChangedFcn = createCallbackFcn(app, @InputDropDown_3ValueChanged, true);
            app.InputDropDown_3.Position = [525 618 158 22];
            app.InputDropDown_3.Value = 'Fast convolution';

            % Create ConvolutionTimeField
            app.ConvolutionTimeField = uieditfield(app.UIFigure, 'text');
            app.ConvolutionTimeField.Position = [705 575 100 22];

            % Create BlocksizeLabel
            app.BlocksizeLabel = uilabel(app.UIFigure);
            app.BlocksizeLabel.HorizontalAlignment = 'right';
            app.BlocksizeLabel.Visible = 'off';
            app.BlocksizeLabel.Position = [587 533 59 22];
            app.BlocksizeLabel.Text = 'Block size';

            % Create BlocksizeEditField
            app.BlocksizeEditField = uieditfield(app.UIFigure, 'numeric');
            app.BlocksizeEditField.ValueChangedFcn = createCallbackFcn(app, @BlocksizeEditFieldValueChanged, true);
            app.BlocksizeEditField.Visible = 'off';
            app.BlocksizeEditField.Position = [705 533 100 22];
            app.BlocksizeEditField.Value = 1048576;

            % Create ResampleInput
            app.ResampleInput = uibutton(app.UIFigure, 'push');
            app.ResampleInput.ButtonPushedFcn = createCallbackFcn(app, @ResampleInputButtonPushed, true);
            app.ResampleInput.Position = [369 622 76 23];
            app.ResampleInput.Text = 'Resample';

            % Create ResampleIR
            app.ResampleIR = uibutton(app.UIFigure, 'push');
            app.ResampleIR.ButtonPushedFcn = createCallbackFcn(app, @ResampleIRButtonPushed, true);
            app.ResampleIR.Position = [369 579 76 24];
            app.ResampleIR.Text = 'Resample';

            % Create Render
            app.Render = uibutton(app.UIFigure, 'push');
            app.Render.ButtonPushedFcn = createCallbackFcn(app, @RenderButtonPushed, true);
            app.Render.Visible = 'off';
            app.Render.Position = [140 579 100 23];
            app.Render.Text = 'Render';

            % Create PlotimagesourcesCheckBox
            app.PlotimagesourcesCheckBox = uicheckbox(app.UIFigure);
            app.PlotimagesourcesCheckBox.Visible = 'off';
            app.PlotimagesourcesCheckBox.Text = 'Plot image sources';
            app.PlotimagesourcesCheckBox.Position = [25 544 124 22];

            % Create ShowraytracesCheckBox
            app.ShowraytracesCheckBox = uicheckbox(app.UIFigure);
            app.ShowraytracesCheckBox.Visible = 'off';
            app.ShowraytracesCheckBox.Text = 'Show raytraces';
            app.ShowraytracesCheckBox.Position = [154 544 105 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GUI

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end