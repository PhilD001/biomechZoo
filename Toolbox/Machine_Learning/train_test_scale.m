function ml_data = train_test_scale(ml_data, Normalize)
%   x           ...   double array, features for classification.
%   y           ...   double array or cell array of char, conditions to classify.
%   VariableName...   cell array char, Name of the variables Use this VariableName=table_event.Properties.VariableNames(1:end-2);
%   subjects    ...   string cell, subject name of all the subjects.
%   subject_wise...   0 or 1,  subject_wise=0 random spliting subject_wise=1 ml_data spliting based on subjects
%   split       ...   [0,1], percent of ml_data to be hold out for testing.
%   Normalize   ...   'StandardScaler' or 'MinMaxScaler' or 'None' for selecting scaler to use
%   seed        ...   Positive integer. Random seed. Default 0
%
% scale

x_train = ml_data.x_train;


disp(['Scaling data using ', Normalize])

if contains(Normalize,'StandardScaler')
    error('Not implemented')
    %     [x_train,m,s]=StandardScaler(x_train);
    %     ml_data.x_train=x_train;
    %     ml_data.mean=m;
    %     ml_data.std=s;
elseif contains(Normalize,'MinMaxScaler')
    disp('MinMax scaling')
    if isa(ml_data.x_train,'double')
        ml_data.x_train= MinMax(ml_data.x_train);
        ml_data.x_test= MinMax(ml_data.x_test);
    elseif isa(ml_data.x_train,'cell')
        for j=1:length(ml_data.x_train)
            ml_data.x_train{j}=MinMax(ml_data.x_train{j});
        end
        for j=1:length(ml_data.x_test)
            ml_data.x_test{j}=MinMax(ml_data.x_test{j});
        end
    end
elseif contains(Normalize,'None')
    disp('no scaling')
else
    disp(['unknown scale ', Normalize, ' Check Normalizating setting'])
end

function rescalex=MinMax(x)
rowmin = min(x,[],2);
rowmax = max(x,[],2);
rescalex= rescale(x,'InputMin',rowmin,'InputMax',rowmax);

