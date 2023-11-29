function cubePlanes = generateCubePlanes(length, width, height)
% Define the coordinates of the cube vertices
vertices = [
    0, 0, 0;  % Vertex 1
    length, 0, 0;  % Vertex 2
    length, width, 0;  % Vertex 3
    0, width, 0;  % Vertex 4
    0, 0, height;  % Vertex 5
    length, 0, height;  % Vertex 6
    length, width, height;  % Vertex 7
    0, width, height  % Vertex 8
    ];

% Define the faces of the cube along with descriptive name tags
faces = {
    {'Bottom face', [1, 2, 3, 4]};  % Bottom face
    {'Top face', [5, 6, 7, 8]};  % Top face
    {'Front face', [1, 2, 6, 5]};  % Front face
    {'Right face', [2, 3, 7, 6]};  % Right face
    {'Back face', [3, 4, 8, 7]};  % Back face
    {'Left face', [4, 1, 5, 8]}  % Left face
    };

% Create the cell array with name tags
cubePlanes = cell(size(faces, 1), 2);
for i = 1:size(faces, 1)
    % Extract the vertex coordinates for the current face
    faceVertices = vertices(faces{i}{2}, :);

    % Get the name tag for the current face
    nameTag = faces{i}{1};

    % Store the face data in the cell array
    cubePlanes{i, 1} = faceVertices;
    cubePlanes{i, 2} = nameTag;
end
end
