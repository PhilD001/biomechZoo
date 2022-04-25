function data=train_test_split(x,y,VariableName,subject,subject_wise,split,seed)
% TRAIN_TEST_SPLIT spliting data into train test sets
%
% ARGUMENTS
%   x           ...   double array, features for classification.
%   y           ...   double array or cell array of char, conditions to classify.
%   VariableName...   cell array char, Name of the variables Use this VariableName=table_event.Properties.VariableNames(1:end-2);
%   subjects    ...   string cell, subject name of all the subjects.
%   subject_wise...   0 or 1,  subject_wise=0 random spliting subject_wise=1 data spliting based on subjects
%   split       ...   [0,1], percent of data to be hold out for testing.
%   seed        ...   Positive integer. Random seed. Default 0
%
% RETURNS
%   data        ...  Struct containing train, test, Conditions, Classification parameters and etc...


% error checking
if nargin < 3
    error('insufficient arguments provided')
end

if nargin == 3
    subject_wise=0;
    split=0.25;
    Normalize='None';
    seed=0;
end

if nargin == 4
    split=0.25;
    Normalize='None';
    seed=0;
end

if nargin == 5
    Normalize='None';
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
data.x_train=x(train_index,:);
data.y_train=categorical(y(train_index));
data.x_test=x(test_index,:);
data.y_test=categorical(y(test_index));
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

% forward feed
numFeatures = length(data.x_train);
numClasses = length(unique(data.y_train));

data.FF.layers = [
    featureInputLayer(numFeatures,'Name','input')
    fullyConnectedLayer(numClasses, 'Name','fc')
    softmaxLayer('Name','sm')
    classificationLayer('Name','classification')];

% LSTM
if iscell(data.x_train)
[numFeatures,~]=size(data.x_train{1});
end
numHiddenUnits=100;
data.LSTM.layers = [
    sequenceInputLayer(numFeatures,'Name','input')
    lstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses, 'Name','fc')
    softmaxLayer('Name','sm')
    classificationLayer('Name','classification')];

% BI LSTM
data.BiLSTM.layers = [
    sequenceInputLayer(numFeatures,'Name','input')
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses, 'Name','fc')
    softmaxLayer('Name','sm')
    classificationLayer('Name','classification')];

% adding deep learning options
data.deeplearning.maxEpochs = 20;
data.deeplearning.miniBatchSize = 8;
data.deeplearning.options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',data.deeplearning.maxEpochs, ...
    'MiniBatchSize',data.deeplearning.miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0, ...
    'Plots','training-progress');



