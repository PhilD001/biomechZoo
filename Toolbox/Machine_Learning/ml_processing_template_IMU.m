% biomechZoo machine learning processing template for IMU data
%
% This sample script shows how to run a toy binary multiclass support vector 
% machines classification model which aims to predict surface type (flat, slope up, 
% slope down) based on events (features) extracted from a public gait database
% (see Luo, Coppola, Dixon, et al. A database of human gait performance on irregular
% and uneven surfaces collected by wearable sensors. Sci Data 7, 219 (2020). 
% https://doi.org/10.1038/s41597-020-0563-y
%
% Processed data with features are stored in:
% biomechZoo-help/examples/example data/IMU_4_cycle
%
% REQUIREMENTS
% - biomechZoo and biomechZoo-help installed
%
% NOTES:

%   - Conditions (y): flat, slope up, slope down
%   - Predictors (x): many, see Dixon, Schütte, Vanwanseele, et al. 
%                   'Gait adaptations of older adults on an uneven brick surface 
%                    can be predicted by age-related physiological changes in 
%                    strength, Gait & Posture, Volume 61,2018, Pages 257-262,
%                    https://doi.org/10.1016/j.gaitpost.2018.01.027.
%   -Features here were hand-crafted (feature engineering) to optimize surface 
%   identification. See ml_processing_template_IMU_simple for a (poor)
%   classification with generic features


%% Data extraction
% - select 'IMU_4_cycle' from biomechZoo-help/examples/example data

mode = 'auto';                                                             % entire code

if strfind(mode,'auto')                                                    %#ok<*STRIFCND>
    tic
    rfld = fullfile(fileparts(which('all_examples_test')),'example data IMU');
    fld = fullfile(rfld,'IMU_4_cycle');
else
    fld=uigetfolder;
end

%% data conversion
[subjects, Conditions] = extract_filestruct(fld);
Conditions=unique(Conditions);
ch = {'shankR_Acc_X','thighR_Acc_X','trunk_Acc_X'};
event.shankR_Acc_X = {'SRegML','SRegAP','StrRegML','StrRegAP',...
    'SymML','SymAP','corrSAG','corrFRO','corrHOR',...
    'rmsSAG','rmsFRO','rmsHOR','SPARCML','SPARCAP',};
event.thighR_Acc_X = {'SRegML','SRegAP','StrRegML','StrRegAP',...
    'SymML','SymAP','corrSAG','corrFRO','corrHOR',...
    'rmsSAG','rmsFRO','rmsHOR','SPARCML','SPARCAP',};
event.trunk_Acc_X = {'StrRegML','StrRegAP',...
    'corrSAG','corrFRO','corrHOR','rmsSAG','rmsFRO','rmsHOR',...
    'SPARCML','SPARCAP',};
table_event = bmech_events2table(fld,ch,event,subjects, Conditions);
x=table2array(table_event(:,1:length(table_event.Properties.VariableNames)-2));
y= table_event.Conditions;
subject=table_event.Subject;
VariableName=table_event.Properties.VariableNames(1:end-2);
%% train_test_split
subject_wise=1;
split=0.25;
Normalize='MinMaxScaler';
seed=0;
ml_data=train_test_split(x,y,VariableName,subject,subject_wise,split,Normalize,seed);
%% fit model
% Model_name  ...   string,'NBayes'  --> Naive bayes
%                          'knn'     --> k-Nearest Neighbor Classifier
%                          'Msvm'    --> Multiclass support vector machines
ml_data.knn.NumNeighbors=5;
Model_name='Msvm';% BDT % NBayes %knn %Bsvm
Mdl=bmech_ml_classification(ml_data,Model_name);
%% predict gait condition classification on the test set
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