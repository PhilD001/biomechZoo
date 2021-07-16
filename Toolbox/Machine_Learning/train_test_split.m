function data=train_test_split(x,y,VariableName,subject,subject_wise,split,Normalize,seed)
% TRAIN_TEST_SPLIT spliting data into train test sets
%
% ARGUMENTS
%   x           ...   double array, features for classification.
%   y           ...   double array or cell array of char, conditions to classify.
%   VariableName...   cell array char, Name of the variables Use this VariableName=table_event.Properties.VariableNames(1:end-2);
%   subjects    ...   string cell, subject name of all the subjects.
%   subject_wise...   0 or 1,  subject_wise=0 random spliting subject_wise=1 data spliting based on subjects
%   split       ...   [0,1], percent of data to be hold out for testing.
%   Normalize   ...   'StandardScaler' or 'MinMaxScaler' or 'None' for selecting scaler to use
%   seed        ...   Positive integer. Random seed. Default 0
%
% RETURNS
%   data        ...  Struct containing train, test, Conditions, Classification parameters and etc...


% error checking
if nargin < 4
    error('insufficient arguments provided')
end

if nargin == 4
    subject_wise=0;
    split=0.25;
    Normalize='None';
    seed=0;
end

if nargin == 5
    split=0.25;
    Normalize='None';
    seed=0;
end

if nargin == 6
    Normalize='None';
    seed=0;
end
if nargin == 7
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
if contains(Normalize,'StandardScaler')
    [x_train,m,s]=normalize_data(x(train_index,:));
    data.x_train=x_train;
    data.mean=m;
    data.std=s;
elseif contains(Normalize,'MinMaxScaler')
    [x_train,Min,Max]=MinMax(x(train_index,:));
    data.x_train=x_train;
    data.Min=Min;
    data.Max=Max;
elseif contains(Normalize,'None')
    data.x_train=x(train_index,:);
else
    disp(['unknown scale ', Normalize, ' Check Normalizating setting'])
end

data.y_train=y(train_index);
x_test=x(test_index,:);
data=test_normalize(data,x_test,Normalize);
data.y_test=y(test_index);
data.train_subject=train_subject;
data.test_subject=test_subject;
data.Conditions=condi;
data.VariableName=VariableName;
data=parameters(data);

function [y,condi]=char2num(y)
temp=y;
y=zeros([length(y),1]);
condi=unique(temp);
for i=1:length(condi)
    y(contains(temp,condi{i}))=i;
end

function [x_train,m,s]=normalize_data(x_train)
m=mean(x_train);
s=std(x_train);
x_train=(x_train-m)./s;

function [x_train,MIN,MAX]=MinMax(x_train)
MIN=min(x_train);
MAX=max(x_train);
x_train=(2*(x_train-MIN)./(MAX-MIN))-1;

function data=test_normalize(data,x_test,Normalize)
if contains(Normalize,'StandardScaler')
    data.x_test=(x_test-data.mean)./data.std;
elseif contains(Normalize,'MinMaxScaler')
    data.x_test=(2*(x_test-data.Min)./(data.Max-data.Min))-1;
elseif contains(Normalize,'None')
    data.x_test=x_test;
end



function data=parameters(data)
%common parameters
data.Prior='empirical';
% Binary Classification Tree
data.BDT.AlgorithmForCategorical='Exact';
data.BDT.MaxNumCategories=10;
data.BDT.MaxNumSplits=1;
data.BDT.MergeLeaves='off';
data.BDT.MinLeafSize=1;
data.BDT.MinParentSize=10;
% Naive Bayes
data.NBayes.DistributionNames='kernel';
data.NBayes.Kernel='normal';
data.NBayes.Support='unbounded';
% k-Nearest Neighbor
data.knn.BucketSize=50;
data.knn.Distance='minkowski';
data.knn.Exponent=2;
data.knn.NSMethod='kdtree';
data.knn.NumNeighbors=1;
% Binary SVM
data.Bsvm.BoxConstraint=1;
data.Bsvm.KernelFunction='rbf';
data.Bsvm.KernelScale=1;
data.Bsvm.KernelOffset=0;
data.Bsvm.Solver='ISDA';
data.Bsvm.Nu=0.5;
% Binary Linear Classification
data.Blinear.Lambda='auto';
data.Blinear.Learner='svm';
data.Blinear.Regularization='ridge';
data.Blinear.Solver='lbfgs';
data.Blinear.TruncationPeriod=10;
% Binary Kernel Classification
data.Bkernel.Learner='svm';
data.Bkernel.NumExpansionDimensions='auto';
data.Bkernel.KernelScale=1;
data.Bkernel.Lambda='auto';
% Multiclass support vector machines
data.Msvm.Learners='svm';
data.Msvm.NumConcurrent=1;
