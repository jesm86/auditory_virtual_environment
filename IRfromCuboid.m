function [iR,isourceCoord,delay,dist] = IRfromCuboid(roomDimensions,sourceCoord,receiverCoord,maxReverb,wallCoeff,Fs)
% roomDimensions=[x,y,z] in m
% sourceCoord=[x,y,z] in m
% receiverCoord=[x,y,z] in m  
% maxReverb=t in s;
% wallCoef=[left, right, front, back, floor, ceiling]  range[0:1]
% Fs=44100;

c_sound = 343; % Speed of sound (m/s)

% calculate image sources with looping over n,l,m
% calculate order of image source while creating it
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

%  function calculate range of n,l,m cuboid
maxDist = maxReverb * c_sound;
n = ceil(maxDist / roomDimensions(1));
l = ceil(maxDist / roomDimensions(2));
m = ceil(maxDist / roomDimensions(3));
%not used because of performance
% {n=1;
% l=1;
% m=1;

nVect = -n:n;
lVect = -l:l;
mVect = -m:m;

isourceLen=length(nVect)*length(lVect)*length(mVect);
isourceCoord = zeros(isourceLen,3);
coefs = zeros(isourceLen,1);
i=1;
for n = nVect
    for l = lVect
        for m = mVect
            xyz = [n*2*Lx; l*2*Ly; m*2*Lz];
            isourceCoords = xyz - sourceXYZ;
            
            
            for a=-1:2:1
                ax=round(a/2+1);   %converts range to 1:2
                for b=-1:2:1
                    bx=round(b/2+1);   %converts range to 1:2
                    for c=-1:2:1
                        cx=round(c/2+1);   %converts range to 1:2
                        % x-axis
                        u = sign(n)*-1;
                        if (sign(a) == sign(n)) || (n==0 && a<0)    % (check direction)
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

% Create impulse Response from room
% create dirac pulse, signal length is maxReverb
% for each image source add a dirac pulse shifted by distance to receiver
% times the wallCoef power the order of image source
% iR =+ dirac.shift(distance,maxReverb) * wallcoef ** order

% declare dirac pulse
iR = zeros(maxReverb*Fs,1);

%calc delay
dist = sqrt(sum((isourceCoord-receiverCoord).^2, 2));
delay = round((Fs/c_sound)*dist);

%delete all items exceeding maxReverb*Fs
isourceCoord = isourceCoord(delay < maxReverb*Fs,:);
coefs = coefs(delay < maxReverb*Fs);
delay = delay(delay < maxReverb*Fs);

for i = 1:numel(delay)
    iR(delay(i)) = iR(delay(i)) + coefs(i);
end


end