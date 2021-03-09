function bmech_forceplate2limbside(fld,ch,thresh,ref)

% BMECH_FORCEPLATE2LIMBSIDE(fld,ch,thresh,ref) determines which limb (right
% or left) made contact with force plate n using marker data.
%
% ARGUMENTS
%  fld      ...   Folder of data to operate on
%  ch       ...   name of force plate channels used in algorithm. Default ForceFz
%  thresh   ...   threshold for detecting gait event. Default 20 N (as in Vicon)
%  ref      ...   Reference frame for ground reaction force data (body, ground). If
%                 body use ref = -1 (GRF peak is negative), if plate use ref = 1 (GRF
%                 peak is positive).Default ref = -1;
%
% NOTES
% - Information is stored in data.zoosystem.Analog.FPlates.LIMBSIDES
%
% See also forceplate2limbside_data,ZeniEventDetect


% Revision History
%
% Created by Philippe C. Dixon March 20th 2016
%
% Updated by Philippe C. Dixon July 2016
% - reformatted for zoosystem v1.3
% - additional default options


% Set defaults
%
if nargin==0
    fld = uigetfolder;
    ch = 'ForceFz';       % name of force plate channels used in algorithm
    thresh = 20;          % threshold for detecting gait event (N)
    ref = -1;             % body oriented reference (peak is negative)
end

if nargin==1
    ch = 'ForceFz';
    thresh = 20;
    ref = -1;
end

if nargin==2
    thresh = 20;
    ref = -1;
end

if nargin==3
    ref = -1;
end

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'associating limb to force plate')
    data= forceplate2limbside_data(data,ch,thresh,ref);
    zsave(fl{i},data);
end


