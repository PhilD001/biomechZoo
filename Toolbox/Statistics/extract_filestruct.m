function [level1,level2,level3,level4] = extract_filestruct(fld)

% EXTRACT_FILESTRUCT returns file structure
%
% ARGUMENTS
%  fld   ...   root folder to operate on
%
% RETURNS
%  level1  ...  1st level of sorting in file tree
%  level2  ...  2nd level of sorting in file tree
%  level3  ...  3rd level of sorting in file tree
%  level4  ...  4th level of sorting in file tree


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon (D.Phil.), Harvard University. Cambridge, USA.
% Yannick Michaud-Paquette (M.Sc.), McGill University. Montreal, Canada.
% JJ Loh (M.Sc.), Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com or pdixon@hsph.harvard.edu
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the conference abstract below if the zoosystem was used in the 
% preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement 
% Analysis Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of 
% Movement Analysis in Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.


% EXTRACT ALL FILES
%
fl = engine('path',fld,'extension','zoo');


% FIND 1st Level (e.g. between subject condition)
%
s = filesep;
subdirs = subdir(fld);
indxfld = strfind(fld,s);

level1 = cell(length(fl),1);

for i = 1:length(subdirs)
    
    temp = subdirs{i};
    indxgrp = strfind(subdirs{i},s);
        
    if length(indxgrp) == length(indxfld) +1                 % groups are 1 step down
        level1{i} = temp(indxgrp(end)+1:end);
    end
      
end

level1(cellfun(@isempty,level1)) = [];                       % That's some hot programming
       
    

% FIND 2nd level (e.g. subject)
%
level2 = cell(length(fl),1);

for i = 1:length(subdirs)
    
    temp = subdirs{i};
    indxsub = strfind(subdirs{i},s);
        
    if length(indxsub) == length(indxfld) +2                  % subjects are 2 steps down  
        level2{i} = temp(indxsub(end)+1:end);
    end
      
end

level2(cellfun(@isempty,level2)) = [];                    % That's some hot programming

    

% Find 3rd level (e.g. within subject conditon)
%
level3 = cell(length(fl),1);

for i = 1:length(subdirs)
    
    temp = subdirs{i};
    indxcon = strfind(subdirs{i},s);
        
    if length(indxcon) == length(indxfld) + 3                  % condiitons (if any) are 3  steps down  
        level3{i} = temp(indxcon(end)+1:end);
    end
      
end

level3(cellfun(@isempty,level3)) = [];                             % That's some hot programming
level3 = unique(level3);


% Find 4th level (e.g. within subject conditon)
%
level4 = cell(length(fl),1);

for i = 1:length(subdirs)
    
    temp = subdirs{i};
    indxcon = strfind(subdirs{i},s);
        
    if length(indxcon) == length(indxfld) + 4                  % condiitons (if any) are 3  steps down  
        level4{i} = temp(indxcon(end)+1:end);
    end
      
end

level4(cellfun(@isempty,level4)) = [];                             % That's some hot programming
level4 = unique(level4);

