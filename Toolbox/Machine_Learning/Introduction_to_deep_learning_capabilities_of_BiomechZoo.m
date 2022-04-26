% Introduction_to_deep_learning_capabilities_of_BiomechZoo
%
% biomechZoo machine learning processing template for mocap data
%
% This sample script shows how to run a toy binary classification model which
% aims to predict gait condition (straight vs turning) based on events
% (features) extracted from the biomechzoo sample data kinematic channels, available at
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
% - Binary SVM (Bsvm) and Long-Short Term Memory (LSTM) models provided as
%   examples, see ml_model_parameters for other model types available


%% MODEL EXAMPLES-------------------------------------------------------------------------
%model_name = 'LSTM';
model_name = 'Bsvm';


%% Step 0: Data pre-processing -----------------------------------------------------------
% - This step runs the biomechZoo sample study processing if data are not already 
% available, see samplestudy_process for more information

% - select 'zoo files (auto process)' from biomechZoo sample study

mode = 'auto';                                                         % entire code
if strfind(mode,'auto')                                              %#ok<*STRIFCND>
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

%% Step 1: Select channels and extract information from data set -------------------------
% - channels: all lower-limb channels are selected for analysis
% - conditions: condition names (straight, turn) are extracted from file structure
% - subjects: subject names  are extracted from file structure

ch = {'RightHipAngle_x','RightHipAngle_y','RightHipAngle_z',...
    'RightKneeAngle_x','RightKneeAngle_y','RightKneeAngle_z'...
    'RightAnkleAngle_x','RightAnkleAngle_y','RightAnkleAngle_z',...
    'LeftHipAngle_x','LeftHipAngle_y','LeftHipAngle_z',...
    'LeftKneeAngle_x','LeftKneeAngle_y','LeftKneeAngle_z'...
    'LeftAnkleAngle_x','LeftAnkleAngle_y','LeftAnkleAngle_z'};

[subjects, Conditions] = extract_filestruct(fld);
Conditions=unique(Conditions);

%% Step 2: Extract data for machine learning to table format -----------------------------
% - If feature engineering is required it is performed in this step via
%   bmech_feature_extraction
%
if ~ismember(model_name,{'LSTM','BiLS','CNN', 'sequence', 'FF' 'stack'})
    events = bmech_feature_extraction(fld, ch);
    table_data = bmech_events2table(fld,ch,events,subjects,Conditions);
else
    table_data = bmech_line2table(fld,ch,subjects,Conditions);
end


%% Step 3: Reformat table data for machine learning --------------------------------------
% x: n trial cell array with each cell n channels x frames OR n_features 
% y: condition name associated with each trial
% VariableName: names associated with each x
% subject: subject name associated with each x
[x, y, VariableName, subject] = table2ml_structure(table_data, model_name);


%% Step 4: Split data into training and test set -----------------------------------------
% - split data into train and test sets based on split percentage
% - option for inter-(subject_wise=True) or intra- (subject_wise = False) subject split
% - all information exported to ml_data struct for further ml processing 
subject_wise=true;
split=0.30;
ml_data=train_test_split(x,y,VariableName,subject,subject_wise,split);

%% Step 5: scale data --------------------------------------------------------------------
% - scaling is conducted on train set and applied to test to avoid 'information leakage'
normalize='MinMaxScaler';
ml_data = train_test_scale(ml_data, normalize);

%% Step 6: Add additional information for model training to the ml_data struct -----------
% - Default parameters are returned via ml_model_parameters
% - Parameters can be edited afterwards (an example is provided in this cell)

ml_data = ml_model_parameters(ml_data, model_name);

% edit paramters for SVM
if strcmp(model_name, 'Bsvm')
    ml_data.Bsvm.KernelFunction='rbf';
end

%% Step 7: Train (fit) model -------------------------------------------------------------
Mdl=model_train(ml_data,model_name);

%% Step 8: Predict gait condition classification on the test set -------------------------
% - model_predict is a wrapper function permitting easier access to
%   existing matlab routines
% - statsOfMeasure summarizes model performance and was downloaded from file exchange
% - confusionmat is an existing matlab file to extraction confusion matrix
%   https://www.mathworks.com/matlabcentral/fileexchange/86158-precision-specificity-sensitivity-accuracy-f1-score
% - confusionchart plots confusion matrix 

ml_data.y_pred = model_predict(Mdl, model_name, ml_data.x_test);

[C,~] = confusionmat(ml_data.y_test, ml_data.y_pred);
confusionchart(C,ml_data.Conditions);

[stats] = statsOfMeasure(C);  % replace by matlab version?

if strfind(mode,'auto')
    disp(' ')
    disp('**************************************************')
    disp('Finished running machine learning model demo in : ')
    toc
    disp('*************************************************')
end