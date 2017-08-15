function fld = setZooFld(fld,mode,name)

% fld = SETZOOFLD(fld,mode,name) prepares folders for batch processing
% steps
%
% Notes:
% - This function can be used in biomechZoo processing scripts to replace
%   multiple 'uigetfolder' calls. For example, given an existing fld '1-c3d2zoo',
%   the following code will move all data in '1-c3d2zoo' to the new folder called
%   '2-some process'and update the fld variable:
%
%  mode = 'auto';
%  fld = 'C:\Users\Phil\samplestudy\1-c3d2zoo'
%  fld = setZooFld(fld,mode,'some process');
%
%
%
% Created by Philippe C. Dixon April 2017

if strcmp(mode,'manual')
    fld = uigetfolder;
else
    indx = strfind(fld,filesep);
    cfld = fld(indx(end)+1:end);
    cstep = str2double(cfld(1));
    nstep = cstep+1;
    if isnan(nstep)
        temp = strrep(fld,cfld,name);
    else
        temp = strrep(fld,cfld,[num2str(nstep),'-',name]);
    end
    
    if ~exist(temp,'dir')
        mkdir(temp)
    end
    copyfile(fld,temp)
    fld = temp;
end