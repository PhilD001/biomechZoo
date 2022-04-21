function ml_data=CNN1D_data_prepration(ml_data)
% CNN1D_data_prepration converts train and test inputs to a 4D array
% Prepares input data for CNN1D
% ARGUMENTS
% ml_data       ...   struct, data struct extracted using train_test_split
% RETURNS
% ml_data       ...   struct, with CNN1D layers and train/test 4D array
for j=1:length(ml_data.x_train)
    trainD(:,:,:,j)=ml_data.x_train{j};
end
ml_data.x_train=trainD;
for j=1:length(ml_data.x_test)
    testD(:,:,:,j)=ml_data.x_test{j};
end
ml_data.x_test=testD;
%CNN parameters
[ch,timeseries, ~, ~]=size(ml_data.x_train);
numClasses = length(unique(ml_data.y_train));
ml_data.CNN.layers = [ imageInputLayer([ch timeseries 1])
convolution2dLayer(5,20)
reluLayer
maxPooling2dLayer(2,'Stride',2)
fullyConnectedLayer(numClasses)
softmaxLayer
classificationLayer];
