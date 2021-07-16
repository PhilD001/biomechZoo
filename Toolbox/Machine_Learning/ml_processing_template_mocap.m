% biomechZoo machine learning processing template for mocap data
%
% This sample script shows how to run a toy binary KNN classification model which 
% aims to predict gait condition (straight vs turning) based on events 
% (features) extracted from the biomechzoo sample data, available at 
% https://github.com/PhilD001/biomechzoo-help/sample study/Data/zoo files (auto process)*
%
% * the terminal folder 'zoo files (auto process)' is only available after
% having run the samplestudy_process.m script
%
% REQUIREMENTS
% - biomechZoo and biomechZoo-help installed
%
% NOTES:
%   Conditions (y): Straight, Turn
%   Predictors (x): RightGroundReactionForce_x max','RightHipAngle_y max',
%                   'RightAnklePower'max

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


%% Data extraction
% - extracts events from zoo files to tabular form
[subjects, Conditions] = extract_filestruct(fld);
Conditions=setdiff(unique(Conditions), 'Static');
ch={'RightGroundReactionForce_x','RightHipAngle_y','RightAnklePower'};
event.RightGroundReactionForce_x={'max'};
event.RightHipAngle_y={'max'};
event.RightAnklePower={'max'};
table_event = bmech_events2table(fld,ch,event,subjects, Conditions);
x=table2array(table_event(:,1:length(table_event.Properties.VariableNames)-2));
y= table_event.Conditions;
subject=table_event.Subject;
VariableName=table_event.Properties.VariableNames(1:end-2);
%% train_test_split
% - creates a data structure containing all parameters for machine learning
subject_wise=0;                 % if 1, split with no subject overlap btw train/test sets
split=0.30;                     % test set size
Normalize='StandardScaler';     % feature normalization, see train_test_spit for options
ml_data=train_test_split(x,y,VariableName,subject,subject_wise,split,Normalize);
%% Fit model 
% - Here we use a knn classifier
% - other options:
% Model_name  ...   string,'BDT'     --> Binary Classification Tree 
%                          'NBayes'  --> Naive bayes
%                          'knn'     --> k-Nearest Neighbor Classifier
%                          'Bsvm'    --> Binary support vector machines
%                          'Blinear' --> Binary Linear Classification
%                          'Bkernel' --> Binary Kernel Classification
%                          'Msvm'    --> Multiclass support vector machines
ml_data.knn.NumNeighbors=4;  % set parameter for knn
Model_name='knn';
Mdl=bmech_ml_classification(ml_data,Model_name);
%% Predict gait condition classification on the test set
figure
label = predict(Mdl,ml_data.x_test);
[C,order] = confusionmat(ml_data.y_test,label);
[stats] = statsOfMeasure(C);
ConfusionTrain = confusionchart(C,ml_data.Conditions,...
    'ColumnSummary','column-normalized', ...
    'RowSummary','row-normalized');

if strfind(mode,'auto')
    disp(' ')
    disp('**********************************')
    disp('Finished running demo program in : ')
    toc
    disp('**********************************')
end
