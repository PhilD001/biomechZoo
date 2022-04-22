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


%% Data extraction from zoo files to tabular form
% - extracts events from zoo files to tabular form
[subjects, Conditions] = extract_filestruct(fld);
Conditions=unique(Conditions);
ch = {'RightHipAngle_x','RightHipAngle_y','RightHipAngle_z',...
    'RightKneeAngle_x','RightKneeAngle_y','RightKneeAngle_z'...
    'RightAnkleAngle_x','RightAnkleAngle_y','RightAnkleAngle_z',...
    'LeftHipAngle_x','LeftHipAngle_y','LeftHipAngle_z',...
    'LeftKneeAngle_x','LeftKneeAngle_y','LeftKneeAngle_z'...
    'LeftAnkleAngle_x','LeftAnkleAngle_y','LeftAnkleAngle_z'};
table_data = bmech_zoo2table(fld,ch,subjects,Conditions);


%% Reformat data structure depending on model type (signal or feature-based)
% - Deep learning models train can train directly on the kinematic data
% - "Traditional" machine learning models use feature input and thus require a 
%   feature engineering step
[x, y, VariableName, subject] = table2ml_structure(table_data, model_name);

%% Split data into training and test set
% - ml_data is struct containing train and test fields
subject_wise=true;
split=0.30;
seed=0;
ml_data=train_test_split(x, y, subject,subject_wise,split,seed);


%% scale data
% - scaling is conducted on train set and applied to test set to avoid
% 'information leakage'

%%% TODO: I don't think the format works for the scalers
normalize='None';
%ml_data = train_test_scale(ml_data, normalize);

%% Add additional information for model training to the ml_data struct
ml_data.VariableName = VariableName;
ml_data = ml_model_parameters(ml_data);
ml_data.Conditions = char2num(y);


%% CNN1D data prepration
if contains(model_name,'CNN')
    ml_data=CNN1D_data_prepration(ml_data);
end
%% fit model
% Model_name  ...   string,'NBayes'  --> Naive bayes
%                          'knn'     --> k-Nearest Neighbor Classifier
%                          'Msvm'    --> Multiclass support vector machines
ml_data.knn.NumNeighbors=3;
Model_name=model_name;% BDT % NBayes %knn %Bsvm
Mdl=bmech_ml_classification(ml_data,Model_name);
%% Predict gait condition classification on the test set
figure
if contains(model_name,{'FF','LSTM','BILS','CNN'})
    label = classify(Mdl,ml_data.x_test);
    [C,~] = confusionmat(ml_data.y_test,label);
else
    label= predict(Mdl,ml_data.x_test);
    [C,~] = confusionmat(ml_data.y_test,categorical(label));
end

[stats] = statsOfMeasure(C);
ConfusionTrain = confusionchart(C,ml_data.Conditions);%,...
% 'ColumnSummary','column-normalized', ...
%'RowSummary','row-normalized');


if strfind(mode,'auto')
    disp(' ')
    disp('**********************************')
    disp('Finished running demo program in : ')
    toc
    disp('**********************************')
end