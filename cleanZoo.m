function cleanZoo

% CLEANZOO removes outputs and folders created by running the various
% examples in the biomechZoo-help repository. Used prior to releasing a
% biomechZoo update
%
% NOTES
% - It is assumed that biomechZoo was properly added to the matlab path
% using startZoo


fld = fileparts(which('samplestudy_process.m'));           % sample study root
cd(fld)
% Remove user generated folders and files from the sample study folder
%
sfld = fullfile(fld,'Data','zoo files (auto process)');    % sample study user gen data folder

if exist(sfld,'dir')
    if strcmp(pwd,sfld)
        cd(fld)
    end
    batchdisp(sfld,'deleting')  
    rmdir(sfld,'s');
end

fl = fullfile(fld,'Statistics','eventval.xlsx');            % sample study user gen stats file
if exist(fl,'file')
    batchdisp(fl,'deleting')
    delete(fl)
end

fl = fullfile(fld,'Statistics','eventval.xls');            % sample study user gen stats file
if exist(fl,'file')
    batchdisp(fl,'deleting')
    delete(fl)
end
 
 

% Remove user generated folders in the examples
%
indx = strfind(fld,'biomechZoo-help');
efld = fullfile(fld(1:indx+14),'examples');

sub = subdir(efld)';

for i = 1:length(sub)
    
    if ~isempty(strfind(sub{i},'example data (processed)'))
        fl = engine('fld',sub{i});
        if ~isempty(fl)
            delfile(fl)
        end
        
        if exist(sub{i},'dir')
            rmdir(sub{i},'s')
        end
        
    elseif ~isempty(strfind(sub{i},'Statistics'))
        fl = engine('fld',sub{i});
        if ~isempty(fl)
            delfile(fl)
        end
        
        if exist(sub{i},'dir')
            rmdir(sub{i},'s')
        end
        
    end
    
end

% remove the prop file created by sampleprop_example
%
pfl = engine('fld',efld,'extension','.prop');
if ~isempty(pfl)
    delfile(pfl)
end

% remove the stats file created by eventval_example
efl = engine('fld',efld,'extension','.xls');
if ~isempty(efl)
    delfile(efl)
end

% remove some mac junk
%fl
rfld = fld(1:indx+14);  % help files folder
zfld = fld(1:indx+9);   % toolbox root
fl = engine('fld',rfld,'extension','.DS_store');
delfile(fl)
fl = engine('fld',zfld,'extension','.DS_store');
delfile(fl)

% remove some conflict junk
fl = engine('fld',rfld,'search file','conflict');
delfile(fl)
fl = engine('fld',zfld,'search file','conflicted copy');
delfile(fl)