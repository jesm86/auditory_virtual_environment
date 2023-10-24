classdef InputOutputAudio_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        StartStopRecordingButton  matlab.ui.control.Button
        WriteAudioField           matlab.ui.control.EditField
        ReadAudioField            matlab.ui.control.EditField
        WriteAudioButton          matlab.ui.control.Button
        ReadAudioButton           matlab.ui.control.Button
        OutputDropDown            matlab.ui.control.DropDown
        OutputDropDownLabel       matlab.ui.control.Label
        InputDropDown             matlab.ui.control.DropDown
        InputsourceDropDownLabel  matlab.ui.control.Label
        FreqDomainAxes            matlab.ui.control.UIAxes
        TimeDomainAxes            matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        y_timeDomain % Description
        F_s
        boRecordingFlag = false;
    end
    

    % Callbacks that handle component events
    methods (Access = private)
        
        %%%%%%%%%
        %
        % Input Audio
        %
        %%%%%%%%%
        % Button pushed function: ReadAudioButton
        function ReadAudioButtonPushed(app, event)
            if "Audiofile" == app.InputDropDown.Value
                [file,path] = uigetfile({'*.wav; *.mp3; *.flac', 'Audio files (*.wav, *.mp3, *.flac)'});
                if isequal(file, 0)
                    app.ReadAudioField.Value = 'cancelled';
                else
                    try
                        [app.y_timeDomain, app.F_s] = audioread(fullfile(path,file));
                       app.ReadAudioField.Value = 'file read';
                    catch 
                        app.ReadAudioField.Value = 'failed';
                    end
                    L = length(app.y_timeDomain);
                    t=(0:L-1)*(1/app.F_s);

                    plot(app.TimeDomainAxes, t*app.F_s, app.y_timeDomain);

                    y_freqDomain = fft(app.y_timeDomain);
                    plot(app.FreqDomainAxes, (0:L-1)*(app.F_s/L), abs(fftshift(y_freqDomain)));
                end
            end
        end
        %%%%%%%%%
        %
        % Output Audio
        %
        %%%%%%%%%
        % Button pushed function: WriteAudioButton
        function WriteAudioButtonPushed(app, event)
            try
                if "Speaker" == app.OutputDropDown.Value
                    soundsc(app.y_timeDomain, app.F_s);
                    app.WriteAudioField.Value = "played";
                elseif "Free Lossless Audio Codec (flac)" == app.OutputDropDown.Value
                    audiowrite("output.flac", app.y_timeDomain, app.F_s, 'BitsPerSample', 24, 'Comment', "Flac output file");
                    app.WriteAudioField.Value = "flac file created";
                elseif "Microsoft WAVE sound (wav)" == app.OutputDropDown.Value
                    audiowrite("output.wav", app.y_timeDomain, app.F_s);
                    app.WriteAudioField.Value = "wav file created";
                end
            catch
                app.WriteAudioField.Value = "failed";
            end
        end

        % Value changed function: InputDropDown
        function InputDropDownValueChanged(app, event)
            if "Microphone" == app.InputDropDown.Value
                app.StartStopRecordingButton.Visible = "on";
                app.ReadAudioButton.Visible = "off";
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
            recording = audiorecorder;
            if false == app.boRecordingFlag
                app.ReadAudioField.Value = "recording...";
                record(recording, "on");
                app.boRecordingFlag = true;                      
            elseif true == app.boRecordingFlag
                record(recording, "off");
                app.ReadAudioField.Value = "finished recordning";
                app.boRecordingFlag = false;
                app.F_s = recording.SampleRate;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create TimeDomainAxes
            app.TimeDomainAxes = uiaxes(app.UIFigure);
            title(app.TimeDomainAxes, 'Time domain')
            xlabel(app.TimeDomainAxes, 't / s')
            ylabel(app.TimeDomainAxes, 'Amplitude')
            zlabel(app.TimeDomainAxes, 'Z')
            app.TimeDomainAxes.XGrid = 'on';
            app.TimeDomainAxes.YGrid = 'on';
            app.TimeDomainAxes.Position = [21 36 300 185];

            % Create FreqDomainAxes
            app.FreqDomainAxes = uiaxes(app.UIFigure);
            title(app.FreqDomainAxes, 'Frequency domain')
            xlabel(app.FreqDomainAxes, 'f / Hz')
            ylabel(app.FreqDomainAxes, 'Magnitude')
            zlabel(app.FreqDomainAxes, 'Z')
            app.FreqDomainAxes.XGrid = 'on';
            app.FreqDomainAxes.YGrid = 'on';
            app.FreqDomainAxes.Position = [320 36 300 185];

            % Create InputsourceDropDownLabel
            app.InputsourceDropDownLabel = uilabel(app.UIFigure);
            app.InputsourceDropDownLabel.HorizontalAlignment = 'right';
            app.InputsourceDropDownLabel.FontWeight = 'bold';
            app.InputsourceDropDownLabel.Position = [32 415 77 22];
            app.InputsourceDropDownLabel.Text = 'Input source';

            % Create InputDropDown
            app.InputDropDown = uidropdown(app.UIFigure);
            app.InputDropDown.Items = {'Audiofile', 'Microphone'};
            app.InputDropDown.ValueChangedFcn = createCallbackFcn(app, @InputDropDownValueChanged, true);
            app.InputDropDown.Position = [21 394 100 22];
            app.InputDropDown.Value = 'Audiofile';

            % Create OutputDropDownLabel
            app.OutputDropDownLabel = uilabel(app.UIFigure);
            app.OutputDropDownLabel.HorizontalAlignment = 'right';
            app.OutputDropDownLabel.FontWeight = 'bold';
            app.OutputDropDownLabel.Position = [42 355 48 22];
            app.OutputDropDownLabel.Text = 'Output ';

            % Create OutputDropDown
            app.OutputDropDown = uidropdown(app.UIFigure);
            app.OutputDropDown.Items = {'Speaker', 'Free Lossless Audio Codec (flac)', 'Microsoft WAVE sound (wav)'};
            app.OutputDropDown.ValueChangedFcn = createCallbackFcn(app, @OutputDropDownValueChanged, true);
            app.OutputDropDown.Position = [21 334 100 22];
            app.OutputDropDown.Value = 'Speaker';

            % Create ReadAudioButton
            app.ReadAudioButton = uibutton(app.UIFigure, 'push');
            app.ReadAudioButton.ButtonPushedFcn = createCallbackFcn(app, @ReadAudioButtonPushed, true);
            app.ReadAudioButton.Position = [139 393 100 23];
            app.ReadAudioButton.Text = 'Read audio';

            % Create WriteAudioButton
            app.WriteAudioButton = uibutton(app.UIFigure, 'push');
            app.WriteAudioButton.ButtonPushedFcn = createCallbackFcn(app, @WriteAudioButtonPushed, true);
            app.WriteAudioButton.Position = [139 333 100 23];
            app.WriteAudioButton.Text = 'Write audio';

            % Create ReadAudioField
            app.ReadAudioField = uieditfield(app.UIFigure, 'text');
            app.ReadAudioField.Position = [256 394 100 22];

            % Create WriteAudioField
            app.WriteAudioField = uieditfield(app.UIFigure, 'text');
            app.WriteAudioField.Position = [256 333 100 22];

            % Create StartStopRecordingButton
            app.StartStopRecordingButton = uibutton(app.UIFigure, 'push');
            app.StartStopRecordingButton.ButtonPushedFcn = createCallbackFcn(app, @StartStopRecordingButtonPushed, true);
            app.StartStopRecordingButton.Visible = 'off';
            app.StartStopRecordingButton.Position = [139 393 100 23];
            app.StartStopRecordingButton.Text = 'Start / Stop ';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = InputOutputAudio_exported

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