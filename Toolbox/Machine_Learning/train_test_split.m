function ml_data=train_test_split(x,y,VariableName,subject,subject_wise,split,seed)
% TRAIN_TEST_SPLIT spliting ml_data into train test sets
%
% ARGUMENTS
%   x           ...   double array, features for classification.
%   y           ...   double array or cell array of char, conditions to classify.
%   VariableName...   cell array char, Name of the variables Use this VariableName=table_event.Properties.VariableNames(1:end-2);
%   subjects     ...  string cell, subject name of all the subjects.
%   subject_wise ...  bool, subject_wise=0 random spliting subject_wise=1 ml_data spliting based on subjects
%   split        ...  [0,1], percent of ml_data to be hold out for testing.
%   seed         ...  Positive integer. Random seed. Default 0
%
% RETURNS
%   ml_data        ...  Struct containing train, test, Conditions, Classification parameters and etc...


% error checking
if nargin < 5
    error('insufficient arguments provided')
end

if nargin == 3
    subject_wise=0;
    split=0.25;
    seed=0;
end

if nargin == 4
    split=0.25;
    seed=0;
end

if nargin == 5
    seed=0;
end
if nargin == 6
    seed=0;
end

if ~isa(y,'double')
    [y,condi]=char2num(y);
end

% set random seed
rng(seed)


% split 
if subject_wise==1
    subjects=unique(subject);
    n=length(subjects);
    indexs=randperm(n);
    test_split=round(split*n);
    test_index=indexs(1:test_split);
    test_subject=subjects(test_index);
    train_indexs=indexs(test_split+1:n);
    train_subject=subjects(train_indexs);
    test_index=find(contains(subject,test_subject)==1);
    train_index=find(contains(subject,test_subject)==0);
    
elseif subject_wise==0
    subjects=subject;
    n=length(subjects);
    indexs=randperm(n);
    test_split=round(split*n);
    test_index=indexs(1:test_split);
    train_index=indexs(test_split+1:n);
    test_subject=subjects(test_index);
    train_subject=subjects(train_index);
end

% scale
ml_data.x_train=x(train_index,:);
ml_data.y_train=categorical(y(train_index));
ml_data.x_test=x(test_index,:);
ml_data.y_test=categorical(y(test_index));
ml_data.train_subject=train_subject;
ml_data.test_subject=test_subject;
ml_data.Conditions=condi;
ml_data.VariableName=VariableName;

function [y,condi]=char2num(y)
temp=y;
y=zeros([length(y),1]);
condi=unique(temp);
for i=1:length(condi)
    y(contains(temp,condi{i}))=i;
end






