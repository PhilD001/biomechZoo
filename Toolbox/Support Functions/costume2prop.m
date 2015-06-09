function costume2prop(fld)

% costume2prop(fld) converts costume objects to props
%
% ARGUMENTS
%  fld ...  path to folder

% Created by JJ Loh June 2015

if nargin==0
    fld = uigetfolder;
end
cd(fld)

fl = engine('path',fld,'extension','cos');

for i = 1 :length(fl)
    batchdisplay(fl{i},'converting to prop')
    t = load(fl{i},'-mat');
    fl{i} = extension(fl{i},'prop');
    object = t.costume;
    
    save(fl{i},'object');
end