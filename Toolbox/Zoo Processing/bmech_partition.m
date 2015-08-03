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


% Part of the Zoosystem Biomechanics Toolbox 
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
        save(fl{i},'data');
    end
    
else
    
    for i = 1:length(fl)
        
        if ~isin(fl{i},folders)
            
            data = zload(fl{i});
            batchdisplay(fl{i},'partitioning');
            data = partitiondata(data,evt1,evt2);
            save(fl{i},'data');
        else
            batchdisplay(fl{i},'not partitioning');
            
            
        end
        
    end
    
end

















