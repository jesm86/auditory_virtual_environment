function [iR,isourceCoord,delay,dist] = IRfromCuboid(roomDimensions,sourceCoord,receiverCoord,maxReverb,wallCoeff,Fs)
% roomDimensions=[x,y,z] in m
% sourceCoord=[x,y,z] in m
% receiverCoord=[x,y,z] in m  
% maxReverb=t in s;
% wallCoef=[left, right, front, back, floor, ceiling]  range[0:1]
% Fs=44100;

c_sound = 343; % Speed of sound (m/s)

% calculate image sources aroudn origin with looping over n,l,m
Lx = roomDimensions(1); 
Ly = roomDimensions(2);
Lz = roomDimensions(3);
x = sourceCoord(1);
y = sourceCoord(2);
z = sourceCoord(3);
sourceXYZ = zeros(3,2,2,2);
nx=1;
for n=-1:2:1
    lx=1;
    for l=-1:2:1
        mx=1;
        for m=-1:2:1
            sourceXYZ(:,nx,lx,mx)=[n*x,l*y,m*z];
            mx=mx+1;
        end
        lx=lx+1;
    end
    nx=nx+1;
end

%  function calculate range of n,l,m; create cuboid
maxDist = maxReverb * c_sound;
n = ceil(maxDist / roomDimensions(1));
l = ceil(maxDist / roomDimensions(2));
m = ceil(maxDist / roomDimensions(3));

nVect = -n:n;
lVect = -l:l;
mVect = -m:m;

%preallocate output vector of image sources and coefficients
isourceLen=length(nVect)*length(lVect)*length(mVect);
isourceCoord = zeros(isourceLen,3);
coefs = zeros(isourceLen,1);

%loop over n,l,m and shifiting origins
i=1;
for n = nVect
    for l = lVect
        for m = mVect
            xyz = [n*2*Lx; l*2*Ly; m*2*Lz];
            isourceCoords = xyz - sourceXYZ;
            
            %loop over image sources around shifted origin 
            for a=-1:2:1
                ax=round(a/2+1);   %converts range to 1:2
                for b=-1:2:1
                    bx=round(b/2+1);   %converts range to 1:2
                    for c=-1:2:1
                        cx=round(c/2+1);   %converts range to 1:2
                        
                        %calculate wallcoefficients
                        % x-axis
                        u = sign(n)*-1;
                        if (sign(a) == sign(n)) || (n==0 && a<0)    
                            u=1;
                        else
                            u=0;
                        end

                        if (n>0)
                            u=u-1;
                        end
                        
                        %y-axes
                        if (sign(b) == sign(l)) || (l==0 && b<0)
                            v=1;
                        else
                            v=0;
                        end

                        if (l>0)
                            v=v-1;
                        end
                        
                        %z-axes
                        if (sign(c) == sign(m)) || (m==0 && c<0)
                            w=1;
                        else
                            w=0;
                        end

                        if (m>0)
                            w=w-1;
                        end

                        coefs(i) = wallCoeff(1)^(abs(n)+u)...
                                 * wallCoeff(2)^abs(n)...
                                 * wallCoeff(3)^(abs(l)+v)...
                                 * wallCoeff(4)^abs(l)...
                                 * wallCoeff(5)^(abs(m)+w)...
                                 * wallCoeff(6)^abs(m);
                        
                        %set output
                        isourceCoord(i,:)=isourceCoords(:,ax,bx,cx);
                        i=i+1;
                        mx=mx+1;
                    end
                    lx=lx+1;
                end
                nx=nx+1;
            end
        end
    end
end

% declare dirac pulse
iR = zeros(maxReverb*Fs,1);

%calc delay in steps of iR
dist = sqrt(sum((isourceCoord-receiverCoord).^2, 2));
delay = round((Fs/c_sound)*dist);

%delete all items exceeding maxReverb*Fs; cuboid -> sphere
isourceCoord = isourceCoord(delay < maxReverb*Fs,:);
coefs = coefs(delay < maxReverb*Fs);
delay = delay(delay < maxReverb*Fs);

% add reverberations to iR
for i = 1:numel(delay)
    iR(delay(i)) = iR(delay(i)) + coefs(i);
end


end