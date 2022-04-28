function ml_data = train_test_scale(ml_data, Normalize)

% ml_data = train_test_scale(ml_data, Normalize) scales ml_data using normalization schemes
%
% ARGUMENTS
%   ml_data        ...  Struct containing train, test, Conditions, Classification parameters and etc...
%   Normalize      ...   'StandardScaler' or 'MinMaxScaler' or 'None' for selecting scaler to use
%
% RETURN
%   ml_data        ...  Struct with scaling implemented 

disp(['Scaling data using method ', Normalize])

if contains(Normalize,'StandardScaler')
    error('Not implemented')
    %     [x_train,m,s]=StandardScaler(x_train);
    %     ml_data.x_train=x_train;
    %     ml_data.mean=m;
    %     ml_data.std=s;
elseif contains(Normalize,'MinMaxScaler')
    disp('MinMax scaling')
    if isa(ml_data.x_train,'double')
        ml_data.x_train= MinMax(ml_data.x_train);
        ml_data.x_test= MinMax(ml_data.x_test);
    elseif isa(ml_data.x_train,'cell')
        for j=1:length(ml_data.x_train)
            ml_data.x_train{j}=MinMax(ml_data.x_train{j});
        end
        for j=1:length(ml_data.x_test)
            ml_data.x_test{j}=MinMax(ml_data.x_test{j});
        end
    end
elseif contains(Normalize,'None')
    disp('no scaling')
else
    disp(['unknown scale ', Normalize, ' Check Normalizating setting'])
end

function rescalex=MinMax(x)
rowmin = min(x,[],2);
rowmax = max(x,[],2);
rescalex= rescale(x,'InputMin',rowmin,'InputMax',rowmax);

