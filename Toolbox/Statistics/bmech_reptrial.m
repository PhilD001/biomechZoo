function bmech_reptrial(fld,chrp)

% BMECH_REPTRIAL(fld,chrp) finds a representative trial per subject/condition based
% closest in the root mean squared difference sense, to the mean trial data
%
% ARGUMENTS
%  fld   ...   folder to operate on
%  chrp  ...   channels to use for choosing rep trial. Default 'all'
%
% NOTES
% - Algorithm chooses trial with overall root mean squared error closest to the mean
% - If only 2 trials are present, the first trial in the list will be chosen
% - If only 1 trial is present, algorithm is not run and single trial is retained

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


% Part of the Zoosystem Biomechanics Toolbox
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.



% Set defaults
%
recycle('on')    % move deleted files to recycling bin

if nargin==0
    fld = uigetfolder;
    chrp = 'all';
end

if nargin==1
    chrp = 'all';
end

cd(fld)


% Find all subfolders and extract terminal folders only
%
sub = subdir(fld);
tsubs = makecolumn(cell(size(sub)));
rsubs = makecolumn(cell(size(sub)));

slash_num = zeros(length(sub),1);

for i = 1:length(sub)
    subsub = subdir(sub{i});
    
    if isempty(subsub)
        tsubs{i} = sub{i};
    end
    
    slash_num(i) = length(strfind(sub{i},slash));
    
end

tsubs(cellfun(@isempty,tsubs)) = [];   % That's some hot programming


% Find reptrial in each terminal folder
%
tstk = ones(length(tsubs),1);

for i = 1:length(tsubs)
    
    fl = engine('fld',tsubs{i},'extension','zoo');
    
    if length(fl)>1
        
        disp(['building representative trial from ',num2str(length(fl))',' trials for ',tsubs{i}])
        r = zload(fl{1});
        gdata = struct;
        
        if ismember('all',chrp)
           chrp = setdiff(fieldnames(r),'zoosystem');
        end
        
        for j = 1:length(fl)
            gdata.(['data',num2str(j)]) = zload(fl{j});
            delete(fl{j})
        end
        
        [data,file_indx] = reptrial(gdata,chrp);
        save(fl{file_indx},'data');
        
        
    else
        disp(['only 1 trial, keeping single trial for ',tsubs{i}])
    end
    
    tstk(i) = length(fl);
    
    
end


% Create summary table
%
indx = length(strfind(sub{1},slash));

disp(' ')
disp('Reptrial summary table')
disp(' ')
disp('CONDITION/# OF TRIALS')
for i = 1:length(tsubs)
    tsub = tsubs{i};
    slash_indx = strfind(tsub,slash);
    tsub = tsub(slash_indx(indx):end);
    disp([tsub,' ',num2str(tstk(i))])
end



%====EMBEDDED FUNCTION==========================


function [data,file_indx] = reptrial(gdata,ch)

nlength = 100;

trials = fieldnames(gdata);
bstk = zeros(length(trials),length(ch));

for i = 1:length(ch)
    
    valstk = zeros(length(trials),nlength+1);
    rstk = zeros(length(trials),1);
    
    for j = 1:length(trials)
        valstk(j,:) = normalizeline(gdata.(trials{j}).(ch{i}).line,nlength)';
    end
    
    meanval = mean(valstk,1);               % mean value for a given sub/con/channel
    
    if ~isempty(find(isnan(meanval), 1))
        error('data contains NaNs')
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
data =  gdata.(trials{file_indx}); % rep trial becomes good trial

% add # of trial for rep trial info to zoosystem
%
data.zoosystem.CompInfo.Reptrials = length(trials);


