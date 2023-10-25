function [newV1,newV2] = zeroPad(v1,v2)
    % get next pow2 of vector
    pot1=log2(length(v1));
    pot1=ceil(pot1);

    pot2=log2(length(v2));
    pot2=ceil(pot2);

    len=0;
    if pot1>pot2
        len=pow2(pot1)-1;
    else
        len=pow2(pot2)-1;
    end
    %create empty vectors
    newV1=zeros(len, 1);
    newV2=zeros(len, 1);

    newV1(1:length(v1))=v1;
    newV2(1:length(v2))=v2;
    %test   
end