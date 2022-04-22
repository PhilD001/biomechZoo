function ml_data = train_test_split(x, y, subject, subject_wise, split, seed)
% TRAIN_TEST_SPLIT spliting data into train test sets
%
% ARGUMENTS
%   x            ...   double array, features for classification.
%   y            ...   double array or cell array of char, conditions to classify.
%   subjects     ...   string cell, subject name of all the subjects.
%   subject_wise ...   bool, subject_wise=0 random spliting subject_wise=1 data spliting based on subjects
%   split        ...   [0,1], percent of data to be hold out for testing.
%   seed         ...   Positive integer. Random seed. Default 0
%
% RETURNS
%   ml_data        ...  Struct containing train, test, Conditions, ...


% error checking
if nargin < 3
    error('insufficient arguments provided')
end

if nargin == 3
    split=0.25;
    seed=0;
end

if nargin == 4
    seed=0;
end

% set random seed
rng(seed)


% split 
if subject_wise
    disp('splitting data into train / test sets via inter-subject scheme (subject_wise = true)')
    subjects=unique(subject);
    n=length(subjects);
    indexs=randperm(n);
    test_split=round(split*n);
    test_index=indexs(1:test_split);
    test_sub=subjects(test_index);
    train_indices=indexs(test_split+1:n);
    train_sub=subjects(train_indices);
    test_index=find(contains(subject,test_sub)==1);
    train_index=find(contains(subject,test_sub)==0);
    
else
    disp('splitting data into train / test sets via intra-subject scheme (subject_wise = false)')
    subjects=subject;
    n=length(subjects);
    indexs=randperm(n);
    test_split=round(split*n);
    test_index=indexs(1:test_split);
    train_index=indexs(test_split+1:n);
    test_sub =subjects(test_index);
    train_sub=subjects(train_index);
end


% add to struct
ml_data = struct;
ml_data.x_train = x(train_index);
ml_data.x_test = x(test_index);
ml_data.y_train = y(train_index);
ml_data.y_test = y(test_index);
ml_data.train_index = train_index;
ml_data.test_index = test_index;
ml_data.train_subject = train_sub;
ml_data.test_subject = test_sub;



