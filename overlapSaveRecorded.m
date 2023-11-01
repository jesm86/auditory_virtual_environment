function [audioConv] = overlapSaveRecorded(audio,h,blocksize)
%Calls the overlap save function for recorded audio

convBlocksize=blocksize+length(h)-1;
audio = cat(1,zeros(convBlocksize-blocksize,1),audio);  %append zeros at beginning to audio

audioConv = zeros(length(audio)+length(h)-1,1);
runs=ceil(length(audio)/blocksize);
for i = 0:runs
    try
        start=blocksize*i+1;
        stop=start+convBlocksize;
        overlapSaveReturn = fftConv(audio(start:stop),h);
        audioConv(start:start+blocksize) = overlapSaveReturn(convBlocksize-blocksize:convBlocksize);
    catch
        while (stop > length(audio) && start <= length(audio))
            audio = cat(1,audio,0);
        end
        overlapSaveReturn = fftConv(audio(start:stop),h);
        audioConv(start:start+blocksize) = overlapSaveReturn(convBlocksize-blocksize:convBlocksize);
    end


    
end


end