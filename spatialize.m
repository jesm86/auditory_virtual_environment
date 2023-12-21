function [spatializedAudio] = spatialize(recording, hrir_set, sampling_rate)
    recordingLength = length(recording);
    eighthLength = floor(recordingLength / 8);
    elevation = 0;
    azimuth = [0, 45, 90, 135, 180, 225, 270, 315];
    
    spatializedAudio_left = [];
    spatializedAudio_right = [];
    for i =  1:8
        [eleIndex(1), eleIndex(2), azIndex(1,1), azIndex(1,2), azIndex(1,3), azIndex(1,4), eValues, aValues(1,:)] = findHRIRindex(elevation, azimuth(i));
        [eleIndex(1), eleIndex(2), azIndex(2,1), azIndex(2,2), azIndex(2,3), azIndex(2,4), ~, aValues(2,:)] = findHRIRindex(elevation, (360 - azimuth(i)));
        for j = 1:floor((512/(44100/sampling_rate)))
           hrir_left(i, j) = interpolateN([hrir_set{eleIndex(1)}{azIndex(1,1)}(j), hrir_set{eleIndex(1)}{azIndex(1,2)}(j)],...
                                 [hrir_set{eleIndex(2)}{azIndex(1,3)}(j), hrir_set{eleIndex(2)}{azIndex(1,3)}(j)],...
                                 eValues, [aValues(1,1), aValues(1,2)], [aValues(1,3), aValues(1,4)], elevation, azimuth(i));
           hrir_right(i, j) = interpolateN([hrir_set{eleIndex(1)}{azIndex(1,1)}(j), hrir_set{eleIndex(1)}{azIndex(1,2)}(j)],...
                                 [hrir_set{eleIndex(2)}{azIndex(1,3)}(j), hrir_set{eleIndex(2)}{azIndex(1,3)}(j)],...
                                 eValues, [aValues(2,1), aValues(2,2)], [aValues(2,3), aValues(2,4)], elevation, (360 - azimuth(i)));
           
        end
        lower_index = (i - 1) * eighthLength + 1;
        upper_index = i * eighthLength;
        
        audio_segment = recording(lower_index : upper_index);
        convolvedPart_left = fftConv(transpose(audio_segment), hrir_left(i));
        convolvedPart_right = fftConv(transpose(audio_segment), hrir_right(i));
        
        spatializedAudio_left = [spatializedAudio_left; convolvedPart_left];
        spatializedAudio_right = [spatializedAudio_right; convolvedPart_right];
    end
    spatializedAudio = {spatializedAudio_left, spatializedAudio_right};
end

