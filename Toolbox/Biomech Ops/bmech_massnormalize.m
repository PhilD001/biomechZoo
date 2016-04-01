function bmech_massnormalize(fld,ch,type)


% BMECH_MASSNORMALIZE normalizes the amplitude of a given channel by mass
% 
% ARGUMENTS
%  fld         ...    folder to operate on
%  ch          ...    name of markers (as cell array of strings)
% type         ...    type of data channel ('forces','moments',or 'markers')


% Revision history: 
%
% Created by Philippe C. Dixon March 2016


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt





% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'normalizing amplitude by mass'); 
    data = massnormalize(data,ch,type);
    zsave(fl{i},data,['for ',strjoin(ch,' ')]);
end



function data = massnormalize(data,ch,type)

% error check
%
if ~isfield(data.zoosystem.Anthro,'Bodymass')
    error('no body mass stored in anthro branch of zoo file')
end


% Normalize quantities by mass
%
mass = data.zoosystem.Anthro.Bodymass;
for i = 1:length(ch)
    data.(ch{i}).line = data.(ch{i}).line/mass; 
end


% Update units fields
%
oUnit = data.zoosystem.Units.(type);
nUnit = [oUnit,'/kg'];
data.zoosystem.Units.(type) = nUnit;

