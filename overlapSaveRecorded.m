function [audioConv] = overlapSaveRecorded(audio,h,blocksize)
%Calls the overlap save function for recorded audio

% block length of total signal for convolution
convBlocksize=blocksize+length(h)-1;

%append zeros at beginning to audio
audio = cat(1,zeros(convBlocksize-blocksize,1),audio);

%preallocate vector for output
audioConv = zeros(length(audio)+length(h)-1,1);

runs=ceil(length(audio)/blocksize);
for i = 0:runs
    try
        start=blocksize*i+1;        %1, blocksize+1, 2*blocksize+1
        stop=start+convBlocksize-1;
        %convolute block of size convblocksize
        overlapSaveReturn = fftConv(audio(start:stop),h);
        %add block of size blocksize beginning from the end of vector to
        %return vector
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