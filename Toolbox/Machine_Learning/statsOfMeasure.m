function [stats] = statsOfMeasure(confusion)
%Copyright (c) 2021, Eugenio Bertolini
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% 
% * Neither the name of  nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% The input 'confusion' is the the output of the Matlab function
% 'confusionmat'

% confusion: 3x3 confusion matrix
tp = [];
fp = [];
fn = [];
tn = [];
len = size(confusion, 1);
for k = 1:len
    % True positives           % | x o o |
    tp_value = confusion(k,k); % | o o o |
    tp = [tp, tp_value];       % | o o o |
    
    % False positives                          % | o x x |
    fp_value = sum(confusion(k,:)) - tp_value; % | o o o |
    fp = [fp, fp_value];                       % | o o o |
    
    % False negatives                          % | o o o |
    fn_value = sum(confusion(:,k)) - tp_value; % | x o o |
    fn = [fn, fn_value];                       % | x o o |
    
    % True negatives (all the rest)                                    % | o o o |
    tn_value = sum(sum(confusion)) - (tp_value + fp_value + fn_value); % | o x x |
    tn = [tn, tn_value];                                               % | o x x |
end

% Statistics of interest for confusion matrix
prec = tp ./ (tp + fp); % precision
sens = tp ./ (tp + fn); % sensitivity, recall
spec = tn ./ (tn + fp); % specificity
acc = sum(tp) ./ sum(sum(confusion));
f1 = (2 .* prec .* sens) ./ (prec + sens);

% For micro-average
microprec = sum(tp) ./ (sum(tp) + sum(fp)); % precision
microsens = sum(tp) ./ (sum(tp) + sum(fn)); % sensitivity, recall
microspec = sum(tn) ./ (sum(tn) + sum(fp)); % specificity
microacc = acc;
microf1 = (2 .* microprec .* microsens) ./ (microprec + microsens);

% Names of the rows
name = ["true_positive"; "false_positive"; "false_negative"; "true_negative"; ...
    "precision"; "sensitivity"; "specificity"; "accuracy"; "F-measure"];

% Names of the columns
varNames = ["name"; "classes"; "macroAVG"; "microAVG"];

% Values of the columns for each class
values = [tp; fp; fn; tn; prec; sens; spec; repmat(acc, 1, len); f1];

% Macro-average
macroAVG = mean(values, 2);

% Micro-average
microAVG = [macroAVG(1:4); microprec; microsens; microspec; microacc; microf1];

% OUTPUT: final table
stats = table(name, values, macroAVG, microAVG, ...
    'VariableNames',varNames)
end