function bmech_partition(evt1,evt2,fld,folders)

% BMECH_PARTITION(evt1,evt2,fld,folders) partitions (cuts) files from evt1 and evt2.
%
% ARGUMENTS
%  evt1     ...   Name of first event as a string.
%  evt2     ...   Name of second event as a string.
%  fld      ...   Path leading to files (Optional argument). Default, popup during
%                 function call
%  folders  ...   Name of folders as cell array of sttring in which NOT to partition. Default 'all'



% Revision History
% 
% Created by JJ Loh 2006
%
% Updated by Philippe C. Dixon August 2009
% - functions within ensembler now
%
% Updated by Philippe C. Dixon February 2012
% - multiple excluded folders are now possible
%
% Updated by Philippe C. Dixon May 2015
% - improved help
% - cleaned up code
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'


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


% Set Defaults
%
if nargin == 2
    folders  = 'all';
    fld = uigetfolder;
end

if nargin ==3
    folders  = 'all';
end


% Batch proces
%
cd(fld);
fl = engine('path',fld,'extension','zoo');

if strcmp(folders,'all')==1
    
    for i = 1:length(fl)
        data = zload(fl{i});
        batchdisplay(fl{i},'partitioning');
        data = partitiondata(data,evt1,evt2);
        zsave(fl{i},data,[evt1,' to ',evt2]) 
    end
    
else
    
    for i = 1:length(fl)
        
        if ~isin(fl{i},folders)
            
            data = zload(fl{i});
            batchdisplay(fl{i},'partitioning');
            data = partitiondata(data,evt1,evt2);
            zsave(fl{i},data,[evt1,' to', evt2])            
        else
            batchdisplay(fl{i},'not partitioning');
            
            
        end
        
    end
    
end

















