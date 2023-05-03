function stats=model_evalute(y_true,y_pred,Conditions)

% stats=model_evalute(y_true,y_pred,Conditions) evaluates predicted data
%
% ARGUMENTS
%   y_true           ...   double, ture test lable.   
%   y_pred           ...   double, predicted test lable.
%   Conditions       ...   cell, cell array of prediction class...
%
% RETURNS
%   stats            ...   table, performace parameter of model and confusion matrix 

[C,~] = confusionmat(y_true, y_pred);
confusionchart(C,Conditions);
tp=diag(C).';
nondiagonal=triu(C,1)+tril(C,-1);
fp=sum(nondiagonal,2).';
fn=sum(nondiagonal,1);
tn=sum(sum(C)) - (tp + fp + fn);

prec = tp ./ (tp + fp); % precision
sens = tp ./ (tp + fn); % sensitivity, recall
spec = tn ./ (tn + fp); % specificity
acc = sum(tp) ./ sum(sum(C));
f1 = (2 .* prec .* sens) ./ (prec + sens);
len = size(C, 1);
weights=len*(sum(C,2)./sum(sum(C))).';

Weighted_Average=[mean(prec.*weights);mean(sens.*weights);mean(spec.*weights);acc;mean(f1.*weights)];
Average=[mean(prec);mean(sens);mean(spec);acc;mean(f1)];
name = ["precision"; "sensitivity"; "specificity"; "accuracy"; "F-measure"];
varNames = ["name"; "classes"; "Average"; "Weighted_Average"];

values = [prec; sens; spec; repmat(acc, 1, len); f1];
stats=table(name, values, Average, Weighted_Average, ...
    'VariableNames',varNames);