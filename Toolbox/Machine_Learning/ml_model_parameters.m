function ml_data=ml_model_parameters(ml_data, model_name, numHiddenUnits)
% ml_data=ml_model_parameters(ml_data, model_name, numHiddenUnits) sets
% parameters for different ml models

%common parameters
ml_data.Prior='empirical';

numFeatures = length(ml_data.x_train);
numClasses = length(unique(ml_data.y_train));

if nargin==2
    numHiddenUnits=100;
end

if strcmp(model_name,'BDT')
    % Binary Classification Tree
    ml_data.BDT.AlgorithmForCategorical='Exact';
    ml_data.BDT.MaxNumCategories=10;
    ml_data.BDT.MaxNumSplits=1;
    ml_data.BDT.MergeLeaves='off';
    ml_data.BDT.MinLeafSize=1;
    ml_data.BDT.MinParentSize=10;
    
elseif strcmp(model_name,'NBayes')
    % Naive Bayes
    ml_data.NBayes.DistributionNames='kernel';
    ml_data.NBayes.Kernel='normal';
    ml_data.NBayes.Support='unbounded';
elseif strcmp(model_name,'knn')
    
    % k-Nearest Neighbor
    ml_data.knn.BucketSize=50;
    ml_data.knn.Distance='minkowski';
    ml_data.knn.Exponent=2;
    ml_data.knn.NSMethod='kdtree';
    ml_data.knn.NumNeighbors=1;
    
elseif strcmp(model_name,'Bsvm')
    % Binary SVM
    ml_data.Bsvm.BoxConstraint=1;
    ml_data.Bsvm.KernelFunction='rbf';
    ml_data.Bsvm.KernelScale=1;
    ml_data.Bsvm.KernelOffset=0;
    ml_data.Bsvm.Solver='ISDA';
    ml_data.Bsvm.Nu=0.5;
    
elseif strcmp(model_name,'Blinear')
    % Binary Linear Classification
    ml_data.Blinear.Lambda='auto';
    ml_data.Blinear.Learner='svm';
    ml_data.Blinear.Regularization='ridge';
    ml_data.Blinear.Solver='lbfgs';
    ml_data.Blinear.TruncationPeriod=10;
    
elseif strcmp(model_name,'Bkernel')
    % Binary Kernel Classification
    ml_data.Bkernel.Learner='svm';
    ml_data.Bkernel.NumExpansionDimensions='auto';
    ml_data.Bkernel.KernelScale=1;
    ml_data.Bkernel.Lambda='auto';
elseif strcmp(model_name,'Msvm')
    % Multiclass support vector machines
    ml_data.Msvm.Learners='svm';
    ml_data.Msvm.NumConcurrent=1;
    
elseif strcmp(model_name,'FF')
    % forward feed
    ml_data.FF.layers = [
        featureInputLayer(numFeatures,'Name','input')
        %sequenceInputLayer(numFeatures,'Name','input')
        %bilstmLayer(numHiddenUnits,'OutputMode','last')
        %lstmLayer(numHiddenUnits,'OutputMode','last')
        fullyConnectedLayer(numClasses, 'Name','fc')
        softmaxLayer('Name','sm')
        classificationLayer('Name','classification')];
    
elseif strcmp(model_name,'LSTM')
    
    % LSTM
    if iscell(ml_data.x_train)
        [numFeatures,~]=size(ml_data.x_train{1});
    end
    ml_data.LSTM.layers = [
        sequenceInputLayer(numFeatures,'Name','input')
        lstmLayer(numHiddenUnits,'OutputMode','last')
        fullyConnectedLayer(numClasses, 'Name','fc')
        softmaxLayer('Name','sm')
        classificationLayer('Name','classification')];
    
elseif strcmp(model_name,'biLSTM')
    
    % BI LSTM
    ml_data.BiLSTM.layers = [
        sequenceInputLayer(numFeatures,'Name','input')
        bilstmLayer(numHiddenUnits,'OutputMode','last')
        fullyConnectedLayer(numClasses, 'Name','fc')
        softmaxLayer('Name','sm')
        classificationLayer('Name','classification')];
end

% CNN1D data prepration
if contains(model_name,'CNN')
    error('not implemented')
    ml_data=CNN1D_data_prepration(ml_data);
end

% adding deep learning options
ml_data.deeplearning.maxEpochs = 20;
ml_data.deeplearning.miniBatchSize = 8;
ml_data.deeplearning.options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',ml_data.deeplearning.maxEpochs, ...
    'MiniBatchSize',ml_data.deeplearning.miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0, ...
    'Plots','training-progress');
