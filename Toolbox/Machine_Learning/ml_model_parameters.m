function data=ml_model_parameters(data)
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
    %sequenceInputLayer(numFeatures,'Name','input')
    %bilstmLayer(numHiddenUnits,'OutputMode','last')
    %lstmLayer(numHiddenUnits,'OutputMode','last')
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
