function intersection_point = interSecFind(point1, point2, surface_points)
% point1 and point2 are 3D coordinates as [x, y, z]
% surface_points is a 4x3 matrix representing the square surface

% Extract coordinates
x1 = point1(1);
y1 = point1(2);
z1 = point1(3);

x2 = point2(1);
y2 = point2(2);
z2 = point2(3);

% Create a vector representing the line
line_vector = [x2 - x1, y2 - y1, z2 - z1];

% Calculate the normal vector of the plane using the surface points
v1 = surface_points(2, :) - surface_points(1, :);
v2 = surface_points(3, :) - surface_points(1, :);
normal_vector = cross(v1, v2);

% Find the intersection point
t = dot(surface_points(1, :) - [x1, y1, z1], normal_vector) / dot(line_vector, normal_vector);
intersection_point = [x1, y1, z1] + t * line_vector;
end
