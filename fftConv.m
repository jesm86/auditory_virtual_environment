function fftConvolution = fftConv(v1,v2)
    % do zero padding with both signals
    [zeroPaddedV1,zeroPaddedV2]=zeroPad(v1,v2);
    
    % convert to frequency domain
    fftv1=fft(zeroPaddedV1);
    fftv2=fft(zeroPaddedV2);
    
    %convolute in frequency domain
    convolution_result = fftv1 .* fftv2;
    
    %inverse transform to time domain
    fftConvolution = ifft(convolution_result);
end