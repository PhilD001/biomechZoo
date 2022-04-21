function x_t=sequencech(x)
% sequencech converts cell array data extracted using bemech_zoo2table to a
% sequence cell array for the classification
% Prepares input data for a sequential neural network (LSTM, BiLSTM)
% ARGUMENTS
% x             ...   Predictor channels extracted using bmech_zoo2table.m
% RETURNS
% x_t           ...   cell array, channels in a sequence
x_t={};
[L,~]=size(x);
for j=1:L
    x_t(j)={cell2mat(x(j,1:end)).'};
end
x_t=x_t.';
