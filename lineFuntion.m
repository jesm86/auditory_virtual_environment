function  [gradient, y_intercept]= lineFuntion(point1, point2)
% Extract the coordinates of the two points
x1 = point1(1);
y1 = point1(2);
x2 = point2(1);
y2 = point2(2);

% Calculate the slope of the line
gradient = (y2 - y1) / (x2 - x1);

% Calculate the y-intercept of the line
y_intercept = y1 - (gradient * x1);
end