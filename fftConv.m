%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: fftConv.m
%
%   This module performs fast fft-based convolution. The two input vectors
%   are first zero-padded using the zeroPad function of the zeroPad.m
%   module. The result will be two versions of the vectors will have an
%   appropriate length, that is also a power of 2. This ensures that the
%   built-in FFT function of matlab will really use the FFT and not the
%   slower DFT. In the frequency domain the two spectra will be multiplied
%   and then transfered back to the time domain using the inverse FFT
%   function. According to the convolution property of the FFT, this whole
%   procedure will yield the same result as directly convolving the two vectors in
%   the time domain.
%
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             18.10.23    L. Gildenstern           initial version  
%   1.1             04.11.23    J.Smith                      comments added, changed variable names  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% param[in]         vector1            first vector of fft convolution
% param[in]         vector2            second vector fft convolution 
% retval               fftConvolution  Result of fft convolution
function fftConvolution = fftConv(vector1,vector2)

    % Call zeroPad function to zero pad both vectors to appropriate length
    [zeroPaddedV1,zeroPaddedV2]=zeroPad(vector1,vector2);
    
    % Perform FFT on both zero padded to get the spectra of them
    fftv1=fft(zeroPaddedV1);
    fftv2=fft(zeroPaddedV2);
    
    % Multiply spectra of the two vectors (i.e. Convolution in time domain)
    convolution_result = fftv1 .* fftv2;
    
    % Perform inverse FFT of result to get time domain representation
    fftConvolution = ifft(convolution_result);
end