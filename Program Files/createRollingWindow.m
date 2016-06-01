function [ output ] = createRollingWindow( vector,n )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
l = length(vector);
%m = l - n + 1;
m = l - n + 1;
%output = vector(hankel(1:m, m:l));
output = vector(m:l);

end

