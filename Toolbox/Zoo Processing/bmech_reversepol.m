function bmech_reversepol(ch,fld)

       
% reverses polarity of a given channel (s) i.e. changes the sign and
% related events
%
% ARGUMENTS
%   fld   ...  folder to operate on
%   ch    ...  name of channel to reverse polarity as a cell array of
%              strings ex {'fz1','fz2'}
%
% Updated Feb 2010
% - events are updated 
%  
% Updated April 2015
% - changed function arguments
% - improved event handing



if ~iscell(ch)  % fix errors such as ch = 'fz1' to ch = {'fz1'}
    ch = {ch};
end


if nargin ==1
   
    fld = uigetfolder('select zoo processed ');
end

cd(fld);
fl = engine('fld',fld,'extension','zoo');


for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'reversing polarity:');
    data = reversepol(data,ch);
    save(fl{i},'data');
end

function data = reversepol(data,ch)
        
        
for i = 1:length(ch)
    evts = fieldnames(data.(ch{i}).event);
    data.(ch{i}).line = -data.(ch{i}).line;
    
    for j = 1:length(evts)
        evt =  data.(ch{i}).event.(evts{j});
        data.(ch{i}).event.(evts{j}) = [   evt(1) -evt(2) evt(3)];    
    end
    
end
        




