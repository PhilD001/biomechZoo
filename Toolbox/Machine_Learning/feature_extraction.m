function table_event=feature_extraction(table_data,ch,method)
% FEATURE_EXTRACTION extracts statistical features from tabular data created by 
% bmech_zoo2table
%
% ARGUMENTS
%   table_data  ...   table, line data table extracted with bemch_line function
%   ch          ...   string, all channel name.
%   method      ...   features extraction method 'None' currently, future
%                     updates will have PCA, LDA, etc...
% RETURNS
%   table_event ...   table, Table of featuers with subjects second last row
%                     and conditions last row.
%
% See also bmech_zoo2table

if nargin == 2
    method='None';
end
event=struct;
features={'Min','Max','Sum','mean','std',...
    'median','lenght','meanLmax',...
    'sumLmax','lenghtLmax','meanLmin','sumLmin',...
    'lenghtLmin','RatioMaxMin','RatioMinMax'};

if contains(method,'None')
    for i=1:length(ch)
        names=cell(1, length(features));
        for k=1:length(features)
            names{k}= [ch{i},'_',features{k}];
        end
        F1 = zeros(1, length(features));
        F2 = zeros(1, length(features));
        F3 = zeros(1, length(features));
        F4 = zeros(1, length(features));
        F5 = zeros(1, length(features));
        F6 = zeros(1, length(features));
        F7 = zeros(1, length(features));
        F8 = zeros(1, length(features));
        F9 = zeros(1, length(features));
        F10 = zeros(1, length(features));
        F11 = zeros(1, length(features));
        F12 = zeros(1, length(features));
        F13 = zeros(1, length(features));
        F14 = zeros(1, length(features));
        F15 = zeros(1, length(features));        
        
        for j=1:length(table_data.(ch{i}))
            disp(['extracting features from ',ch{i},' data ', num2str(j)])
            F1(j)=min(table_data.(ch{i}){j});
            F2(j)=max(table_data.(ch{i}){j});
            F3(j)=sum(table_data.(ch{i}){j});
            F4(j)=mean(table_data.(ch{i}){j});
            F5(j)=std(table_data.(ch{i}){j});
            F6(j)=median(table_data.(ch{i}){j});
            F7(j)=length(table_data.(ch{i}){j});
            Lmax=table_data.(ch{i}){j}(local_max(table_data.(ch{i}){j}));
            F8(j)=mean(Lmax);
            F9(j)=sum(Lmax);
            F10(j)=length(Lmax);
            Lmin=table_data.(ch{i}){j}(islocalmin(table_data.(ch{i}){j}));
            if isempty(Lmin)
                Lmin=1;
            end
            F11(j)=mean(Lmin);
            F12(j)=sum(Lmin);
            F13(j)=length(Lmin);
            F14(j)=max(Lmax)/min(Lmin);
            F15(j)=min(Lmax)/max(Lmax);
        end
        event.(ch{i})=table(F1.',F2.',F3.',F4.',F5.',F6.',F7.',F8.',F9.',F10.',F11.',F12.',F13.',F14.',F15.','VariableNames',names);
    end
    for i=2:length(ch)
        if i==2
            table_event=[event.(ch{1}),event.(ch{2})];
        elseif i==1
            table_event=event.(ch{1});
        else
            table_event=[table_event,event.(ch{i})]; %#ok<AGROW>
        end
    end
    table_event=[table_event,table(table_data.Conditions,table_data.Subject,'VariableNames',{'Conditions','Subject'})];
else
    error('Feature extraction method not available')
end