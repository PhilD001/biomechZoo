function bmech_cocontraction(fld,pairs)

% BMECH_COCONTRACTION computes co-contraction index for muscle pairs
%
% ARGUMENTS
%  fld           ...   folder to operate on
%  pairs       ...   Names of muscle pairs (cell array of strings). Default = {'VM_MG','VM_MH','VL_LG','VL_LH'}



if nargin==0
    fld = uigetfolder;
    pairs = {'VM_MG','VM_MH','VL_LG','VL_LH'};                                           % muscle pairs for co-contraction
end

if nargin==1
    pairs = {'VM_MG','VM_MH','VL_LG','VL_LH'};                                           % muscle pairs for co-contraction
end

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'computing co-contraction');
    data = cocontraction_data(data,pairs);
    zsave(fl{i},data);
end