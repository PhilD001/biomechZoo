function bmech_reptrial(fld,chrp)

% BMECH_REPTRIAL finds a representative trial per subject/condition based
% closest in the root mean squared difference sense, to the mean trial data 
%
% ARGUMENTS
%  fld   ...   folder to operate on
%  chrp  ...   channels to use for choosing rep trial. Default 'all'
%
% NOTES
% - Algorithm chooses trial with overall root mean squared error closest to the mean


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


% Part of the Zoosystem Biomechanics Toolbox v1.2
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
% Aduts and Children. Rome, Italy.Sept 29-Oct 4th 2014.



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

for i = 1:length(sub)
    subsub = subdir(sub{i});
    
    if isempty(subsub)
        tsubs{i} = sub{i};
    end
end

tsubs(cellfun(@isempty,tsubs)) = [];   % That's some hot programming


% Find reptrial in each terminal folder
%
for i = 1:length(tsubs)
    
    
    fl = engine('fld',tsubs{i},'extension','zoo');
    
    if length(fl)>1
        
        disp(['finding representative trial for ',tsubs{i}])
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
    end
    
end




%====EMBEDDED FUNCTION==========================


function [data,file_indx] = reptrial(gdata,ch)

nlength = 100;

trials = fieldnames(gdata);
bstk = zeros(length(trials),length(ch));

for i = 1:length(ch)
    
    valstk = zeros(length(ch),nlength+1);
    rstk = zeros(length(ch),1);
    
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

% pick overal mean smallest rms value as rep trial--
%
[~,file_indx] = min(RMSvals);
data =  gdata.(trials{file_indx}); % rep trial becomes good trial



