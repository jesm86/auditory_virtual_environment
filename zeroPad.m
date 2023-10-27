function [newV1,newV2] = zeroPad(v1,v2)
    
    len = length(v1) + length(v2) - 1;
    pot = ceil(log2(len));
    len = pow2(pot);

    %create empty vectors
    newV1=zeros(len, 1);
    newV2=zeros(len, 1);

    newV1(1:length(v1))=v1;
    newV2(1:length(v2))=v2;
    %test   
end