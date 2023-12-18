%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: IRfromCuboid.m
%
%   This module renders the image sources for a given source and
%   receiver pair in a given three dimensional cuboid room. The amount of rendered
%   image sources is restricted by setting a maximal reverberation time.
%   Additionally, different wall absorption coefficients for all six walls
%   of the cuboid have to be set by the user.
%
%
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             03.12.23    L.Gildenstern            created
%   1.1             05.12.23    J.Smith, T.W.    comments added
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   param[in]       roomDimensions  Dimensions of the room for rendering [x, y, z] in m
%   param[in]       sourceCoord         Coordinates of sound source in room [x, y, z] in m
%   param[in]       receiverCoord       Coordinates of receiver in room [x, y, z] in m
%   param[in]       maxReverb           maximal reverberation time for rendering walls 
%                                                      [left, right, front, back, floor, ceiling], range[0:1]
%   param[in]       Fs                         sampling rate of rendered impulse response
%
%   retval             iR                          vector containing rendered impulse response
%   retval             isourceCoord        coordinates of calculated image sources
%   retval             delay                     vector containing delay [s] of associated image sources
%   retval             dist                        vector containing distance [m] of associated image sources
function [iR,isourceCoord,delay,dist] = IRfromCuboid(roomDimensions,sourceCoord,receiverCoord,maxReverb,wallCoeff,Fs)

% Speed of sound [m/s]
c_sound = 343; 

Lx = roomDimensions(1); 
Ly = roomDimensions(2);
Lz = roomDimensions(3);
x = sourceCoord(1);
y = sourceCoord(2);
z = sourceCoord(3);

%{
Pre allocation with zeros is used for perfromance.
In the 4 dimensional sourceXYZ array the first dimension holds the x,y,z
cordinates of the 3D vector space.

The 8 cuboids of vertices around the orgin (0,0,0) are classified in the 2nd, 
3rd & 4th dimensional array of sourceXYZ.

In the nested for loops the mirrored image soruces across the x,y,z axis
are calculated by inverting the signs of the source's coordinates.
%}
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

% Calculating the maximal allowable distance of an image source using the
% maximal reverberation time specified by the user and the speed of sound
maxDist = maxReverb * c_sound;
n = ceil(maxDist / roomDimensions(1));
l = ceil(maxDist / roomDimensions(2));
m = ceil(maxDist / roomDimensions(3));

nVect = -n:n;
lVect = -l:l;
mVect = -m:m;

% Preallocation for performance improvement
isourceLen=length(nVect)*length(lVect)*length(mVect);
isourceCoord = zeros(isourceLen,3);
coefs = zeros(isourceLen,1);

% Loop over n,l,m and shifiting origins
% Loop over maximal distances and calculate image sources additional allowable image
% sources 
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
                        
                        % Calculate wall absorption coefficients
                        % x-axis
                        if (sign(a) == sign(n)) || (n==0 && a>0)    
                            u=1;
                        else
                            u=0;
                        end

                        if (n>0)
                            u=u-1;
                        end
                        
                        %y-axes
                        if (sign(b) == sign(l)) || (l==0 && b>0)
                            v=1;
                        else
                            v=0;
                        end

                        if (l>0)
                            v=v-1;
                        end
                        
                        %z-axes
                        if (sign(c) == sign(m)) || (m==0 && c>0)
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

% Allocate vector for impulse response
iR = zeros(maxReverb*Fs,1);

% Calculate delay of image source in impulse resonse
dist = sqrt(sum((isourceCoord-receiverCoord).^2, 2));
delay = round((Fs/c_sound)*dist);

% Remove all items still exceeding max reverberation time
% This will be the ones with a diagonal path (thus, cuboid becomes sphere)
isourceCoord = isourceCoord(delay < maxReverb*Fs,:);
coefs = coefs(delay < maxReverb*Fs);
delay = delay(delay < maxReverb*Fs);

% add reverberations to imulse response
for i = 1:numel(delay)
    iR(delay(i)) = iR(delay(i)) + coefs(i);
end


end