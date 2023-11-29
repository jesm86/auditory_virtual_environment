function resultMatrix=plot1stOrdImgSrc(roomDimensions,sourceCoord,roomOrgin)
%The parameter passed in roomOrgin is the left,dwon,front corner of the
%cube that is passed in and taken as the Orgin of the room. For 1st order
%image source it is 0,0,0.

%Function that calculates 1st order reflection imf srcs and returns a 3 x
%6 array
%The below name spaces are named in respect to the cube drawn and is
%previewd from view type 3.

%"Left face"
%"Right face"
%"Top face"
%"Bottom face"
%"Back face"
%"Front face" 
%(x,y,z)


resultMatrix =[(0-abs(0-sourceCoord(1))) sourceCoord(2) sourceCoord(3);...
    (roomDimensions(1)+abs(roomDimensions(1)-sourceCoord(1))) sourceCoord(2) sourceCoord(3);...
    sourceCoord(1) sourceCoord(2) (roomDimensions(3)+abs(roomDimensions(3)-sourceCoord(3)));...
    sourceCoord(1) sourceCoord(2) (0-abs(0-sourceCoord(3)));...
    sourceCoord(1) (roomDimensions(2)+abs(sourceCoord(2)-roomDimensions(2))) sourceCoord(3);...
    sourceCoord(1) (0-abs(sourceCoord(2)-0)) sourceCoord(3);...
    ];

end