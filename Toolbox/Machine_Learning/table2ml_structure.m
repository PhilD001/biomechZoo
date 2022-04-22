function [x, y, VariableName, subject] = table2ml_structure(table_data, model_name)
%
% table2ml_structure(table_data, model_name) prepares data in Matlab table
% format for input to machine learning models
%
% ARGUMENTS
%   table_data    ...   table. See bmech_zoo2table
%   model_name    ...   string. Model to be implemented. 
%                       Choices {'FF' 'LSTM', 'BilS', 'CNN', 'stack',
%                       'sequence', 'features'}
% RETURNS
%   x             ...   depen


if ismember(model_name,{'FF', 'stack'})
    x=table2array(table_data(:,1:length(table_data.Properties.VariableNames)-2));
    x=stackch(x);
    y= table_data.Conditions;
    subject=table_data.Subject;
    VariableName=table_data.Properties.VariableNames(1:end-2);
    % Sequence ch
elseif ismember(model_name,{'LSTM','BiLS','CNN', 'sequence'})
    x=table2array(table_data(:,1:length(table_data.Properties.VariableNames)-2));
    x=sequencech(x);
    y= table_data.Conditions;
    subject=table_data.Subject;
    VariableName=table_data.Properties.VariableNames(1:end-2);
else 
    % Feature extraction
    % - extracts basic statistical features from table_data
    table_event=feature_extraction(table_data,ch);
    x=table2array(table_event(:,1:length(table_event.Properties.VariableNames)-2));
    y= table_event.Conditions;
    subject=table_event.Subject;
    VariableName=table_event.Properties.VariableNames(1:end-2);
end