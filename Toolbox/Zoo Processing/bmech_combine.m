function bmech_combine(fld1,fld2,method,fl1exclude,fl2exclude)

% BMECH_COMBINE(fld1,fld2,method,fl1exclude,fl2exclude) will combine data from 2 separate zoo files.
%
% ARGUMENTS
%  fld1      ...  folder for first data set. Files saved to fld1
%  fld2      ...  folder for second data set
%  method   ...   determines if you want to upsample the signal with the lower frequency ('up'),
%                 if you want to downsample the signal with the  highest frequency ('down'), or
%                 leave them the same 'none'. Default is down if frequencies are different.
%  fl1exclude ... Files names to ignore from fld1. Default none, {}
%  fl2exclude ... File names to ignore from fld2. Default none, {}
%
% Example
%  You may have collected data using 2 separate systems. As each signal was colected by a different system,
%  you have 2 sets of zoo data per trial. This file will create a sigle zoo file containing
%  all the channels in the first folder fld1
%
% NOTES
%  - make a copy of "folder 1" this is where all your data will be combined
%  - please make sure correct trials are combined. Files in each folder
%    should follow the same number sequence.
%  - You can check the zoosystem SourceFile to make sure process was completed correctly


% Revision History
%
% Created by Philippe C. Dixon and TJ Stidwill August 2008
%
% Updated by Philippe C. Dixon August 2010
% - function checks that after processing your channels are of the same
%   length. If they are different by more than 4, a warning is displayed
%
% Updated by Philippe C. Dixon March 2011
% - folder 2 is deleted automatically
%
% Updated by Philippe C. Dixon May 2015
% - improved combining of zoosystem folder metadata
% - no resampling when sampling rates are the same


s = filesep;

if nargin==0
    fld1 = uigetfolder('Select Folder 1');
    fld2 = uigetfolder('Select Folder 2');
    method = 'down';
    fl1exclude = {};
    fl2exclude = {};
end

if nargin==2
    method = 'down';
    fl1exclude = {};
    fl2exclude = {};
end

if nargin==3
    fl1exclude = {};
    fl2exclude = {};
end

if nargin==4
    fl2exclude = {};
end

cd(fld1)

fl1 = engine('path',fld1,'extension','zoo');
fl2 = engine('path',fld2,'extension','zoo');


if ~isempty(fl1exclude)
    for i = 1:length(fl1exclude)
        temp = engine('path',fld1,'extension','zoo','search file',fl1exclude{i});
        fl1 = setdiff(fl1,temp);
    end
    
end

if ~isempty(fl2exclude)
    fl2exclude = engine('path',fld2,'extension','zoo','search file',fl2exclude);
    fl2 = setdiff(fl2,fl2exclude);
end


%-----------ERROR CHECKING---------
%
stk1 = cell(size(fl1));
for k = 1:length(fl1)
    [~,stk1{k}] = fileparts(fl1{k});
end

stk2 = cell(size(fl2));
for l = 1:length(fl2)
    [~,stk2{l}] = fileparts(fl2{l});
end

a = ismember(stk1,stk2);
b = find(a==0);     %different files

if ~isempty(b);
    
    for l = 1:length(b)
        disp([stk1{b(l)},' and ', stk2{b(l)}, ' have different file names'])
    end
    
    disp(' ')
    disp(' **************program ended****************')
    disp(' ')
    
    return
    
end




%----------RUN PROGRAM-----------


for i = 1:length(fl1)
    
    data = zload(fl1{i});
    data1 = data;
    
    data = zload(fl2{i});
    data2 = data;
    
    indx1 = strfind(fl1{i},s);
    indx1 = indx1(end-1);
    
    indx2 = strfind(fl2{i},s);
    indx2 = indx2(end-1);
    
    batchdisp(fl1{i},'combining')
    batchdisp(fl2{i},'combining')
    disp(' ')
    
    if strcmp(fl1{i}(indx1:end),fl1{i}(indx2:end))==0
        disp ('*****file name error*********')
        disp(' ')
        disp(fl1{i})
        disp(fl1{i})
        
        return
    end
    
    data = combine_data(data1,data2,method);
    
    zsave(fl1{i},data);
end


disp (['all files saved in ',fld1])




