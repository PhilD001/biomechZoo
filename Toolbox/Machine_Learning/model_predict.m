function y_pred = model_predict(mdl, model_name, x_test)

if contains(model_name,{'FF','LSTM','BILS','CNN'})
    y_pred = classify(mdl, x_test);
else
    y_pred= predict(mdl,x_test);
end
