function [overlapVector, outputVector] = prepareBlocks(blockSize, h)
% set convolution blocksize
convBlocksize=blockSize+length(h)-1;
% preallocate overlap
overlapVector = zeros(convBlocksize,1);

% preallocate output
outputVector = zeros(blockSize,2);
end

