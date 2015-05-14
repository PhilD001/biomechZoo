function bmech_normalize(fld,datalength)

% BMECH_NORMALIZE(fld,datalength) will normalize data to a given data length
%
% ARGUMENTS
%  fld          ...   Folder to operate on
%  datalength   ...   Normalize data to a specific length. Data will have
%                     datalength+1 frames. Default 101 frames
% 
% NOTES
% - If no arguments are supplied, the function will ask for a folder to
%   operate on and normalize to 101 frames
% - All channels of a given file will be normalized
% - Normalization will not recalculate an event value. It will only recalculate the 
%   event index. Thus an event may not 'lie' 
%   exactly on a normalized line. Statistics can still be run on these data. 
% - For processing a single vector, use standalone NORMALIZELINE.m 


% Revision history: 
%
% Updated Jan 2010
% - this function now normalizes event data as well
% - function only runs in batch file mode, 
%
% Updated June 2010
% -Event normalization verified and improved. 
%
% Updated May 2015
% - Help improved



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
% Aduts and Children. Rome, Italy.Sept 29-Oct 4th 2014. 



% Set defaults
%
if nargin==0
    disp('normalizing to 100%, please select your folder');
    disp(' ');
    datalength = 100;
    fld = uigetfolder('select zoo processed ');
    cd(fld);  
end

if nargin ==1
    disp(['normalizing to 100%, using folder ',fld]);
    datalength=100;
end

if nargin ==2
    disp(['normalizing to ',num2str(datalength),'using folder ',fld])
end



% Batch process
%
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'normalizing:');
    data = normalizedata(data,datalength);
    save(fl{i},'data');
end




function data = normalizedata(data,ndatalength)

ch = setdiff(fieldnames(data),{'zoosystem'});

if  isfield(data.zoosystem.Video,'Indx')
    data.zoosystem.Video.Indx = 0:1:ndatalength;
end


for i = 1:length(ch)

    [data.(ch{i}).line,nlength] = normalizeline(data.(ch{i}).line,ndatalength);
    
    if ~isempty(fieldnames(data.(ch{i}).event))
        
        event = fieldnames(data.(ch{i}).event);
        
        for e = 1:length(event)
            
            if data.(ch{i}).event.(event{e})(2)~=999
                
                if data.(ch{i}).event.(event{e})(1)~=1
                    data.(ch{i}).event.(event{e})(1) = round(data.(ch{i}).event.(event{e})(1)/(nlength)*ndatalength);
                end
                
            end
            
        end
    end
    
end













