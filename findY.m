function [y_val] = findY(gradient,y_intercept,x_val)
%FINDY Summary of this function goes here
%   Detailed explanation goes here
y_val = gradient*x_val +y_intercept;
end

