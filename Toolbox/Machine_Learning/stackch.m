function x_t=stackch(x)

% x_t=stackch(x) converts cell array data extracted using bemech_zoo2table to a
% single double array for the classification
% Prepares input data for a forwardfeed network
%
% ARGUMENTS
%   x             ...   Predictor channels extracted using bmech_zoo2table.m
% 
% RETURNS
%   x_t           ...   double array, stacked channels

[L,W]=size(x);
input_size=0;
input_end=1;
for i=1:W
    input_size=input_size+length(x{1,i});
    input_end=[input_end,input_size+1];
end
x_t=zeros(L,input_size);

for j=1:L
    for i=1:length(input_end)-1
        x_t(j,input_end(i):input_end(i+1)-1)=table2array(table(x{j,i})).';
    end
end