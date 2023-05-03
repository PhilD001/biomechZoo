function y_pred = model_predict(mdl, model_name, x_test)
% model_evalute evaluates predicted data
%
% ARGUMENTS
%  mdl           ...   trained model.   
%  model_name    ...   string, model name
%  x_test        ...   double/cell/4D array, test data...
%
% RETURNS
%  y_pred        ...   double, predicted test lable.
Trails=max(size(x_test));
disp(['predicting conditions for n = ', num2str(Trails), ' trials...'])
if contains(model_name,{'FF','LSTM','BiLS','CNN'})
    y_pred = classify(mdl, x_test);
else
    y_pred= predict(mdl,x_test);
end
