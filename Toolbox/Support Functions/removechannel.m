function data= removechannel(data,chrm,section)

% data= REMOVECHANNEL(data,chrm,section) removes channels from zoo files
%
% ARGUMENTS
%  data      ...   zoo file
%  chrm      ...   channels to remove as cell array of strings
%  section   ...   section (Video or Analog) where channel resides


% Revision History
%
% Created by Philippe C. Dixon  
% - extracted from old functions
%
% Updated by Philippe C. Dixon May 2015
% - updated help


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




% error checking
%
if ~iscell(chrm)
    chrm = {chrm};
end

% setting sections
%
if nargin==2
    
    section = [];
    v_list = cell(size(chrm));
    a_list = cell(size(chrm));
    
    for i = 1:length(chrm)
        
        if isin(data.zoosystem.Video.Channels,chrm{i})
            v_list{i}  = chrm{i};
            
        elseif isin(data.zoosystem.Analog.Channels,chrm{i})
            a_list{i}  = chrm{i};
            
        else
            error('missing appropriate section fieldname in zoosystem')
        end
        
    end
    
    v_list(cellfun(@isempty,v_list)) = [];
    a_list(cellfun(@isempty,a_list)) = [];
    
    
end





% process
%
for i = 1:length(chrm)
    
    if isfield(data,chrm{i})
        
        data = rmfield(data,chrm{i});
        
        if ~isempty(section)
            
        elseif isin(chrm{i},v_list)
            section = 'Video';
        elseif isin(chrm{i},a_list)
            section = 'Analog';
        end
        
        chlist = data.zoosystem.(section).Channels;
        nchlist = setdiff(chlist,chrm{i});
        data.zoosystem.(section).Channels = nchlist;
        
    end
    
end