function [ml_data,stats,Mdl]=Introduction_to_deep_learning_capabilities_of_BiomechZoo(model_name)
% Introduction_to_deep_learning_capabilities_of_BiomechZoo
% biomechZoo machine learning processing template for mocap data
%
% This sample script shows how to run a toy binary classification model which
% aims to predict gait condition (straight vs turning) based on events
% (features) extracted from the biomechzoo sample data, available at
% https://github.com/PhilD001/biomechzoo-help/sample study/Data/zoo files (auto process)*
%
% * the terminal folder 'zoo files (auto process)' is only available after
% having run the samplestudy_process.m script
%
% REQUIREMENTS
% - biomechZoo and biomechZoo-help installed
% - Statistical and Machine learning toolbox
% - Deep learning toolbox
%
% NOTES:
%   Conditions (y): Straight, Turn
%   Predictors (x): Hip, knee, ankle joint angles for right and left side
%
% ARGUMENTS
% model_name     ...   srting or character,
%                          'BDT'     --> Binary Classification Tree
%                          'NBayes'  --> Naive bayes
%                          'knn'     --> k-Nearest Neighbor Classifier
%                          'Bsvm'    --> Binary support vector machines
%                          'Blinear' --> Binary Linear Classification
%                          'Bkernel' --> Binary Kernel Classification
%                          'Msvm'    --> Multiclass support vector machines
%                          'FF'      --> Forward Feed Neural network
%                          'LSTM'    --> Long short-term memory
%                          'BiLS'  --> Bidirectional Long short-term memory
%                          'CNN'     --> Convolutional neural network
% Returns
% ml_data       ...   struct, struct extracted by train_test_split
% stats         ...   table, table of performance stats
% Mdl           ...   Trained model
%
%% Data selection
% - select 'zoo files (auto process)' from biomechZoo sample study
if nargin == 0
    model_name = 'LSTM';
end

mode = 'auto';                                                             % entire code
if strfind(mode,'auto')                                                    %#ok<*STRIFCND>
    tic
    rfld = fullfile(fileparts(which('samplestudy_process')),'Data');
    fld = fullfile(rfld,'zoo files (auto process)');

    if ~exist(fld, 'dir')
        disp('running samplestudy_process to obtain processed data...')
        samplestudy_process
        rfld = fullfile(fileparts(which('samplestudy_process')),'Data');
        fld = fullfile(rfld,'zoo files (auto process)');
    end

else
    fld = uigetfolder;
end


%
ch = {'RightHipAngle_x','RightHipAngle_y','RightHipAngle_z',...
    'RightKneeAngle_x','RightKneeAngle_y','RightKneeAngle_z'...
    'RightAnkleAngle_x','RightAnkleAngle_y','RightAnkleAngle_z',...
    'LeftHipAngle_x','LeftHipAngle_y','LeftHipAngle_z',...
    'LeftKneeAngle_x','LeftKneeAngle_y','LeftKneeAngle_z'...
    'LeftAnkleAngle_x','LeftAnkleAngle_y','LeftAnkleAngle_z'};

[subjects, Conditions] = extract_filestruct(fld);
Conditions=unique(Conditions);


%% EXTRACT DATA FROM ZOO FILES TO TABLE FORMAT
% - If feature engineering is required it is performed in this step
%
if ~ismember(model_name,{'LSTM','BiLS','CNN', 'sequence', 'FF' 'stack'})
    bmech_feature_extraction(fld, ch)
    table_data = bmech_events2table(fld);
else
    table_data = bmech_line2table(fld,ch,subjects,Conditions);
end


%% Reformat tble data for machine learning
% %todo: describe x, y
[x, y, VariableName, subject] = table2ml_structure(table_data, model_name);


%% Split data into training and test set
% - ml_data is struct containing train and test fields
subject_wise=true;
split=0.30;
seed=0;
ml_data=train_test_split(x,y,VariableName,subject,subject_wise,split,seed);


%% scale data
% - scaling is conducted on train set and applied to test set to avoid
% 'information leakage'

normalize='MinMax';
ml_data = train_test_scale(ml_data, normalize);

%% Add additional information for model training to the ml_data struct
ml_data = ml_model_parameters(ml_data, model_name);

% edit paramters for SVM
if strcmp(model_name, 'SVM')
% ml_data.svm.?=3;
end

%% fit model
Mdl=model_train(ml_data,model_name);
% todo rename to model_train
%% Predict gait condition classification on the test set
figure
ml_data.y_pred = model_predict(Mdl, model_name, ml_data.x_test);


[C,~] = confusionmat(ml_data.y_test, ml_data.y_pred);
[stats] = statsOfMeasure(C);  % replace by matlab version?

%plot fonfusion matrix with names
confusionchart(C,ml_data.Conditions);


if strfind(mode,'auto')
    disp(' ')
    disp('**********************************')
    disp('Finished running demo program in : ')
    toc
    disp('**********************************')
end