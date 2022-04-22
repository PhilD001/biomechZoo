function train_test_scale(ml_data, normalize)
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
x_test = ml_data.x_test;

if contains(Normalize,'StandardScaler')
    [x_train,m,s]=StandardScaler(x_train);
    ml_data.x_train=x_train;
    ml_data.mean=m;
    ml_data.std=s;
elseif contains(Normalize,'MinMaxScaler')
    [x_train,Min,Max]=MinMax(x(train_index,:));
    ml_data.x_train=x_train;
    ml_data.Min=Min;
    ml_data.Max=Max;
elseif contains(Normalize,'None')
    ml_data.x_train=x(train_index,:);
else
    disp(['unknown scale ', Normalize, ' Check Normalizating setting'])
end

ml_data.y_train=categorical(y(train_index));
x_test=x(test_index,:);
ml_data=test_normalize(ml_data,x_test,Normalize);
ml_data.y_test=categorical(y(test_index));
ml_data.train_subject=train_subject;
ml_data.test_subject=test_subject;
ml_data.Conditions=condi;


function [x_train,m,s]=StandardScaler(x_train)
m=mean(x_train);
s=std(x_train);
x_train=(x_train-m)./s;

function [x_train,MIN,MAX]=MinMax(x_train)
MIN=min(x_train);
MAX=max(x_train);
x_train=(2*(x_train-MIN)./(MAX-MIN))-1;

function ml_data=test_normalize(ml_data,x_test,Normalize)
if contains(Normalize,'StandardScaler')
    ml_data.x_test=(x_test-ml_data.mean)./ml_data.std;
elseif contains(Normalize,'MinMaxScaler')
    ml_data.x_test=(2*(x_test-ml_data.Min)./(ml_data.Max-ml_data.Min))-1;
elseif contains(Normalize,'None')
    ml_data.x_test=x_test;
end


