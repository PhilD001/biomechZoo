function bmech_normalize(fld,datalength,intmethod)

% BMECH_NORMALIZE(FLD,DATALENGTH,INTMETHOD) will normalize data to a given data length
%
% ARGUMENTS
%  fld          ...   Folder to operate on
%  datalength   ...   Normalize data to a specific length. Data will have
%                     datalength+1 frames. Default 101 frames
%  intmethod    ...   method to interpolate data. Default 'linear'.
%                     See interp1 for more options
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
% Updated by Philippe C. Dixon Jan 2010
% - this function now normalizes event data as well
% - function only runs in batch file mode, 
%
% Updated by Philippe C. Dixon June 2010
% -Event normalization verified and improved. 
%
% Updated by Philippe C. Dixon May 2015
% - Help improved
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'
%
% Updated by Philippe C. Dixon Jan 11th 
% - Interpolation can be performed using any method available in the
%  'interp1' function


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


% Set defaults
%
if nargin==0
    disp('normalizing to 100%, please select your folder');
    disp(' ');
    datalength = 100;
    fld = uigetfolder('select zoo processed ');
    cd(fld);  
    intmethod = 'linear';

end

if nargin ==1
    disp(['normalizing to 100%, using folder ',fld]);
    datalength=100;
    intmethod = 'linear';
end

if nargin ==2
    disp(['normalizing to ',num2str(datalength),'using folder ',fld])
    intmethod = 'linear';
end



% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'normalizing:');
    data = normalizedata(data,datalength,intmethod);
    zsave(fl{i},data, [num2str(datalength+1) ' frames']);
end




function data = normalizedata(data,ndatalength,intmethod)

ch = setdiff(fieldnames(data),{'zoosystem'});

if  isfield(data.zoosystem.Video,'Indx')
    data.zoosystem.Video.Indx = 0:1:ndatalength;
end


for i = 1:length(ch)

    [data.(ch{i}).line,nlength] = normalizeline(data.(ch{i}).line,ndatalength,intmethod);
    
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













