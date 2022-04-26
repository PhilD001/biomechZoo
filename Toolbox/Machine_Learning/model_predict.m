function y_pred = model_predict(mdl, model_name, x_test)

disp(['predicting conditions for n = ', num2str(length(x_test)), ' trials...'])
if contains(model_name,{'FF','LSTM','BiLS','CNN'})
    y_pred = classify(mdl, x_test);
else
    y_pred= predict(mdl,x_test);
end
