classdef GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        StopOutputButton            matlab.ui.control.Button
        WriteFileButton             matlab.ui.control.Button
        OutputStatusField           matlab.ui.control.EditField
        OutputButton                matlab.ui.control.Button
        InputStatusField            matlab.ui.control.EditField
        LoadFileButton              matlab.ui.control.Button
        RecordButton                matlab.ui.control.Button
        OutputDropDown              matlab.ui.control.DropDown
        OutputDropDownLabel         matlab.ui.control.Label
        InputDropDown               matlab.ui.control.DropDown
        InputDropDownLabel          matlab.ui.control.Label
        TabGroup                    matlab.ui.container.TabGroup
        PlotsTab                    matlab.ui.container.Tab
        UpdateButton                matlab.ui.control.Button
        OutputFrequencyDomainAxis   matlab.ui.control.UIAxes
        OutputTimeDomainAxis        matlab.ui.control.UIAxes
        InputFrequencyDomainAxis    matlab.ui.control.UIAxes
        InputTimeDomainAxis         matlab.ui.control.UIAxes
        RoomAcousticsand3DSpatializationTab  matlab.ui.container.Tab
        StopPosRecordingButton      matlab.ui.control.Button
        RecordPosStatusField        matlab.ui.control.EditField
        HrirStatusField             matlab.ui.control.EditField
        LoadHRIRSetButton           matlab.ui.control.Button
        RecordPositionsButton       matlab.ui.control.Button
        ShowraytracesCheckBox       matlab.ui.control.CheckBox
        PlotimagesourcesCheckBox    matlab.ui.control.CheckBox
        KeystrokesButton            matlab.ui.control.Button
        ApplyCoordsButton           matlab.ui.control.Button
        ReceiverZField              matlab.ui.control.NumericEditField
        ZEditField_2Label           matlab.ui.control.Label
        ReceiverYField              matlab.ui.control.NumericEditField
        YEditField_2Label           matlab.ui.control.Label
        ReceiverXField              matlab.ui.control.NumericEditField
        XEditField_4Label           matlab.ui.control.Label
        ReceiverLabel               matlab.ui.control.Label
        SourceZField                matlab.ui.control.NumericEditField
        ZEditFieldLabel             matlab.ui.control.Label
        SourceYField                matlab.ui.control.NumericEditField
        YEditFieldLabel             matlab.ui.control.Label
        SourceXField                matlab.ui.control.NumericEditField
        XEditFieldLabel             matlab.ui.control.Label
        SourceLabel                 matlab.ui.control.Label
        RenderCuboidRoomButton      matlab.ui.control.Button
        RoomPlot                    matlab.ui.control.UIAxes
        OutputCreationTab           matlab.ui.container.Tab
        SpatializationField         matlab.ui.control.EditField
        SpatializationButton        matlab.ui.control.Button
        Only3DspatializationLabel   matlab.ui.control.Label
        RoomAcousticConvField       matlab.ui.control.EditField
        RoomAcousticConvButton      matlab.ui.control.Button
        OnlyroomacousticsLabel      matlab.ui.control.Label
        Lamp_3                      matlab.ui.control.Lamp
        Lamp_2                      matlab.ui.control.Lamp
        Lamp                        matlab.ui.control.Lamp
        Gauge                       matlab.ui.control.Gauge
        StopRTButton                matlab.ui.control.Button
        RealTimeOutputButton        matlab.ui.control.Button
        Createsimplified3DroomacousticsLabel  matlab.ui.control.Label
        CreateAccurateStatusField   matlab.ui.control.EditField
        CreateAccurateOutputButton  matlab.ui.control.Button
        Createaccurate3DroomacousticsofflineLabel  matlab.ui.control.Label
        ContextMenu                 matlab.ui.container.ContextMenu
        Menu                        matlab.ui.container.Menu
        Menu2                       matlab.ui.container.Menu
    end

    properties (Access = private)
        % Private properties necessary for recording: Recorder objects and
        % recording flag
        audioRecorder;                  
        audioRealtimePlayerRecorder;
        recordingFlag = false;
        
        % Properties that contain the input and output (=processes)
        % audiodata as well as important properties like f_s, reverberation
        % time in the room and block size for block processing
        inputAudioData;
        outputAudioData;
        f_s;
        combinedRoomImpulseResponse;
        t_reverb;
        blockSize = 2^13;
        
        % Properties belonging to room acoustics (image source method)
        roomDimensions;
        roomType;
        Source;
        Receiver;
        recordedSourceCoords;
        recordedReceiverCoords
        ImageSourceCoords
        Wallcoefs;
        
        % Properties belonging to 3D audio spatialization
        HrirFullSet
        CurrentHrirLeft
        CurrentHrirRight
        
        % boolean flags necessary for the GUI
        boKeystrokeActive = false;
        boRecordingPositions = false;
        boRealTimeActive = false;
        boPositionsChanged = false;
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: InputDropDown
        function InputDropDownValueChanged(app, event)
            if "Microphone" == app.InputDropDown.Value
                app.RecordButton.Visible = "on";
                app.LoadFileButton.Visible = "off";
            elseif "File" == app.InputDropDown.Value
                app.RecordButton.Visible = "off";
                app.LoadFileButton.Visible = "on";
            end
            
        end

        % Button pushed function: RecordButton
        % Records audio and resamples loaded HRIR set to appropriate
        % sampling rate
        function RecordButtonPushed(app, event)
            if false == app.recordingFlag
                if isempty(app.f_s)
                    app.f_s = 21000;
                    if ~isempty(app.HrirFullSet) 
                        for i = 1:length(app.HrirFullSet(:,1))
                            for j = 1:length(app.HrirFullSet{i})
                                app.HrirFullSet{i}{j} = resample(app.HrirFullSet{i}{j}, app.f_s, oldFs);
                                app.HrirStatusField.Value = "Set resampled";
                            end
                        end
                    end
                end
                app.audioRecorder = audiorecorder(app.f_s, 24, 1);
                app.recordingFlag = recordAudio(app.audioRecorder, app.f_s, app.recordingFlag);
                app.InputStatusField.Value = "recording";
                app.RecordButton.Text = "Stop";
            else
                app.recordingFlag = recordAudio(app.audioRecorder, app.f_s, app.recordingFlag);
                app.InputStatusField.Value = "finished";
                app.inputAudioData = getaudiodata(app.audioRecorder);
                app.outputAudioData = [];
                app.RecordButton.Text = "Record";
            end
        end

        % Value changed function: OutputDropDown
        function OutputDropDownValueChanged(app, event)
            if "Speaker" == app.OutputDropDown.Value
                app.OutputButton.Visible = "on";
                app.WriteFileButton.Visible = "off";
            elseif "File" == app.OutputDropDown.Value
                app.OutputButton.Visible = "off";
                app.WriteFileButton.Visible = "on";
            end
            
        end

        % Button pushed function: WriteFileButton
        function WriteFileButtonPushed(app, event)
            if ~isempty(app.outputAudioData)
                boStatusFlag = writeAudiofile("wav", app.outputAudioData, app.f_s);
            elseif isempty(app.outputAudioData) && ~isempty(app.inputAudioData)
                boStatusFlag = writeAudiofile("wav", app.inputAudioData, app.f_s);
            else
                boStatusFlag = false;
            end

            if true == boStatusFlag
                app.OutputStatusField.Value = "written";
            else
                app.OutputStatusField.Value = "failed";
            end
        end

        % Button pushed function: OutputButton
        function OutputButtonPushed(app, event)
            if ~isempty(app.outputAudioData)
                boStatusFlag = writeAudiofile("speaker", app.outputAudioData, app.f_s);
            elseif isempty(app.outputAudioData) && ~isempty(app.inputAudioData)
                boStatusFlag = writeAudiofile("speaker", app.inputAudioData, app.f_s);
            else
                boStatusFlag = false;
            end
            app.OutputButton.Visible = "off";
            app.StopOutputButton.Visible = "on";
            if true == boStatusFlag
                app.OutputStatusField.Value = "played";
            else
                app.OutputStatusField.Value = "failed";
                app.OutputButton.Visible = "on";
                app.StopOutputButton.Visible = "off";
            end
        end

        % Button pushed function: LoadFileButton
        function LoadFileButtonPushed(app, event)
            [boSuccessFlag, audioData, sampling_rate] = readAudiofile;
            if boSuccessFlag
                app.inputAudioData = audioData;
                app.outputAudioData = [];

                if isempty(app.f_s)
                    app.f_s = sampling_rate;
                else
                    app.inputAudioData = resample(app.inputAudioData, app.f_s, sampling_rate);
                end
                app.InputStatusField.Value = "read";
            else
                app.InputStatusField.Value = "failed";
            end
        end

        % Button pushed function: RenderCuboidRoomButton
        % Creates a pop up window to ask user for room properties. 4
        % preconfigured rooms available
        function RenderCuboidRoomButtonPushed(app, event)
            popup = uifigure("Name", "Choose room type", "Position", [100, 100, 300, 200]);
            dropdownLabel = uilabel(popup, 'Text', 'Select a room', 'Position', [10, 130, 150, 22]);
            dropdown = uidropdown(popup, "Items", {'100x100x100, high reflection', '100x100x100, low reflection','300x300x300, high reflection', '300x300x300, low reflection', 'Custom'}, "Position", [150, 130, 150, 22]);
            reverbTFieldLabel = uilabel(popup, 'Text', 'Reverberation time [s]:', 'Position', [10, 70, 150, 22]);
            reverbT_field  = uieditfield(popup, 'numeric', 'Position', [150, 70, 50, 22], 'Value', 0);
            sampleRFieldLabel = uilabel(popup, 'Text', 'Sample rate [Hz]:', 'Position', [10, 100, 150, 22]);
            sampleR_field = uieditfield(popup, 'numeric', 'Position', [150, 100, 50, 22], 'Value', 0);
            popupButton = uibutton(popup, "Text", "Ok", "Position", [95, 20, 60, 22], 'ButtonPushedFcn', @(~,~) popupButtonPushedFcn(popup, dropdown, reverbT_field, sampleR_field));
            oldFs = app.f_s;
            function popupButtonPushedFcn(popup, dropdown, reverbT_field, sampleR_field)
                if ~isempty(app.inputAudioData) && ~isempty(app.f_s)
                    app.inputAudioData= resample(app.inputAudioData, sampleR_field.Value, app.f_s);
                end

                app.t_reverb = reverbT_field.Value;
                app.f_s = sampleR_field.Value;
                app.roomType = dropdown.Value;
                cla(app.RoomPlot);
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
                app.roomDimensions = [str2double(inputs(1)), str2double(inputs(2)), str2double(inputs(3))];
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
                app.roomDimensions = [100, 100, 100];
                app.Source = [50, 50, 50];
                app.Receiver = [1, 55, 50];
                app.Wallcoefs = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2];

            elseif strcmp('100x100x100, low reflection', app.roomType)
                app.roomDimensions = [100, 100, 100];
                app.Source = [50, 50, 50];
                app.Receiver = [1, 55, 50];
                app.Wallcoefs = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
            elseif strcmp('300x300x300, high reflection', app.roomType)
                app.roomDimensions = [300, 300, 300];
                app.Source = [150, 150, 150];
                app.Receiver = [10, 155, 150];
                app.Wallcoefs = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2];          
            elseif strcmp('300x300x300, low reflection', app.roomType)
                app.roomDimensions = [300, 300, 300];
                app.Source = [150, 150, 150];
                app.Receiver = [10, 155, 150];
                app.Wallcoefs = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1];     
            else
                return
            end
            
            % Sets source and receiver coordinates if room has been
            % successfully created
            if ~isempty(app.roomDimensions) && ~isempty(app.Source) && ~isempty(app.Receiver) && ~isempty(app.Wallcoefs) && ~isempty(app.t_reverb) && ~isempty(app.f_s)
                [app.combinedRoomImpulseResponse, app.ImageSourceCoords]  = IRfromCuboid(app.roomDimensions, app.Source, app.Receiver, app.t_reverb, app.Wallcoefs, app.f_s);
                app.SourceXField.Value = app.Source(1);
                app.SourceYField.Value = app.Source(2);
                app.SourceZField.Value = app.Source(3);
                app.ReceiverXField.Value = app.Receiver(1);
                app.ReceiverYField.Value = app.Receiver(2);
                app.ReceiverZField.Value = app.Receiver(3);
                
                % plot room
                if app.PlotimagesourcesCheckBox.Value
                    plotImageSources(app.roomDimensions, app.Receiver, app.Source, app.ImageSourceCoords, app.ShowraytracesCheckBox.Value, app.RoomPlot);
                else
                    plotRoom(app.roomDimensions, app.Receiver, app.Source, app.RoomPlot);
                end
            end
            
            % Resampling of HRIR set to sampling rate set at room creation
            if ~isempty(app.HrirFullSet) 
                for i = 1:length(app.HrirFullSet(:,1))
                    for j = 1:length(app.HrirFullSet{i})
                        app.HrirFullSet{i}{j} = resample(app.HrirFullSet{i}{j}, app.f_s, oldFs);
                        app.HrirStatusField.Value = "Set resampled";
                    end
                end
            end
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
        % Callback function for movement of receiver and  source
        function KeyPressCallback(app, event)
            if app.boKeystrokeActive
                [app.Source, app.Receiver] = keystrokeCoordUpdate(app.Source, app.Receiver, app.roomDimensions, event);
                [app.combinedRoomImpulseResponse, app.ImageSourceCoords]  = IRfromCuboid(app.roomDimensions, app.Source, app.Receiver, app.t_reverb, app.Wallcoefs, app.f_s);
                
                app.SourceXField.Value = app.Source(1);
                app.SourceYField.Value = app.Source(2);
                app.SourceZField.Value = app.Source(3);
                app.ReceiverXField.Value = app.Receiver(1);
                app.ReceiverYField.Value = app.Receiver(2);
                app.ReceiverZField.Value = app.Receiver(3);
                
                % update plot of room
                cla(app.RoomPlot);
                if app.PlotimagesourcesCheckBox.Value
                    plotImageSources(app.roomDimensions, app.Receiver, app.Source, app.ImageSourceCoords, app.ShowraytracesCheckBox.Value, app.RoomPlot);
                else
                    plotRoom(app.roomDimensions, app.Receiver, app.Source, app.RoomPlot);
                end
                app.boPositionsChanged = true;
            end  
        end

        % Button pushed function: ApplyCoordsButton
        % Read coordinates from user input field (source and receiver) and
        % update source and receiver positions accordingly
        function ApplyCoordsButtonPushed(app, event)
        if ~isempty(app.SourceXField.Value)
            if app.SourceXField.Value <= 0
                app.Source(1) = 1;
            elseif app.SourceXField.Value >= app.roomDimensions(1)
                app.Source(1) = app.roomDimensions(1) - 1;
            else
            app.Source(1) = app.SourceXField.Value;
            end
        end
        if ~isempty(app.SourceYField.Value)
            if app.SourceYField.Value <= 0
                app.Source(2) = 1;
            elseif app.SourceYField.Value >= app.roomDimensions(2)
                app.Source(2) = app.roomDimensions(2) - 1;
            else
                app.Source(2) = app.SourceYField.Value;
            end
        end
        if ~isempty(app.SourceZField.Value)
            if app.SourceZField.Value <= 0
                app.Source(3) = 1;
            elseif app.SourceZField.Value >= app.roomDimensions(3)
                app.Source(3) = app.roomDimensions(3) - 1;
            else
                app.Source(3) = app.SourceZField.Value;
            end
        end            
        if ~isempty(app.ReceiverXField.Value)
            if app.ReceiverXField.Value <= 0
                app.Receiver(1) = 1;
            elseif app.ReceiverXField.Value >= app.roomDimensions(1)
                app.Receiver(1) = app.roomDimensions(1) - 1;
            else
                app.Receiver(1) = app.ReceiverXField.Value;
            end
        end
        if ~isempty(app.ReceiverYField.Value)
            if app.ReceiverYField.Value <= 0
                app.Receiver(2) = 1;
            elseif app.ReceiverYField.Value >= app.roomDimensions(2)
                app.Receiver(2) = app.roomDimensions(2) - 1;
            else
                app.Receiver(2) = app.ReceiverYField.Value;
            end
        end
        if ~isempty(app.ReceiverZField.Value)
            if app.ReceiverZField.Value <= 0
                app.Receiver(3) = 1;
            elseif app.ReceiverZField.Value >= app.roomDimensions(3)
                app.Receiver(3) = app.roomDimensions(3) - 1;
            else
                app.Receiver(3) = app.ReceiverZField.Value;
            end
        end          
        
        % Compute new image source according to new positioning. Update
        % room plot
        [app.combinedRoomImpulseResponse, app.ImageSourceCoords]  = IRfromCuboid(app.roomDimensions, app.Source, app.Receiver, app.t_reverb, app.Wallcoefs, app.f_s);
        cla(app.RoomPlot);
        if app.PlotimagesourcesCheckBox.Value
            plotImageSources(app.roomDimensions, app.Receiver, app.Source, app.ImageSourceCoords, app.ShowraytracesCheckBox.Value, app.RoomPlot);
        else
            plotRoom(app.roomDimensions, app.Receiver, app.Source, app.RoomPlot);
        end
        app.boPositionsChanged = true;
        end

        % Value changed function: PlotimagesourcesCheckBox
        % If tickbox to plot image sources is ticked, update plot
        function PlotimagesourcesCheckBoxValueChanged(app, event)
            if ~isempty(app.roomDimensions) && ~isempty(app.Source) && ~isempty(app.Receiver)
                if true == app.PlotimagesourcesCheckBox.Value
                    cla(app.RoomPlot);
                    plotImageSources(app.roomDimensions, app.Receiver, app.Source, app.ImageSourceCoords, app.ShowraytracesCheckBox.Value, app.RoomPlot);
                else
                    cla(app.RoomPlot);
                    plotRoom(app.roomDimensions, app.Receiver, app.Source, app.RoomPlot);
                end
            end
        end

        % Value changed function: ShowraytracesCheckBox
        % If tickbox to plot raytraces to imagesources is ticket together
        % with plot-image-source-tickbox, then update plot
        function ShowraytracesCheckBoxValueChanged(app, event)
            if ~isempty(app.roomDimensions) && ~isempty(app.Source) && ~isempty(app.Receiver)
                if true == app.PlotimagesourcesCheckBox.Value
                    cla(app.RoomPlot);
                    plotImageSources(app.roomDimensions, app.Receiver, app.Source, app.ImageSourceCoords, app.ShowraytracesCheckBox.Value, app.RoomPlot);
                else
                    cla(app.RoomPlot);
                    plotRoom(app.roomDimensions, app.Receiver, app.Source, app.RoomPlot);
                end
            end            
        end

        % Button pushed function: UpdateButton
        % If Update botton for input and output audio signal plotting (if
        % existing) is pressed, then plot both in time and frequency domain
        function UpdateButtonPushed(app, event)
            if ~isempty(app.inputAudioData)
                len = length(app.inputAudioData);
                t = (0:len-1)*(1 / app.f_s);
                plot(app.InputTimeDomainAxis, t, app.inputAudioData);                
                y_freqDomain = fft(app.inputAudioData);
                plot(app.InputFrequencyDomainAxis, (0:len-1)*(app.f_s / len), abs(fftshift(y_freqDomain)));
            end

            if ~isempty(app.outputAudioData)
                len = length(app.outputAudioData);
                t = (0:len-1)*(1 / app.f_s);
                plot(app.OutputTimeDomainAxis, t, app.outputAudioData);                
                y_freqDomain = fft(app.outputAudioData);
                plot(app.OutputFrequencyDomainAxis, (0:len-1)*(app.f_s / len), abs(fftshift(y_freqDomain)));
            elseif isempty(app.outputAudioData) && ~isempty(app.inputAudioData)
                len = length(app.inputAudioData);
                t = (0:len-1)*(1 / app.f_s);
                plot(app.OutputTimeDomainAxis, t, app.inputAudioData);                
                y_freqDomain = fft(app.inputAudioData);
                plot(app.OutputFrequencyDomainAxis, (0:len-1)*(app.f_s / len), abs(fftshift(y_freqDomain)));
            end
        end

        % Button pushed function: LoadHRIRSetButton
        % Load HRIR full set from hard disk into program.
        function LoadHRIRSetButtonPushed(app, event)
            app.HrirFullSet = readHRIR("./impulse_responses//HRTF_full/");
            if ~isempty(app.HrirFullSet) && ~isempty(app.f_s)
                for i = 1:length(app.HrirFullSet(:,1))
                    for j = 1:length(app.HrirFullSet{i})
                        app.HrirFullSet{i}{j} = resample(app.HrirFullSet{i}{j}, app.f_s, 44100);
                    end
                end
            end
            app.HrirFullSet = transpose(app.HrirFullSet);
            app.HrirStatusField.Value = "set loaded";
        end

        % Button pushed function: RecordPositionsButton
        function RecordPositionsButtonPushed(app, event)
        % Checks if room dimensions, source- and receiver
        % coordinates and sampling frequency have already been set.
        % Calculates the time interval of 1 block. Until stopped source and
        % receiver coords are sampled with that period and stored in arrays
        if false == app.boRecordingPositions
                if isempty(app.roomDimensions) || isempty(app.Source) || isempty(app.Receiver) || isempty(app.f_s)
                    app.RecordPosStatusField.Value = "failed";
                else
                    app.boRecordingPositions = true;
                    app.RecordPosStatusField.Value = "recording";
                    app.RecordPositionsButton.Visible = "off";
                    app.StopPosRecordingButton.Visible = "on";
                    indexCount = 1;
                    timeIntervall = app.blockSize / app.f_s;
                    app.recordedReceiverCoords = [];
                    app.recordedSourceCoords = [];
                    while  true == app.boRecordingPositions
                        app.recordedSourceCoords(indexCount, :) = app.Source;
                        app.recordedReceiverCoords(indexCount, :) = app.Receiver;
                        indexCount = indexCount +1;
                        pause(timeIntervall);
                    end
                end
        else

        end
        end

        % Button pushed function: StopPosRecordingButton
        function StopPosRecordingButtonPushed(app, event)
            app.boRecordingPositions = false;
            app.StopPosRecordingButton.Visible = "off";
            app.RecordPositionsButton.Visible = "on";
        end

        % Button pushed function: CreateAccurateOutputButton
        function CreateAccurateOutputButtonPushed(app, event)
            LoadHRIRSetButtonPushed(app, []);
            if  isempty(app.f_s) || isempty(app.inputAudioData) || isempty(app.roomDimensions) || isempty(app.t_reverb) || isempty(app.Wallcoefs) || isempty(app.HrirFullSet)
                app.CreateAccurateStatusField.Value = "failed";
            else
                if isempty(app.recordedReceiverCoords) || isempty(app.recordedSourceCoords)
                    app.recordedReceiverCoords(1, :) = app.Receiver;
                    app.recordedSourceCoords(1, :) = app.Source;
                end
                app.Lamp.Color = "red";
                app.Lamp_2.Color = "red";
                app.Lamp_3.Color = "red";
                app.CreateAccurateStatusField.Value = "Processing...";
                app.outputAudioData = imageSourceAnd3dSpatialisationOffline(app.inputAudioData, app.f_s, 2^(13), app.roomDimensions, app.recordedSourceCoords,...
                                                                                                                                                  app.recordedReceiverCoords, [1,0,0], app.t_reverb, app.Wallcoefs, app.HrirFullSet, app.Gauge);
                app.CreateAccurateStatusField.Value = "finished";
                app.Lamp.Color = "green";
                app.Lamp_2.Color = "green";
                app.Lamp_3.Color = "green";
            end
        end

        % Value changed function: SourceYField
        function SourceYFieldValueChanged(app, event)
            value = app.SourceYField.Value;
            
        end

        % Button pushed function: RealTimeOutputButton
        function RealTimeOutputButtonPushed(app, event)
            if ~isempty(app.f_s) && ~isempty(app.HrirFullSet) && ~isempty(app.roomDimensions)
                app.boRealTimeActive = true;
                app.RealTimeOutputButton.Visible = "off";
                app.StopRTButton.Visible = "on";
                % app.outputAudioData(:,1) = zeros(2,1);
                % app.outputAudioData(:,2) = zeros(2,1);
                app.outputAudioData = [];
                app.audioRealtimePlayerRecorder = audioPlayerRecorder(app.f_s);
                app.audioRealtimePlayerRecorder.PlayerChannelMapping = [1, 2];
                blocks = 1024;
                [Hrir(:,1), Hrir(:,2)] = computeFinalHrir(app.Receiver, app.Source, app.HrirFullSet, app.f_s);
                combinedIRs_left = fftConv(Hrir(:,1), app.combinedRoomImpulseResponse);
                combinedIRs_right = fftConv(Hrir(:,2), app.combinedRoomImpulseResponse);
                [audioOverlap(:,1), output(:,1)] = prepareBlocks(blocks, combinedIRs_left );
                [audioOverlap(:,2), output(:,2)] = prepareBlocks(blocks, combinedIRs_right); 

                while app.boRealTimeActive
                    output_normalized(:,1) = output(:,1) / max(abs(output(:,1)));
                    output_normalized(:,2) = output(:,2) / max(abs(output(:,2)));
                    input = app.audioRealtimePlayerRecorder([output_normalized(:,1), output_normalized(:,2)]);
                    [output(:,1), audioOverlap(:,1)] = realTimeConvAndOutput(input, audioOverlap(:,1),  combinedIRs_left, blocks);
                    [output(:,2), audioOverlap(:,2)] = realTimeConvAndOutput(input, audioOverlap(:,2),  combinedIRs_right, blocks);

                    if isempty(app.outputAudioData)
                        app.outputAudioData = output;
                    else
                        app.outputAudioData = [app.outputAudioData; output];
                    end
                    pause(0.01);

                    if app.boPositionsChanged
                        app.boPositionsChanged = false;
                        [Hrir(:,1), Hrir(:,2)] = computeFinalHrir(app.Receiver, app.Source, app.HrirFullSet, app.f_s);
                        combinedIRs_left = fftConv(Hrir(:,1), app.combinedRoomImpulseResponse);
                        combinedIRs_right = fftConv(Hrir(:,2), app.combinedRoomImpulseResponse);
                    end
                end
            else
            end
            
        end

        % Button pushed function: StopRTButton
        function StopRTButtonPushed(app, event)
            app.boRealTimeActive = false;
            app.StopRTButton.Visible = "off";
            app.RealTimeOutputButton.Visible = "on";
        end

        % Button pushed function: StopOutputButton
        function StopOutputButtonPushed(app, event)
            clear sound
            app.StopOutputButton.Visible = "off";
            app.OutputButton.Visible = "on";
        end

        % Button pushed function: RoomAcousticConvButton
        function RoomAcousticConvButtonPushed(app, event)
            app.outputAudioData = [];
            if ~isempty(app.inputAudioData) && ~isempty(app.combinedRoomImpulseResponse)
                app.outputAudioData(:,1) = overlapSaveRecorded(app.inputAudioData(:,1), app.combinedRoomImpulseResponse, 1024);

                if 2 == width(app.inputAudioData)
                    app.outputAudioData(:,2) = overlapSaveRecorded(app.inputAudioData(:,2), app.combinedRoomImpulseResponse, 1024);
                end
                app.RoomAcousticConvField.Value = "finished";
            else
                app.RoomAcousticConvField.Value = "failed";
            end
        end

        % Button pushed function: SpatializationButton
        function SpatializationButtonPushed(app, event)
            app.outputAudioData = [];
            if ~isempty(app.inputAudioData) && ~isempty(app.HrirFullSet) && ~isempty(app.Source) && ~isempty(app.Receiver)
                [Hrir(:,1), Hrir(:,2)] = computeFinalHrir(app.Receiver, app.Source, app.HrirFullSet, app.f_s);
                app.outputAudioData(:,1) = overlapSaveRecorded(app.inputAudioData(:,1), Hrir(:,1), 1024);
                app.outputAudioData(:,2) = overlapSaveRecorded(app.inputAudioData(:,1), Hrir(:,2), 1024);
                
                app.SpatializationField.Value = "finished";
            else
                app.SpatializationField.Value = "failed";
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 876 709];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.KeyPressFcn = createCallbackFcn(app, @KeyPressCallback, true);

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 876 618];

            % Create PlotsTab
            app.PlotsTab = uitab(app.TabGroup);
            app.PlotsTab.Title = 'Plots';

            % Create InputTimeDomainAxis
            app.InputTimeDomainAxis = uiaxes(app.PlotsTab);
            title(app.InputTimeDomainAxis, 'Input Time Domain Signal')
            xlabel(app.InputTimeDomainAxis, 'Time / s')
            ylabel(app.InputTimeDomainAxis, 'u(t)')
            zlabel(app.InputTimeDomainAxis, 'Z')
            app.InputTimeDomainAxis.Position = [23 326 377 228];

            % Create InputFrequencyDomainAxis
            app.InputFrequencyDomainAxis = uiaxes(app.PlotsTab);
            title(app.InputFrequencyDomainAxis, 'Input Frequency Domain')
            xlabel(app.InputFrequencyDomainAxis, 'Frequency / Hz')
            ylabel(app.InputFrequencyDomainAxis, 'Magnitude Spectrum')
            zlabel(app.InputFrequencyDomainAxis, 'Z')
            app.InputFrequencyDomainAxis.Position = [455 326 387 228];

            % Create OutputTimeDomainAxis
            app.OutputTimeDomainAxis = uiaxes(app.PlotsTab);
            title(app.OutputTimeDomainAxis, 'Output Time Domain Signal')
            xlabel(app.OutputTimeDomainAxis, 'Time / s')
            ylabel(app.OutputTimeDomainAxis, 'v(t)')
            zlabel(app.OutputTimeDomainAxis, 'Z')
            app.OutputTimeDomainAxis.Position = [23 65 387 222];

            % Create OutputFrequencyDomainAxis
            app.OutputFrequencyDomainAxis = uiaxes(app.PlotsTab);
            title(app.OutputFrequencyDomainAxis, 'Output Frequency Domain')
            xlabel(app.OutputFrequencyDomainAxis, 'Frequency / Hz')
            ylabel(app.OutputFrequencyDomainAxis, 'Magnitude Spectrum ')
            zlabel(app.OutputFrequencyDomainAxis, 'Z')
            app.OutputFrequencyDomainAxis.Position = [455 65 387 222];

            % Create UpdateButton
            app.UpdateButton = uibutton(app.PlotsTab, 'push');
            app.UpdateButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateButtonPushed, true);
            app.UpdateButton.Position = [56 12 100 23];
            app.UpdateButton.Text = 'Update ';

            % Create RoomAcousticsand3DSpatializationTab
            app.RoomAcousticsand3DSpatializationTab = uitab(app.TabGroup);
            app.RoomAcousticsand3DSpatializationTab.Title = 'Room Acoustics and 3D Spatialization';

            % Create RoomPlot
            app.RoomPlot = uiaxes(app.RoomAcousticsand3DSpatializationTab);
            title(app.RoomPlot, 'Room')
            xlabel(app.RoomPlot, 'X')
            ylabel(app.RoomPlot, 'Y')
            zlabel(app.RoomPlot, 'Z')
            app.RoomPlot.Position = [11 12 831 499];

            % Create RenderCuboidRoomButton
            app.RenderCuboidRoomButton = uibutton(app.RoomAcousticsand3DSpatializationTab, 'push');
            app.RenderCuboidRoomButton.ButtonPushedFcn = createCallbackFcn(app, @RenderCuboidRoomButtonPushed, true);
            app.RenderCuboidRoomButton.Position = [23 553 131 23];
            app.RenderCuboidRoomButton.Text = 'Render Cuboid Room';

            % Create SourceLabel
            app.SourceLabel = uilabel(app.RoomAcousticsand3DSpatializationTab);
            app.SourceLabel.FontWeight = 'bold';
            app.SourceLabel.Position = [23 519 50 22];
            app.SourceLabel.Text = 'Source:';

            % Create XEditFieldLabel
            app.XEditFieldLabel = uilabel(app.RoomAcousticsand3DSpatializationTab);
            app.XEditFieldLabel.HorizontalAlignment = 'right';
            app.XEditFieldLabel.FontWeight = 'bold';
            app.XEditFieldLabel.Position = [70 519 25 22];
            app.XEditFieldLabel.Text = 'X:';

            % Create SourceXField
            app.SourceXField = uieditfield(app.RoomAcousticsand3DSpatializationTab, 'numeric');
            app.SourceXField.Position = [100 519 51 22];

            % Create YEditFieldLabel
            app.YEditFieldLabel = uilabel(app.RoomAcousticsand3DSpatializationTab);
            app.YEditFieldLabel.HorizontalAlignment = 'right';
            app.YEditFieldLabel.FontWeight = 'bold';
            app.YEditFieldLabel.Position = [143 519 25 22];
            app.YEditFieldLabel.Text = 'Y:';

            % Create SourceYField
            app.SourceYField = uieditfield(app.RoomAcousticsand3DSpatializationTab, 'numeric');
            app.SourceYField.ValueChangedFcn = createCallbackFcn(app, @SourceYFieldValueChanged, true);
            app.SourceYField.Position = [173 519 51 22];

            % Create ZEditFieldLabel
            app.ZEditFieldLabel = uilabel(app.RoomAcousticsand3DSpatializationTab);
            app.ZEditFieldLabel.HorizontalAlignment = 'right';
            app.ZEditFieldLabel.FontWeight = 'bold';
            app.ZEditFieldLabel.Position = [217 519 25 22];
            app.ZEditFieldLabel.Text = 'Z:';

            % Create SourceZField
            app.SourceZField = uieditfield(app.RoomAcousticsand3DSpatializationTab, 'numeric');
            app.SourceZField.Position = [247 519 51 22];

            % Create ReceiverLabel
            app.ReceiverLabel = uilabel(app.RoomAcousticsand3DSpatializationTab);
            app.ReceiverLabel.FontWeight = 'bold';
            app.ReceiverLabel.Position = [322 519 59 22];
            app.ReceiverLabel.Text = 'Receiver:';

            % Create XEditField_4Label
            app.XEditField_4Label = uilabel(app.RoomAcousticsand3DSpatializationTab);
            app.XEditField_4Label.HorizontalAlignment = 'right';
            app.XEditField_4Label.FontWeight = 'bold';
            app.XEditField_4Label.Position = [369 519 25 22];
            app.XEditField_4Label.Text = 'X:';

            % Create ReceiverXField
            app.ReceiverXField = uieditfield(app.RoomAcousticsand3DSpatializationTab, 'numeric');
            app.ReceiverXField.Position = [399 519 51 22];

            % Create YEditField_2Label
            app.YEditField_2Label = uilabel(app.RoomAcousticsand3DSpatializationTab);
            app.YEditField_2Label.HorizontalAlignment = 'right';
            app.YEditField_2Label.FontWeight = 'bold';
            app.YEditField_2Label.Position = [442 519 25 22];
            app.YEditField_2Label.Text = 'Y:';

            % Create ReceiverYField
            app.ReceiverYField = uieditfield(app.RoomAcousticsand3DSpatializationTab, 'numeric');
            app.ReceiverYField.Position = [472 519 51 22];

            % Create ZEditField_2Label
            app.ZEditField_2Label = uilabel(app.RoomAcousticsand3DSpatializationTab);
            app.ZEditField_2Label.HorizontalAlignment = 'right';
            app.ZEditField_2Label.FontWeight = 'bold';
            app.ZEditField_2Label.Position = [516 519 25 22];
            app.ZEditField_2Label.Text = 'Z:';

            % Create ReceiverZField
            app.ReceiverZField = uieditfield(app.RoomAcousticsand3DSpatializationTab, 'numeric');
            app.ReceiverZField.Position = [546 519 51 22];

            % Create ApplyCoordsButton
            app.ApplyCoordsButton = uibutton(app.RoomAcousticsand3DSpatializationTab, 'push');
            app.ApplyCoordsButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyCoordsButtonPushed, true);
            app.ApplyCoordsButton.Position = [613 518 100 23];
            app.ApplyCoordsButton.Text = 'Apply';

            % Create KeystrokesButton
            app.KeystrokesButton = uibutton(app.RoomAcousticsand3DSpatializationTab, 'push');
            app.KeystrokesButton.ButtonPushedFcn = createCallbackFcn(app, @KeystrokesButtonPushed, true);
            app.KeystrokesButton.Position = [728 518 100 23];
            app.KeystrokesButton.Text = 'Keystrokes';

            % Create PlotimagesourcesCheckBox
            app.PlotimagesourcesCheckBox = uicheckbox(app.RoomAcousticsand3DSpatializationTab);
            app.PlotimagesourcesCheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotimagesourcesCheckBoxValueChanged, true);
            app.PlotimagesourcesCheckBox.Text = 'Plot image sources';
            app.PlotimagesourcesCheckBox.Position = [167 553 124 22];

            % Create ShowraytracesCheckBox
            app.ShowraytracesCheckBox = uicheckbox(app.RoomAcousticsand3DSpatializationTab);
            app.ShowraytracesCheckBox.ValueChangedFcn = createCallbackFcn(app, @ShowraytracesCheckBoxValueChanged, true);
            app.ShowraytracesCheckBox.Text = 'Show raytraces';
            app.ShowraytracesCheckBox.Position = [310 553 105 22];

            % Create RecordPositionsButton
            app.RecordPositionsButton = uibutton(app.RoomAcousticsand3DSpatializationTab, 'push');
            app.RecordPositionsButton.ButtonPushedFcn = createCallbackFcn(app, @RecordPositionsButtonPushed, true);
            app.RecordPositionsButton.Position = [725 552 106 23];
            app.RecordPositionsButton.Text = 'Record Positions';

            % Create LoadHRIRSetButton
            app.LoadHRIRSetButton = uibutton(app.RoomAcousticsand3DSpatializationTab, 'push');
            app.LoadHRIRSetButton.ButtonPushedFcn = createCallbackFcn(app, @LoadHRIRSetButtonPushed, true);
            app.LoadHRIRSetButton.Position = [525 552 100 23];
            app.LoadHRIRSetButton.Text = 'Load HRIR Set';

            % Create HrirStatusField
            app.HrirStatusField = uieditfield(app.RoomAcousticsand3DSpatializationTab, 'text');
            app.HrirStatusField.Position = [423 553 87 22];

            % Create RecordPosStatusField
            app.RecordPosStatusField = uieditfield(app.RoomAcousticsand3DSpatializationTab, 'text');
            app.RecordPosStatusField.Position = [641 552 72 22];

            % Create StopPosRecordingButton
            app.StopPosRecordingButton = uibutton(app.RoomAcousticsand3DSpatializationTab, 'push');
            app.StopPosRecordingButton.ButtonPushedFcn = createCallbackFcn(app, @StopPosRecordingButtonPushed, true);
            app.StopPosRecordingButton.Visible = 'off';
            app.StopPosRecordingButton.Position = [726 552 100 23];
            app.StopPosRecordingButton.Text = 'Stop';

            % Create OutputCreationTab
            app.OutputCreationTab = uitab(app.TabGroup);
            app.OutputCreationTab.Title = 'Output Creation';

            % Create Createaccurate3DroomacousticsofflineLabel
            app.Createaccurate3DroomacousticsofflineLabel = uilabel(app.OutputCreationTab);
            app.Createaccurate3DroomacousticsofflineLabel.FontWeight = 'bold';
            app.Createaccurate3DroomacousticsofflineLabel.Position = [23 553 255 22];
            app.Createaccurate3DroomacousticsofflineLabel.Text = 'Create accurate 3D room acoustics (offline)';

            % Create CreateAccurateOutputButton
            app.CreateAccurateOutputButton = uibutton(app.OutputCreationTab, 'push');
            app.CreateAccurateOutputButton.ButtonPushedFcn = createCallbackFcn(app, @CreateAccurateOutputButtonPushed, true);
            app.CreateAccurateOutputButton.Position = [19 517 108 23];
            app.CreateAccurateOutputButton.Text = 'Create Audiodata';

            % Create CreateAccurateStatusField
            app.CreateAccurateStatusField = uieditfield(app.OutputCreationTab, 'text');
            app.CreateAccurateStatusField.Position = [142 517 100 22];

            % Create Createsimplified3DroomacousticsLabel
            app.Createsimplified3DroomacousticsLabel = uilabel(app.OutputCreationTab);
            app.Createsimplified3DroomacousticsLabel.FontWeight = 'bold';
            app.Createsimplified3DroomacousticsLabel.Position = [509 552 217 22];
            app.Createsimplified3DroomacousticsLabel.Text = 'Create simplified 3D room acoustics ';

            % Create RealTimeOutputButton
            app.RealTimeOutputButton = uibutton(app.OutputCreationTab, 'push');
            app.RealTimeOutputButton.ButtonPushedFcn = createCallbackFcn(app, @RealTimeOutputButtonPushed, true);
            app.RealTimeOutputButton.Position = [509 511 100 23];
            app.RealTimeOutputButton.Text = 'Real-Time';

            % Create StopRTButton
            app.StopRTButton = uibutton(app.OutputCreationTab, 'push');
            app.StopRTButton.ButtonPushedFcn = createCallbackFcn(app, @StopRTButtonPushed, true);
            app.StopRTButton.Visible = 'off';
            app.StopRTButton.Position = [509 511 100 23];
            app.StopRTButton.Text = 'Stop RT';

            % Create Gauge
            app.Gauge = uigauge(app.OutputCreationTab, 'circular');
            app.Gauge.Position = [56 347 139 139];

            % Create Lamp
            app.Lamp = uilamp(app.OutputCreationTab);
            app.Lamp.Position = [89 313 20 20];

            % Create Lamp_2
            app.Lamp_2 = uilamp(app.OutputCreationTab);
            app.Lamp_2.Position = [116 313 20 20];

            % Create Lamp_3
            app.Lamp_3 = uilamp(app.OutputCreationTab);
            app.Lamp_3.Position = [143 313 20 20];

            % Create OnlyroomacousticsLabel
            app.OnlyroomacousticsLabel = uilabel(app.OutputCreationTab);
            app.OnlyroomacousticsLabel.FontWeight = 'bold';
            app.OnlyroomacousticsLabel.Position = [509 446 124 22];
            app.OnlyroomacousticsLabel.Text = 'Only room acoustics';

            % Create RoomAcousticConvButton
            app.RoomAcousticConvButton = uibutton(app.OutputCreationTab, 'push');
            app.RoomAcousticConvButton.ButtonPushedFcn = createCallbackFcn(app, @RoomAcousticConvButtonPushed, true);
            app.RoomAcousticConvButton.Position = [507 404 100 23];
            app.RoomAcousticConvButton.Text = 'Convolve';

            % Create RoomAcousticConvField
            app.RoomAcousticConvField = uieditfield(app.OutputCreationTab, 'text');
            app.RoomAcousticConvField.Position = [628 404 100 22];

            % Create Only3DspatializationLabel
            app.Only3DspatializationLabel = uilabel(app.OutputCreationTab);
            app.Only3DspatializationLabel.FontWeight = 'bold';
            app.Only3DspatializationLabel.Position = [509 340 130 22];
            app.Only3DspatializationLabel.Text = 'Only 3D spatialization';

            % Create SpatializationButton
            app.SpatializationButton = uibutton(app.OutputCreationTab, 'push');
            app.SpatializationButton.ButtonPushedFcn = createCallbackFcn(app, @SpatializationButtonPushed, true);
            app.SpatializationButton.Position = [507 298 100 23];
            app.SpatializationButton.Text = 'Convolve';

            % Create SpatializationField
            app.SpatializationField = uieditfield(app.OutputCreationTab, 'text');
            app.SpatializationField.Position = [628 298 100 22];

            % Create InputDropDownLabel
            app.InputDropDownLabel = uilabel(app.UIFigure);
            app.InputDropDownLabel.HorizontalAlignment = 'right';
            app.InputDropDownLabel.FontWeight = 'bold';
            app.InputDropDownLabel.Position = [24 648 34 22];
            app.InputDropDownLabel.Text = 'Input';

            % Create InputDropDown
            app.InputDropDown = uidropdown(app.UIFigure);
            app.InputDropDown.Items = {'Microphone', 'File'};
            app.InputDropDown.ValueChangedFcn = createCallbackFcn(app, @InputDropDownValueChanged, true);
            app.InputDropDown.Position = [73 648 100 22];
            app.InputDropDown.Value = 'Microphone';

            % Create OutputDropDownLabel
            app.OutputDropDownLabel = uilabel(app.UIFigure);
            app.OutputDropDownLabel.HorizontalAlignment = 'right';
            app.OutputDropDownLabel.FontWeight = 'bold';
            app.OutputDropDownLabel.Position = [467 648 44 22];
            app.OutputDropDownLabel.Text = 'Output';

            % Create OutputDropDown
            app.OutputDropDown = uidropdown(app.UIFigure);
            app.OutputDropDown.Items = {'Speaker', 'File'};
            app.OutputDropDown.ValueChangedFcn = createCallbackFcn(app, @OutputDropDownValueChanged, true);
            app.OutputDropDown.Position = [526 648 100 22];
            app.OutputDropDown.Value = 'Speaker';

            % Create RecordButton
            app.RecordButton = uibutton(app.UIFigure, 'push');
            app.RecordButton.ButtonPushedFcn = createCallbackFcn(app, @RecordButtonPushed, true);
            app.RecordButton.Position = [193 647 100 23];
            app.RecordButton.Text = 'Record';

            % Create LoadFileButton
            app.LoadFileButton = uibutton(app.UIFigure, 'push');
            app.LoadFileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadFileButtonPushed, true);
            app.LoadFileButton.Visible = 'off';
            app.LoadFileButton.Position = [193 647 100 23];
            app.LoadFileButton.Text = 'Load file';

            % Create InputStatusField
            app.InputStatusField = uieditfield(app.UIFigure, 'text');
            app.InputStatusField.Position = [311 648 100 22];
            app.InputStatusField.Value = 'ready';

            % Create OutputButton
            app.OutputButton = uibutton(app.UIFigure, 'push');
            app.OutputButton.ButtonPushedFcn = createCallbackFcn(app, @OutputButtonPushed, true);
            app.OutputButton.Position = [642 647 100 23];
            app.OutputButton.Text = 'Output';

            % Create OutputStatusField
            app.OutputStatusField = uieditfield(app.UIFigure, 'text');
            app.OutputStatusField.Position = [755 648 100 22];

            % Create WriteFileButton
            app.WriteFileButton = uibutton(app.UIFigure, 'push');
            app.WriteFileButton.ButtonPushedFcn = createCallbackFcn(app, @WriteFileButtonPushed, true);
            app.WriteFileButton.Visible = 'off';
            app.WriteFileButton.Position = [642 647 100 23];
            app.WriteFileButton.Text = 'Write file';

            % Create StopOutputButton
            app.StopOutputButton = uibutton(app.UIFigure, 'push');
            app.StopOutputButton.ButtonPushedFcn = createCallbackFcn(app, @StopOutputButtonPushed, true);
            app.StopOutputButton.Visible = 'off';
            app.StopOutputButton.Position = [642 647 100 23];
            app.StopOutputButton.Text = 'Stop';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create Menu
            app.Menu = uimenu(app.ContextMenu);
            app.Menu.Text = 'Menu';

            % Create Menu2
            app.Menu2 = uimenu(app.ContextMenu);
            app.Menu2.Text = 'Menu2';
            
            % Assign app.ContextMenu
            app.Only3DspatializationLabel.ContextMenu = app.ContextMenu;

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