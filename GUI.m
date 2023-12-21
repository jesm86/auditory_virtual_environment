%% GUI starting point of the project. Not yet properly commented because constantly changing. 
% Please read readme.txt For short introduction.

classdef GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        RecordRTSpatializationButton  matlab.ui.control.Button
        ResampleHRIRsetButton         matlab.ui.control.Button
        TabGroup                      matlab.ui.container.TabGroup
        PlotsTab                      matlab.ui.container.Tab
        FreqDomainAxes                matlab.ui.control.UIAxes
        FreqDomainAxes_2              matlab.ui.control.UIAxes
        TimeDomainAxes_2              matlab.ui.control.UIAxes
        TimeDomainAxes                matlab.ui.control.UIAxes
        RoomTab                       matlab.ui.container.Tab
        ReceiverXField                matlab.ui.control.NumericEditField
        ReceiverYField                matlab.ui.control.NumericEditField
        YLabel_2                      matlab.ui.control.Label
        ReceiverZField                matlab.ui.control.NumericEditField
        ZLabel_2                      matlab.ui.control.Label
        XEditFieldLabel_2             matlab.ui.control.Label
        SourceXField                  matlab.ui.control.NumericEditField
        SourceYField                  matlab.ui.control.NumericEditField
        YLabel                        matlab.ui.control.Label
        SourceZField                  matlab.ui.control.NumericEditField
        ZLabel                        matlab.ui.control.Label
        GITLabel                      matlab.ui.control.Label
        KeystrokesButton              matlab.ui.control.Button
        ReceiverLabel                 matlab.ui.control.Label
        SourceLabel                   matlab.ui.control.Label
        ApplyButton                   matlab.ui.control.Button
        RTPlot                        matlab.ui.control.UIAxes
        ButtonLoadHRIR                matlab.ui.control.Button
        RTButtonConv                  matlab.ui.control.Button
        RTButtonStartStop             matlab.ui.control.Button
        ShowraytracesCheckBox         matlab.ui.control.CheckBox
        PlotimagesourcesCheckBox      matlab.ui.control.CheckBox
        Render                        matlab.ui.control.Button
        ResampleIR                    matlab.ui.control.Button
        ResampleInput                 matlab.ui.control.Button
        BlocksizeEditField            matlab.ui.control.NumericEditField
        BlocksizeLabel                matlab.ui.control.Label
        ConvolutionTimeField          matlab.ui.control.EditField
        InputDropDown_3               matlab.ui.control.DropDown
        ConvolutionField              matlab.ui.control.EditField
        InputDropDown_2               matlab.ui.control.DropDown
        Inputsource2Label             matlab.ui.control.Label
        ReadAudioField_2              matlab.ui.control.EditField
        ConvolutionButton             matlab.ui.control.Button
        ReadAudioButton_2             matlab.ui.control.Button
        StartStopRecordingButton      matlab.ui.control.Button
        WriteAudioField               matlab.ui.control.EditField
        ReadAudioField                matlab.ui.control.EditField
        WriteAudioButton              matlab.ui.control.Button
        ReadAudioButton               matlab.ui.control.Button
        OutputDropDown                matlab.ui.control.DropDown
        OutputDropDownLabel           matlab.ui.control.Label
        InputDropDown                 matlab.ui.control.DropDown
        InputsourceDropDownLabel      matlab.ui.control.Label
    end

        properties (Access = private)
        audioData                                       % vector with audiodata of input source (mic or file)
        F_s = 16000;                                    % sampling frequency of input data
        impulseResponseData                   % vector with data of impulse response 
        F_s_2 = 16000;                               % sampling frequency of impulse response
        hrir_fullset                                      % full set of HRIR provided by MIT
        current_hrir_left;                              % current pair of HRIR (1: left ear, 2: right ear)
        current_hrir_right;
        convolvedSignalData                     % result of convolution of input & impulse response
        convolvedSignalData_left
        convolvedSignalData_right
        F_s_3                                             % sampling frequency of result
        boRecordingFlag1 = false;             % boolean indicating if system is recording
        recorder = audiorecorder(16000, 16, 1); % Object of class audiorecorder for recording audio
                                                                        % with microphone. Sampling rate will be 44,1kHz
                                                                        % 16 bit quantization and 1 channel
        hrir_set;                                                   % Full set of loaded HRIR by MIT
        Wallcoefs;                                               % Wall coefficients
        Room_dimensions;                                 % Room dimensions
        Source;                                                   % Source room coordinates
        Receiver;                                                % Receiver room coordinates
        facingDirection;
        currentPosAngles;                                  % current positional angles (1: elevation angle, 2: azimuth angle)
        boStopRTRecordingFlag = false;
        t_reverb;
        roomType;
        boKeystrokeActive = false;
        boResampledHrirFlag = false;
        playRec;
    end
    
    methods (Access = private)
        
        function computeFinalImpulseResponse(app)
            if isempty(app.facingDirection)
                app.facingDirection = [1, 0, 0];
            end
            [app.currentPosAngles(1), app.currentPosAngles(2)] = getElevationAndAzimuth(app.Source, app.Receiver, app.facingDirection);
            [elevationIndices(1), elevationIndices(2), azimuthIndices(1,1), azimuthIndices(1,2), azimuthIndices(1,3), azimuthIndices(1,4), elevalues, azimvalues(1,:)] = findHRIRindex(app.currentPosAngles(1), app.currentPosAngles(2));
            [~, ~, azimuthIndices(2,1), azimuthIndices(2,2), azimuthIndices(2,3), azimuthIndices(2,4), ~, azimvalues(2,:)] = findHRIRindex(app.currentPosAngles(1), (360 - app.currentPosAngles(2)));            
            for i = 1:floor((512/(44100/app.F_s_2)))
                app.current_hrir_left(i) = interpolateN([app.hrir_fullset{elevationIndices(1)}{azimuthIndices(1,1)}(i), app.hrir_fullset{elevationIndices(1)}{azimuthIndices(1,2)}(i)],...
                                                                      [app.hrir_fullset{elevationIndices(2)}{azimuthIndices(1,3)}(i), app.hrir_fullset{elevationIndices(2)}{azimuthIndices(1,4)}(i)],...
                                                                      [elevalues(1), elevalues(2)],[azimvalues(1,1), azimvalues(1,2)], [azimvalues(1,3), azimvalues(1,4)], app.currentPosAngles(1), app.currentPosAngles(2));
                app.current_hrir_right(i) = interpolateN([app.hrir_fullset{elevationIndices(1)}{azimuthIndices(2,1)}(i), app.hrir_fullset{elevationIndices(1)}{azimuthIndices(2,2)}(i)],...
                                                                      [app.hrir_fullset{elevationIndices(2)}{azimuthIndices(2,3)}(i), app.hrir_fullset{elevationIndices(2)}{azimuthIndices(2,4)}(i)],...
                                                                      [elevalues(1), elevalues(2)],[azimvalues(2,1), azimvalues(2,2)], [azimvalues(3), azimvalues(2,4)], app.currentPosAngles(1), (360 - app.currentPosAngles(2)));
            end 
            app.convolvedSignalData_left  =    transpose(app.current_hrir_left);
            app.convolvedSignalData_right =    transpose(app.current_hrir_right);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: ReadAudioButton
        function ReadAudioButtonPushed(app, event)
            [boFileRead, timeDomain, f_s] = readAudiofile;  % call function to read audio file
            if true == boFileRead                                           % if successful: save data and f_s          
                    app.ReadAudioField.Value = 'file read';            
                    app.audioData= timeDomain;
                    app.F_s = f_s;            
                    L = length(app.audioData);
                    t=(0:L-1)*(1/app.F_s);            
                    plot(app.TimeDomainAxes, t, app.audioData); % plot in time domain
                    y_freqDomain = fft(app.audioData);                                % fft to plot spectra as well
                    plot(app.FreqDomainAxes, (0:L-1)*(app.F_s/L), abs(fftshift(y_freqDomain)));
                    app.ConvolutionField.Value = "ready";
            else 
                app.ReadAudioField.Value = 'failed';
            end
        end

        % Button pushed function: WriteAudioButton
        function WriteAudioButtonPushed(app, event)
            % write audiodata to file or speaker using writeAudiofile module
            try                                         
                if "finished" == app.ConvolutionField.Value
                    audio = app.convolvedSignalData;
                else
                    audio = app.audioData;
                end

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

        % Value changed function: InputDropDown
        function InputDropDownValueChanged(app, event)
            % Only show "Start Recording" or "Read file" button depending
            % on drop down menu
            if "Microphone" == app.InputDropDown.Value
                app.StartStopRecordingButton.Visible = "on";
                app.ReadAudioButton.Visible = "off"; 
                app.ResampleInput.Visible = "on";
                app.RTButtonStartStop.Visible = "off";
                app.InputDropDown_3.Visible = "on";
                app.RTButtonConv.Visible = "off";
                app.OutputDropDown.Visible = "on";
                app.WriteAudioButton.Visible = "on";
                app.WriteAudioField.Visible = "on";
                app.OutputDropDownLabel.Visible = "on";
                app.InputDropDown_3.Visible = "on";
                app.ConvolutionField.Visible = "on";
                app.ConvolutionTimeField.Visible = "on";
                app.RecordRTSpatializationButton.Visible = "off";
                app.ConvolutionButton.Visible = "on";
            elseif "Audiofile" == app.InputDropDown.Value
                app.StartStopRecordingButton.Visible = "off";
                app.ReadAudioButton.Visible = "on";
                app.ResampleInput.Visible = "on";
                app.RTButtonStartStop.Visible = "off";
                app.InputDropDown_3.Visible = "on";
                app.RTButtonConv.Visible = "off";
                app.OutputDropDown.Visible = "on";
                app.WriteAudioButton.Visible = "on";
                app.WriteAudioField.Visible = "on";
                app.OutputDropDownLabel.Visible = "on";
                app.InputDropDown_3.Visible = "on";
                app.ConvolutionField.Visible = "on";
                app.ConvolutionTimeField.Visible = "on";
                app.RecordRTSpatializationButton.Visible = "off";
                app.ConvolutionButton.Visible = "on";
            elseif "Real-Time Microphone" == app.InputDropDown.Value
                app.StartStopRecordingButton.Visible = "off";
                app.ReadAudioButton.Visible = "off";
                app.ResampleInput.Visible = "off";
                app.RTButtonStartStop.Visible = "on";         
                app.InputDropDown_3.Visible = "off";
                app.RTButtonConv.Visible = "on";
                app.OutputDropDown.Visible = "off";
                app.WriteAudioButton.Visible = "off";
                app.WriteAudioField.Visible = "off";
                app.OutputDropDownLabel.Visible = "off";
                app.InputDropDown_3.Visible = "off";
                app.ConvolutionField.Visible = "off";
                app.ConvolutionTimeField.Visible = "off";
                app.RecordRTSpatializationButton.Visible = "on";
                app.ConvolutionButton.Visible = "off";
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
                app.F_s = 16000;
                app.boRecordingFlag1 = recordAudio(app.recorder, app.F_s, app.boRecordingFlag1);
                app.ReadAudioField.Value = "recording...";                
            elseif true == app.boRecordingFlag1
                app.boRecordingFlag1 = recordAudio(app.recorder, app.F_s, app.boRecordingFlag1);
                app.ReadAudioField.Value = "record finished";
                app.audioData= getaudiodata(app.recorder);
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
          L = length(app.convolvedSignalData);
          t=(0:L-1)*(1/app.F_s);

          plot(app.TimeDomainAxes, t, app.convolvedSignalData);

          y_freqDomain = fft(app.convolvedSignalData);
          plot(app.FreqDomainAxes, (0:L-1)*(app.F_s/L), abs(fftshift(y_freqDomain)));
        end

        % Button pushed function: ReadAudioButton_2
        function ReadAudioButton_2Pushed(app, event)
            %Functionality to read in impulse response from a file
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

        % Button pushed function: ResampleInput
        function ResampleInputButtonPushed(app, event)
            promt = 'Enter sample rate for resampling of input signal:';
            title = "Resampling of input signal";
            dims = [1 60];
            defaultValue = {''};
            inputValue = inputdlg(promt, title, dims, defaultValue);

            if isempty(inputValue)
            else
                targetFreq =  str2double(inputValue);
                app.audioData = resample(app.audioData, targetFreq, app.F_s);
                app.F_s = targetFreq;

                L = length(app.audioData);
                t=(0:L-1)*(1/app.F_s);            
                plot(app.TimeDomainAxes, t, app.audioData); % plot in time domain
                y_freqDomain = fft(app.audioData);                                % fft to plot spectra as well
                plot(app.FreqDomainAxes, (0:L-1)*(app.F_s/L), abs(fftshift(y_freqDomain)));
            end

        end

        % Button pushed function: ResampleIR
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

        % Button pushed function: Render
        function RenderButtonPushed(app, event)
            popup = uifigure("Name", "Choose room type", "Position", [100, 100, 300, 200]);
            dropdownLabel = uilabel(popup, 'Text', 'Select a room', 'Position', [10, 130, 150, 22]);
            dropdown = uidropdown(popup, "Items", {'100x100x100, high reflection', '100x100x100, low reflection','300x300x300, high reflection', '300x300x300, low reflection', 'Custom'}, "Position", [150, 130, 150, 22]);
            reverbTFieldLabel = uilabel(popup, 'Text', 'Reverberation time [s]:', 'Position', [10, 70, 150, 22]);
            reverbT_field  = uieditfield(popup, 'numeric', 'Position', [150, 70, 50, 22], 'Value', 0);
            sampleRFieldLabel = uilabel(popup, 'Text', 'Sample rate [Hz]:', 'Position', [10, 100, 150, 22]);
            sampleR_field = uieditfield(popup, 'numeric', 'Position', [150, 100, 50, 22], 'Value', 0);
            popupButton = uibutton(popup, "Text", "Ok", "Position", [95, 20, 60, 22], 'ButtonPushedFcn', @(~,~) popupButtonPushedFcn(popup, dropdown, reverbT_field, sampleR_field));
            
            function popupButtonPushedFcn(popup, dropdown, reverbT_field, sampleR_field)
                app.t_reverb = reverbT_field.Value;
                app.F_s_2 = sampleR_field.Value;
                app.roomType = dropdown.Value;
                cla(app.RTPlot);
                close(popup);
            end
            waitfor(popup);

            if strcmp("Custom", app.roomType)
                % get room dimensions
                promt = {"Room length:", "Room width:", "Room height:"};
                title = "Enter room dimensions";
                dims = [1 80];
                defaultValues = {'', '', ''};
    
                inputs = inputdlg(promt, title, dims, defaultValues);
                if ~isempty(inputs)
                app.Room_dimensions = [str2double(inputs(1)), str2double(inputs(2)), str2double(inputs(3))];
                end
                
                % get source position
                promt = {"Source x coord:", "Source y coord:", "Source z coord:"};
                title = "Source location in room";
                dims = [1 80];
                defaultValues = {'', '', ''};
    
                inputs = inputdlg(promt, title, dims, defaultValues);
                if ~isempty(inputs)
                app.Source = [str2double(inputs(1)), str2double(inputs(2)), str2double(inputs(3))];
                end
    
                % get source position
                promt = {"Receiver x coord:", "Receiver y coord:", "Receiver z coord:"};
                title = "Receiver location in room";
                dims = [1 80];
                defaultValues = {'', '', ''};
    
                inputs = inputdlg(promt, title, dims, defaultValues);
                if ~isempty(inputs)
                app.Receiver = [str2double(inputs(1)), str2double(inputs(2)), str2double(inputs(3))];
                end
    
                % get Wall coefficients
                promt = {"Left wall:", "Right wall:", "Front wall:", "Back wall:", "Floor:", "Ceiling:"};
                title = "Absorption coefficients of walls";
                dims = [1 80];
                defaultValues = {'', '', '', '', '', ''};
    
                inputs = inputdlg(promt, title, dims, defaultValues);
                if ~isempty(inputs)
                app.Wallcoefs = [str2double(inputs(1)), str2double(inputs(2)), str2double(inputs(3)), str2double(inputs(4)), str2double(inputs(5)), str2double(inputs(6))];
                end
            elseif strcmp('100x100x100, high reflection', app.roomType)
                app.Room_dimensions = [100, 100, 100];
                app.Source = [50, 50, 50];
                app.Receiver = [1, 55, 50];
                app.Wallcoefs = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2];

            elseif strcmp('100x100x100, low reflection', app.roomType)
                app.Room_dimensions = [100, 100, 100];
                app.Source = [50, 50, 50];
                app.Receiver = [1, 55, 50];
                app.Wallcoefs = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
            elseif strcmp('300x300x300, high reflection', app.roomType)
                app.Room_dimensions = [300, 300, 300];
                app.Source = [150, 150, 150];
                app.Receiver = [10, 155, 150];
                app.Wallcoefs = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2];          
            elseif strcmp('300x300x300, low reflection', app.roomType)
                app.Room_dimensions = [300, 300, 300];
                app.Source = [150, 150, 150];
                app.Receiver = [10, 155, 150];
                app.Wallcoefs = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1];     
            else
                return
            end

            if ~isempty(app.Room_dimensions) && ~isempty(app.Source) && ~isempty(app.Receiver) && ~isempty(app.Wallcoefs) && ~isempty(app.t_reverb) && ~isempty(app.F_s_2)
                 [IRdata, imageSourceCoords]  = IRfromCuboid(app.Room_dimensions, app.Source, app.Receiver, app.t_reverb, app.Wallcoefs, app.F_s_2);
                 app.SourceXField.Value = app.Source(1);
                 app.SourceYField.Value = app.Source(2);
                 app.SourceZField.Value = app.Source(3);
                 app.ReceiverXField.Value = app.Receiver(1);
                 app.ReceiverYField.Value = app.Receiver(2);
                 app.ReceiverZField.Value = app.Receiver(3);
                 app.impulseResponseData = IRdata;

                 if ~isempty(app.impulseResponseData)
                    L = length(app.impulseResponseData);
                    t=(0:L-1)*(1/app.F_s_2);
                    
                    plot(app.TimeDomainAxes_2, t, app.impulseResponseData);
                    
                    y_freqDomain = fft(app.impulseResponseData);
                    plot(app.FreqDomainAxes_2, (0:L-1)*(app.F_s_2/L), abs(fftshift(y_freqDomain)));
                 end

                 if app.PlotimagesourcesCheckBox.Value
                    plotImageSources(app.Room_dimensions, app.Receiver, app.Source, imageSourceCoords, app.ShowraytracesCheckBox.Value, app.RTPlot);
                 else
                    plotRoom(app.Room_dimensions, app.Receiver, app.Source, app.RTPlot);
                    app.RTPlot.Visible = "on";
                 end
                
            end
        end

        % Button pushed function: ButtonLoadHRIR
        function ButtonLoadHRIRPushed(app, event)
            app.boResampledHrirFlag = false;
            app.ResampleHRIRsetButton.Visible = "on";
            app.hrir_fullset  = readHRIR("./impulse_responses//HRTF_full/");


        end

        % Button pushed function: RTButtonConv
        function RTButtonConvPushed(app, event)
            app.boStopRTRecordingFlag = false;
            app.playRec = audioPlayerRecorder(app.F_s_2);
            app.playRec.PlayerChannelMapping = [1, 2];
            blocks = 1024;
            computeFinalImpulseResponse(app);
            [audioOverlap(:,1), output(:,1)] = prepareBlocks(blocks, app.convolvedSignalData_left);
            [audioOverlap(:,2), output(:,2)] = prepareBlocks(blocks, app.convolvedSignalData_right); 
            if ~isempty(app.impulseResponseData)
                while ~app.boStopRTRecordingFlag
                    input = app.playRec([output(:,1), output(:,2)]);
                    [output(:,1), audioOverlap(:,1)] = realTimeConvAndOutput(input, audioOverlap(:,1),  app.current_hrir_right, blocks);
                    [output(:,2), audioOverlap(:,2)] = realTimeConvAndOutput(input, audioOverlap(:,2),  app.current_hrir_left, blocks);
                    pause(0.01);
                end
            end
            release(app.playRec);
        end

        % Button pushed function: RTButtonStartStop
        function RTButtonStartStopPushed(app, event)
            app.boStopRTRecordingFlag = true;
       
        end

        % Button pushed function: ApplyButton
        function ApplyButtonPushed(app, event)
            if ~isempty(app.SourceXField.Value)
                app.Source(1) = app.SourceXField.Value;
            end
            if ~isempty(app.SourceYField.Value)
                app.Source(2) = app.SourceYField.Value;
            end
            if ~isempty(app.SourceZField.Value)
                app.Source(3) = app.SourceZField.Value;
            end            
            if ~isempty(app.ReceiverXField.Value)
                app.Receiver(1) = app.ReceiverXField.Value;
            end
            if ~isempty(app.ReceiverYField.Value)
                app.Source(2) = app.ReceiverYField.Value;
            end
            if ~isempty(app.ReceiverZField.Value)
                app.Source(3) = app.ReceiverZField.Value;
            end          
            [app.impulseResponseData, imageSourceCoords]  = IRfromCuboid(app.Room_dimensions, app.Source, app.Receiver, app.t_reverb, app.Wallcoefs, app.F_s_2);
            cla(app.RTPlot);
            computeFinalImpulseResponse(app);
            if app.PlotimagesourcesCheckBox.Value
                plotImageSources(app.Room_dimensions, app.Receiver, app.Source, imageSourceCoords, app.ShowraytracesCheckBox.Value, app.RTPlot);
            else
                plotRoom(app.Room_dimensions, app.Receiver, app.Source, app.RTPlot);
                app.RTPlot.Visible = "on";
            end

            L = length(app.impulseResponseData);
            t=(0:L-1)*(1/app.F_s_2);
            
            plot(app.TimeDomainAxes_2, t, app.impulseResponseData);
            
            y_freqDomain = fft(app.impulseResponseData);
            plot(app.FreqDomainAxes_2, (0:L-1)*(app.F_s_2/L), abs(fftshift(y_freqDomain)));
        end

        % Button pushed function: KeystrokesButton
        function KeystrokesButtonPushed(app, event)
            if ~app.boKeystrokeActive
                app.boKeystrokeActive = true;
                app.KeystrokesButton.Text = 'Deactivate';
            else
                app.boKeystrokeActive = false;
                app.KeystrokesButton.Text = 'Keystrokes';
            end
        end

        % Key press function: UIFigure
        function UIFigureKeyPress(app, event)
            if app.boKeystrokeActive
                [app.Source, app.Receiver] = keystrokeCoordUpdate(app.Source, app.Receiver, app.Room_dimensions, event);
                [app.impulseResponseData, imageSourceCoords]  = IRfromCuboid(app.Room_dimensions, app.Source, app.Receiver, app.t_reverb, app.Wallcoefs, app.F_s_2);
                           
                cla(app.RTPlot);
                 if app.PlotimagesourcesCheckBox.Value
                    plotImageSources(app.Room_dimensions, app.Receiver, app.Source, imageSourceCoords, app.ShowraytracesCheckBox.Value, app.RTPlot);
                 else
                    plotRoom(app.Room_dimensions, app.Receiver, app.Source, app.RTPlot);
                 end
                computeFinalImpulseResponse(app);
                app.RTPlot.Visible = "on";
            end
            
        end

        % Button down function: RTPlot
        function RTPlotButtonDown(app, event)
            
        end

        % Button pushed function: ResampleHRIRsetButton
        function ResampleHRIRsetButtonPushed(app, event)
            app.boResampledHrirFlag = true;
            if ~isempty(app.hrir_fullset)
                app.ResampleHRIRsetButton.Visible = "off";
                for i = 1:length(app.hrir_fullset(:,1))
                    for j = 1:length(app.hrir_fullset{i})
                        app.hrir_fullset{i}{j} = resample(app.hrir_fullset{i}{j}, app.F_s_2, 44100);
                    end
                end
            end
            app.hrir_fullset = transpose(app.hrir_fullset);
        end

        % Value changed function: WriteAudioField
        function WriteAudioFieldValueChanged(app, event)

            
        end

        % Button pushed function: RecordRTSpatializationButton
        function RecordRTSpatializationButtonPushed(app, event)
            app.boStopRTRecordingFlag = false;
            app.playRec = audioPlayerRecorder(app.F_s_2);
            app.playRec.PlayerChannelMapping = [1, 2];
            blocks = 1024;
            audiofile_left = [];
            audiofile_right = [];
            computeFinalImpulseResponse(app);
            [audioOverlap(:,1), output(:,1)] = prepareBlocks(blocks, app.convolvedSignalData_left);
            [audioOverlap(:,2), output(:,2)] = prepareBlocks(blocks, app.convolvedSignalData_right); 
            if ~isempty(app.impulseResponseData)
                while ~app.boStopRTRecordingFlag
                    input = app.playRec(output);
                    [output(:,1), audioOverlap(:,1)] = realTimeConvAndOutput(input, audioOverlap(:,1),  app.current_hrir_left, blocks);
                    [output(:,2), audioOverlap(:,2)] = realTimeConvAndOutput(input, audioOverlap(:,2),  app.current_hrir_right, blocks);
                    audiofile_left = [audiofile_left; output(:,1)];
                    audiofile_right = [audiofile_right; output(:,2)];                    
                    pause(0.01);
                end
            end
            release(app.playRec);
            audiofile = [audiofile_left, audiofile_right];
            % writeAudiofile("wav", audiofile, app.F_s_2);
            audiowrite("audiofile.wav", audiofile, app.F_s_2);
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
            app.UIFigure.KeyPressFcn = createCallbackFcn(app, @UIFigureKeyPress, true);

            % Create InputsourceDropDownLabel
            app.InputsourceDropDownLabel = uilabel(app.UIFigure);
            app.InputsourceDropDownLabel.HorizontalAlignment = 'right';
            app.InputsourceDropDownLabel.FontWeight = 'bold';
            app.InputsourceDropDownLabel.Position = [32 644 77 22];
            app.InputsourceDropDownLabel.Text = 'Input source';

            % Create InputDropDown
            app.InputDropDown = uidropdown(app.UIFigure);
            app.InputDropDown.Items = {'Audiofile', 'Microphone', 'Real-Time Microphone'};
            app.InputDropDown.ValueChangedFcn = createCallbackFcn(app, @InputDropDownValueChanged, true);
            app.InputDropDown.Position = [21 623 100 22];
            app.InputDropDown.Value = 'Audiofile';

            % Create OutputDropDownLabel
            app.OutputDropDownLabel = uilabel(app.UIFigure);
            app.OutputDropDownLabel.HorizontalAlignment = 'right';
            app.OutputDropDownLabel.FontWeight = 'bold';
            app.OutputDropDownLabel.Position = [50 472 48 22];
            app.OutputDropDownLabel.Text = 'Output ';

            % Create OutputDropDown
            app.OutputDropDown = uidropdown(app.UIFigure);
            app.OutputDropDown.Items = {'Speaker', 'Free Lossless Audio Codec (flac)', 'Microsoft WAVE sound (wav)'};
            app.OutputDropDown.ValueChangedFcn = createCallbackFcn(app, @OutputDropDownValueChanged, true);
            app.OutputDropDown.Position = [24 442 100 22];
            app.OutputDropDown.Value = 'Speaker';

            % Create ReadAudioButton
            app.ReadAudioButton = uibutton(app.UIFigure, 'push');
            app.ReadAudioButton.ButtonPushedFcn = createCallbackFcn(app, @ReadAudioButtonPushed, true);
            app.ReadAudioButton.Position = [139 622 100 23];
            app.ReadAudioButton.Text = 'Read audio';

            % Create WriteAudioButton
            app.WriteAudioButton = uibutton(app.UIFigure, 'push');
            app.WriteAudioButton.ButtonPushedFcn = createCallbackFcn(app, @WriteAudioButtonPushed, true);
            app.WriteAudioButton.Position = [139 442 100 23];
            app.WriteAudioButton.Text = 'Write audio';

            % Create ReadAudioField
            app.ReadAudioField = uieditfield(app.UIFigure, 'text');
            app.ReadAudioField.Position = [256 623 100 22];

            % Create WriteAudioField
            app.WriteAudioField = uieditfield(app.UIFigure, 'text');
            app.WriteAudioField.ValueChangedFcn = createCallbackFcn(app, @WriteAudioFieldValueChanged, true);
            app.WriteAudioField.Position = [256 442 100 22];

            % Create StartStopRecordingButton
            app.StartStopRecordingButton = uibutton(app.UIFigure, 'push');
            app.StartStopRecordingButton.ButtonPushedFcn = createCallbackFcn(app, @StartStopRecordingButtonPushed, true);
            app.StartStopRecordingButton.Visible = 'off';
            app.StartStopRecordingButton.Position = [139 622 100 23];
            app.StartStopRecordingButton.Text = 'Start / Stop ';

            % Create ReadAudioButton_2
            app.ReadAudioButton_2 = uibutton(app.UIFigure, 'push');
            app.ReadAudioButton_2.ButtonPushedFcn = createCallbackFcn(app, @ReadAudioButton_2Pushed, true);
            app.ReadAudioButton_2.Position = [139 579 100 23];
            app.ReadAudioButton_2.Text = 'Read audio';

            % Create ConvolutionButton
            app.ConvolutionButton = uibutton(app.UIFigure, 'push');
            app.ConvolutionButton.ButtonPushedFcn = createCallbackFcn(app, @ConvolutionButtonPushed, true);
            app.ConvolutionButton.Position = [555 575 100 23];
            app.ConvolutionButton.Text = 'Convolution';

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
            app.PlotimagesourcesCheckBox.Position = [23 544 124 22];

            % Create ShowraytracesCheckBox
            app.ShowraytracesCheckBox = uicheckbox(app.UIFigure);
            app.ShowraytracesCheckBox.Visible = 'off';
            app.ShowraytracesCheckBox.Text = 'Show raytraces';
            app.ShowraytracesCheckBox.Position = [154 544 105 22];

            % Create RTButtonStartStop
            app.RTButtonStartStop = uibutton(app.UIFigure, 'push');
            app.RTButtonStartStop.ButtonPushedFcn = createCallbackFcn(app, @RTButtonStartStopPushed, true);
            app.RTButtonStartStop.Visible = 'off';
            app.RTButtonStartStop.Position = [139 622 100 23];
            app.RTButtonStartStop.Text = 'Stop';

            % Create RTButtonConv
            app.RTButtonConv = uibutton(app.UIFigure, 'push');
            app.RTButtonConv.ButtonPushedFcn = createCallbackFcn(app, @RTButtonConvPushed, true);
            app.RTButtonConv.Visible = 'off';
            app.RTButtonConv.Position = [258 507 145 23];
            app.RTButtonConv.Text = 'Real-Time Spatialization';

            % Create ButtonLoadHRIR
            app.ButtonLoadHRIR = uibutton(app.UIFigure, 'push');
            app.ButtonLoadHRIR.ButtonPushedFcn = createCallbackFcn(app, @ButtonLoadHRIRPushed, true);
            app.ButtonLoadHRIR.Position = [24 507 100 23];
            app.ButtonLoadHRIR.Text = 'Load HRIR set';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [16 11 827 417];

            % Create PlotsTab
            app.PlotsTab = uitab(app.TabGroup);
            app.PlotsTab.Title = 'Plots';

            % Create TimeDomainAxes
            app.TimeDomainAxes = uiaxes(app.PlotsTab);
            title(app.TimeDomainAxes, 'Time domain')
            xlabel(app.TimeDomainAxes, 't / s')
            ylabel(app.TimeDomainAxes, 'Amplitude')
            zlabel(app.TimeDomainAxes, 'Z')
            app.TimeDomainAxes.XGrid = 'on';
            app.TimeDomainAxes.YGrid = 'on';
            app.TimeDomainAxes.ButtonDownFcn = createCallbackFcn(app, @TimeDomainAxesButtonDown, true);
            app.TimeDomainAxes.Position = [4 206 300 185];

            % Create TimeDomainAxes_2
            app.TimeDomainAxes_2 = uiaxes(app.PlotsTab);
            title(app.TimeDomainAxes_2, 'Time domain - Impulse Response')
            xlabel(app.TimeDomainAxes_2, 't / s')
            ylabel(app.TimeDomainAxes_2, 'Amplitude')
            zlabel(app.TimeDomainAxes_2, 'Z')
            app.TimeDomainAxes_2.XGrid = 'on';
            app.TimeDomainAxes_2.YGrid = 'on';
            app.TimeDomainAxes_2.Position = [4 10 300 185];

            % Create FreqDomainAxes_2
            app.FreqDomainAxes_2 = uiaxes(app.PlotsTab);
            title(app.FreqDomainAxes_2, 'Frequency domain - impulse response')
            xlabel(app.FreqDomainAxes_2, 'f / Hz')
            ylabel(app.FreqDomainAxes_2, 'Magnitude')
            zlabel(app.FreqDomainAxes_2, 'Z')
            app.FreqDomainAxes_2.XGrid = 'on';
            app.FreqDomainAxes_2.YGrid = 'on';
            app.FreqDomainAxes_2.Position = [466 10 300 185];

            % Create FreqDomainAxes
            app.FreqDomainAxes = uiaxes(app.PlotsTab);
            title(app.FreqDomainAxes, 'Frequency domain')
            xlabel(app.FreqDomainAxes, 'f / Hz')
            ylabel(app.FreqDomainAxes, 'Magnitude')
            zlabel(app.FreqDomainAxes, 'Z')
            app.FreqDomainAxes.XGrid = 'on';
            app.FreqDomainAxes.YGrid = 'on';
            app.FreqDomainAxes.Position = [466 208 300 185];

            % Create RoomTab
            app.RoomTab = uitab(app.TabGroup);
            app.RoomTab.Title = 'Room';

            % Create RTPlot
            app.RTPlot = uiaxes(app.RoomTab);
            title(app.RTPlot, 'Title')
            xlabel(app.RTPlot, 'X')
            ylabel(app.RTPlot, 'Y')
            zlabel(app.RTPlot, 'Z')
            app.RTPlot.ButtonDownFcn = createCallbackFcn(app, @RTPlotButtonDown, true);
            app.RTPlot.Visible = 'off';
            app.RTPlot.Position = [8 10 807 344];

            % Create ApplyButton
            app.ApplyButton = uibutton(app.RoomTab, 'push');
            app.ApplyButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyButtonPushed, true);
            app.ApplyButton.Position = [471 361 100 23];
            app.ApplyButton.Text = 'Apply';

            % Create SourceLabel
            app.SourceLabel = uilabel(app.RoomTab);
            app.SourceLabel.Position = [9 361 46 22];
            app.SourceLabel.Text = 'Source:';

            % Create ReceiverLabel
            app.ReceiverLabel = uilabel(app.RoomTab);
            app.ReceiverLabel.Position = [235 361 56 22];
            app.ReceiverLabel.Text = 'Receiver:';

            % Create KeystrokesButton
            app.KeystrokesButton = uibutton(app.RoomTab, 'push');
            app.KeystrokesButton.ButtonPushedFcn = createCallbackFcn(app, @KeystrokesButtonPushed, true);
            app.KeystrokesButton.Position = [705 360 100 23];
            app.KeystrokesButton.Text = 'Keystrokes';

            % Create GITLabel
            app.GITLabel = uilabel(app.RoomTab);
            app.GITLabel.HorizontalAlignment = 'right';
            app.GITLabel.Position = [48 361 25 22];
            app.GITLabel.Text = 'X';

            % Create ZLabel
            app.ZLabel = uilabel(app.RoomTab);
            app.ZLabel.HorizontalAlignment = 'right';
            app.ZLabel.Position = [150 361 25 22];
            app.ZLabel.Text = 'Z';

            % Create SourceZField
            app.SourceZField = uieditfield(app.RoomTab, 'numeric');
            app.SourceZField.Position = [179 361 35 22];

            % Create YLabel
            app.YLabel = uilabel(app.RoomTab);
            app.YLabel.HorizontalAlignment = 'right';
            app.YLabel.Position = [99 361 25 22];
            app.YLabel.Text = 'Y';

            % Create SourceYField
            app.SourceYField = uieditfield(app.RoomTab, 'numeric');
            app.SourceYField.Position = [128 361 35 22];

            % Create SourceXField
            app.SourceXField = uieditfield(app.RoomTab, 'numeric');
            app.SourceXField.Position = [77 361 35 22];

            % Create XEditFieldLabel_2
            app.XEditFieldLabel_2 = uilabel(app.RoomTab);
            app.XEditFieldLabel_2.HorizontalAlignment = 'right';
            app.XEditFieldLabel_2.Position = [296 361 13 22];
            app.XEditFieldLabel_2.Text = 'X';

            % Create ZLabel_2
            app.ZLabel_2 = uilabel(app.RoomTab);
            app.ZLabel_2.HorizontalAlignment = 'right';
            app.ZLabel_2.Position = [386 361 25 22];
            app.ZLabel_2.Text = 'Z';

            % Create ReceiverZField
            app.ReceiverZField = uieditfield(app.RoomTab, 'numeric');
            app.ReceiverZField.Position = [415 361 35 22];

            % Create YLabel_2
            app.YLabel_2 = uilabel(app.RoomTab);
            app.YLabel_2.HorizontalAlignment = 'right';
            app.YLabel_2.Position = [335 361 25 22];
            app.YLabel_2.Text = 'Y';

            % Create ReceiverYField
            app.ReceiverYField = uieditfield(app.RoomTab, 'numeric');
            app.ReceiverYField.Position = [364 361 35 22];

            % Create ReceiverXField
            app.ReceiverXField = uieditfield(app.RoomTab, 'numeric');
            app.ReceiverXField.Position = [313 361 35 22];

            % Create ResampleHRIRsetButton
            app.ResampleHRIRsetButton = uibutton(app.UIFigure, 'push');
            app.ResampleHRIRsetButton.ButtonPushedFcn = createCallbackFcn(app, @ResampleHRIRsetButtonPushed, true);
            app.ResampleHRIRsetButton.Position = [134 507 121 23];
            app.ResampleHRIRsetButton.Text = 'Resample HIRR set';

            % Create RecordRTSpatializationButton
            app.RecordRTSpatializationButton = uibutton(app.UIFigure, 'push');
            app.RecordRTSpatializationButton.ButtonPushedFcn = createCallbackFcn(app, @RecordRTSpatializationButtonPushed, true);
            app.RecordRTSpatializationButton.Visible = 'off';
            app.RecordRTSpatializationButton.Position = [401 507 147 23];
            app.RecordRTSpatializationButton.Text = 'Record RT Spatialization';

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