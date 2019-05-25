function bmech_reptrial(fld,chrp,method)

% BMECH_REPTRIAL(fld,chrp) finds a representative trial per subject/condition based
% closest in the root mean squared difference sense, to the mean trial data
%
% ARGUMENTS
%  fld    ...   folder to operate on
%  chrp   ...   channels to use for choosing rep trial. Default 'all'
%  method ...   method to use for reptrial. Default = 'RMSE'. If 'mean', 
%               data in the rep trial is the average data for all trials
%               of the given group
%
% NOTES FOR RMSE
% - Algorithm chooses trial with overall root mean squared error closest to the mean
% - If only 2 trials are present, the first trial in the list will be chosen
% - If only 1 trial is present, algorithm is not run and single trial is retained
% - An additional prefix 'mean_' and 'sd_' are added to existing events.
%   These branches are equivalent to taking the average of all the trials for
%   a given condition/subject. Other events in the event branch of the
%   reprial are 'representative events' that are unchanged and belong to
%   the representative trial


% Revision History
%
% Created by Philiippe C. Dixon March 2012
%
% Updated by Philiippe C. Dixon May 19th 2013
% - fixed small bug in stacking of values.
%
% Updated by Philiippe C. Dixon May 11th 2015
% - simplified/generalized function
% - added error checking for data with NaNs
%
% Updated by Philiippe C. Dixon June 2015
% - small bug fix
%
% Updated by Philiippe C. Dixon Feb 2015
% - Reptrial can analyse n x 3 channels. These channels are temporarily exploded
%   into n x 1 for analysis
%
% Updated by Philiippe C. Dixon May 2015
% - mean and sd of events are appended to event branc of representative
%   trial
%
% Updated by Philippe C. Dixon Jan 2017
% - Improved user output messages
% - checks for case where there are no trials for a given condition
%
% Updated by Philippe C. Dixon May 2019
% - reptrial can be used to extact an average trial




% Set defaults
%
s = filesep;    % determine slash direction based on computer type
recycle('on')    % move deleted files to recycling bin

if nargin==0
    fld = uigetfolder;
    chrp = 'all';
    method = 'mean';
end

if nargin==1
    chrp = 'all';
    method = 'RMSE';
end

if nargin==2
    method = 'RMSE';
end

cd(fld)


% Find all subfolders and extract terminal folders only
%
sub = subdir(fld);
tsubs = makecolumn(cell(size(sub)));
slash_num = zeros(length(sub),1);

for i = 1:length(sub)
    subsub = subdir(sub{i});
    
    if isempty(subsub)
        tsubs{i} = sub{i};
    end
    
    slash_num(i) = length(strfind(sub{i},s));
end

tsubs(cellfun(@isempty,tsubs)) = [];   % That's some hot programming


% Find reptrial in each terminal folder
%
tstk = ones(length(tsubs),1);
for i = 1:length(tsubs)
    fl = engine('fld',tsubs{i},'extension','zoo');
    
    if length(fl)>1
        batchdisp(tsubs{i},['building rep trial from ',num2str(length(fl)),' trials '])
        r = zload(fl{1});
        gdata = struct;
        
        if ismember('all',chrp)
            chrp = setdiff(fieldnames(r),'zoosystem');
        end
        
        for j = 1:length(fl)
            gdata.(['data',num2str(j)]) = zload(fl{j});
        end
        
        [data,file_indx] = reptrial(gdata,chrp, method);
        
        if strcmp(method, 'mean')
            fl_rep = strrep(fl{1}, '.zoo', '_mean.zoo');
        else
            fl_rep = fl{file_indx};
        end
        zsave(fl_rep, data);

    % delete old files
    delfile(fl)

        
    elseif length(fl)==1
        batchdisp(tsubs{i},'only 1 trial, keeping single trial ')
    else
        batchdisp(tsubs{i},'no trials found ')
    end
    
    tstk(i) = length(fl);
end


% Create summary table
%
indx = length(strfind(sub{1},s));

disp(' ')
disp('Reptrial summary table')
disp(' ')
disp('CONDITION/# OF TRIALS')

for i = 1:length(tsubs)
    tsub = tsubs{i};
    slash_indx = strfind(tsub,s);
    tsub = tsub(slash_indx(indx):end);
    disp([tsub,' ',num2str(tstk(i))])
end



%====EMBEDDED FUNCTION==========================


function [data,file_indx] = reptrial(gdata,ch, method)

nlength = 100;
trials = fieldnames(gdata);
bstk = zeros(length(trials),length(ch));

% check for and (temporarily) explode any n x 3 channels
%
och = ch; % copy of original channels

for i = 1:length(ch)
    
    [~,ccols] = size(gdata.(trials{1}).(ch{i}).line);
    
    if ccols ==3
        disp(['ch ',ch{i}, ' is n x 3, exploding...'])
        
        for j = 1:length(trials)
            gdata.(trials{j}) = explode_data(gdata.(trials{j}),ch{i});
        end
        
        ch{i+1} = [ch{i},'_x'];
        ch{i+2} = [ch{i},'_y'];
        ch{i+3} = [ch{i},'_z'];
        ch{i} = '';
    end
end

ch(cellfun(@isempty,ch)) = [];

if method == 'mean'
    
    for i = 1:length(ch)
        
        valstk = zeros(length(trials),nlength+1);        
        for j = 1:length(trials)
            valstk(j,:) = normalize_line(gdata.(trials{j}).(ch{i}).line,nlength)';
        end
        
        gdata.data1.(ch{i}).line = mean(valstk,1);               % mean value for a given sub/con/channel
        
    end
    
    data = gdata.data1;
    file_indx = 'mean';
    
elseif method == 'RMSE'
    
    for i = 1:length(ch)
        
        valstk = zeros(length(trials),nlength+1);
        rstk = zeros(length(trials),1);
        
        for j = 1:length(trials)
            valstk(j,:) = normalize_line(gdata.(trials{j}).(ch{i}).line,nlength)';
        end
        
        meanval = mean(valstk,1);               % mean value for a given sub/con/channel
        
        if ~isempty(find(isnan(meanval), 1))
            error(['data contains NaNs in channel ',ch{i}])
        end
        
        for j = 1:length(trials)
            rstk(j) = rmse(meanval,valstk(j,:));
        end
        
        bstk(:,i) = rstk;
        
    end
    
    % average rms value based on all channels
    %
    RMSvals = mean(bstk,2);
    
    % pick overall mean smallest rms value as rep trial--
    %
    [~,file_indx] = min(RMSvals);
    
    
    % find average events
    %
    ach = setdiff(fieldnames(gdata.(trials{j})),'zoosystem');
    
    for i = 1:length(ach)
        evts = fieldnames(gdata.data1.(ach{i}).event);
        
        for j = 1:length(evts)
            evtstk = zeros(length(trials),3);
            for k = 1:length(trials)
                
                if ~isfield(gdata.(trials{k}).(ach{i}).event,evts{j})
                    evtstk(k,:) = [NaN NaN NaN];
                else
                    evtstk(k,:) = gdata.(trials{k}).(ach{i}).event.(evts{j});
                end
            end
            
            mean_evt = nanmean(evtstk);
            sd_evt = nanstd(evtstk);
            
            gdata.(trials{file_indx}).(ach{i}).event.(['mean_',evts{j}]) = mean_evt;
            gdata.(trials{file_indx}).(ach{i}).event.(['sd_',evts{j}]) = sd_evt;
        end
        
    end
    
    % write back rep trial to data
    %
    data =  gdata.(trials{file_indx}); % rep trial becomes good trial
    
end

% check if channels were exploded
%
for i = 1:length(och)
    if ismember([och{i},'_x'],ch)   % then was exploded
        data = removechannel_data(data,{[och{i},'_x'],[och{i},'_y'],[och{i},'_z']});
    end
end

% add # of trial for rep trial info to zoosystem
%
data.zoosystem.CompInfo.Reptrials.Trials = length(trials);
data.zoosystem.CompInfo.Reptrials.Method = method;

