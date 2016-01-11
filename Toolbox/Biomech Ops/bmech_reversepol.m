function bmech_reversepol(fld,ch)

% bmech_reversepol(fld,ch) reveres the polarity of a given channel and
% accompanying event if available
%
% ARGUMENTS
%  fld   ...  folder to operate on. 
%  ch    ...  channels to reverse as cell array of strings
%
% Example
% fld = 'c:/my documents'
% ch = {'Fz1','Fz2'}
% bmech_reversepol(fld,ch) reverses the polarity of the the channels Fz1
% and Fz2 in all files contained within the folder 'c:/my documents'
%
% Notes
% - event of type range of motion ('rom') will not be changed


% Revision history: 
%
% Created by Philippe C. Dixon 2008  
%
% Updated by Philippe C. Dixon May 2015
% - event data are reversed as well
% - Help improved
%
% Updated by Philippe C. Dixon June 2015
% - events of type 'rom' will not be reversed
% - improved error checking
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
if nargin==0
    fld = uigetfolder;
    ch = 'all';
end

if nargin ==1
    ch = 'all';
end

cd(fld);

if ischar(ch)
    ch = {ch};
end


% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'reversing polarity');
    data = reversepol(data,ch);
    zsave(fl{i},data);
    
    if isin(ch{1},'all')
        zsave(fl{i},data,'for all channels')
    else
        zsave(fl{i},data,['for channel ',strjoin(ch)])
    end
    
end





function data = reversepol(data,ch)


if isin(ch{1},'all')
    ch = setdiff(fieldnames(data),'zoosystem');
end


for i = 1:length(ch)
    
    data.(ch{i}).line = -1.*data.(ch{i}).line;
    evt = fieldnames(data.(ch{i}).event);
    
    for j = 1:length(evt)
        
        if ~isin(evt,'rom')
        r = data.(ch{i}).event.(evt{j});
        data.(ch{i}).event.(evt{j}) = [r(1) -r(2) r(3)];
        end
    end
end





