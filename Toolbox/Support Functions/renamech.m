function data = renamech(data,och,nch)

% data = RENAMECH(data,och,nch) renames zoo channels (standalone function for bmech_renamechannel)
%
% ARGUMENTS
%  data  ...  zoo file
%  och   ...  list of old channel names (cell array of strings)
%  nch   ...  list of new channel names (cell array of strings)
%
% RETURNS
%  data  ...  updated zoo file


% Revision History
%
% Created by Philippe C. Dixon  
% - extracted from old functions
%
% Updated by Philippe C. Dixon May 2015
% - code implements 'addchannel.m' and 'removechannel.m'


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
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 



% Get Video/Analog channel list
%
vch = data.zoosystem.Video.Channels;
ach = data.zoosystem.Analog.Channels;


% check for single string instead of cell array of strings
%
if ~iscell(och)
    och = {och};
end

if ~iscell(nch)
    nch= {nch};
end


for i = 1:length(och)

    if isempty(findfield(data,och{i}))
        disp(['channel: ',och{i}, ' does not exist'])
    else
        
        if ismember(och{i},vch)
            section = 'Video';
        elseif ismember(och{i},ach)
            section = 'Analog';
        else
            error(['unknown section for ch: ',och{i}])
        end
                
        data = addchannel(data,nch{i},data.(och{i}).line,section);  
        data.(nch{i}).event = data.(och{i}).event;
        data = removechannel(data,och{i},section);
    end
end