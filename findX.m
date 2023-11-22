function [x_val] = findX(gradient,y_intercept,y_val)
%FINDY Summary of this function goes here
%   Detailed explanation goes here
x_val = y_val-y_intercept/(gradient);
end

