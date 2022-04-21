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
% NOTES:
%   Conditions (y): Straight, Turn
%   Predictors (x): Hip, knee, ankle joint angles for right and left side
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
mode = 'auto';                                                             % entire code

if strfind(mode,'auto')                                                    %#ok<*STRIFCND>
    tic
    rfld = fullfile(fileparts(which('samplestudy_process')),'Data');
    fld = fullfile(rfld,'zoo files (auto process)');

    if ~exist(fld, 'dir')
        disp('running samplestudy_process to obtain processed data...')
        samplestudy_process
    end

else
    fld = uigetfolder;
end


%% Data conversion
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


%% stacking ch
if contains(model_name,'FF')
    x=table2array(table_data(:,1:length(table_data.Properties.VariableNames)-2));
    x=stackch(x);
    y= table_data.Conditions;
    subject=table_data.Subject;
    VariableName=table_data.Properties.VariableNames(1:end-2);
    %% Sequence ch
elseif contains(model_name,'LSTM')
    x=table2array(table_data(:,1:length(table_data.Properties.VariableNames)-2));
    x=sequencech(x);
    y= table_data.Conditions;
    subject=table_data.Subject;
    VariableName=table_data.Properties.VariableNames(1:end-2);
elseif contains(model_name,'BiLS')
    x=table2array(table_data(:,1:length(table_data.Properties.VariableNames)-2));
    x=sequencech(x);
    y= table_data.Conditions;
    subject=table_data.Subject;
    VariableName=table_data.Properties.VariableNames(1:end-2);
elseif contains(model_name,'CNN')
    x=table2array(table_data(:,1:length(table_data.Properties.VariableNames)-2));
    x=sequencech(x);
    y= table_data.Conditions;
    subject=table_data.Subject;
    VariableName=table_data.Properties.VariableNames(1:end-2);
else
    %% Feature extraction
    % - extracts basic statistical features from table_data
    table_event=feature_extraction(table_data,ch);
    x=table2array(table_event(:,1:length(table_event.Properties.VariableNames)-2));
    y= table_event.Conditions;
    subject=table_event.Subject;
    VariableName=table_event.Properties.VariableNames(1:end-2);
end

%% train_test_split
subject_wise=1;
split=0.30;
Normalize='None';
seed=0;
ml_data=train_test_split(x,y,VariableName,subject,subject_wise,split,Normalize,seed);
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