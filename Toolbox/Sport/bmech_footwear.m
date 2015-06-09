function bmech_footwear(fld,type)

% BMECH_FOOTWEAR(fld,type) adds a tag to the zoosystem folder to allow
% 'director' to add specific footwear to the skeleton model
%
% ARGUMENTS
% fld   ...  folder to operate on
% type  ...  type of footwear. Default 'skates'
%
% NOTES
% - Currently only 'skates' are available. Users wishing to add different
%   footwear need to create prop objects. See visualization/Cinema objects
%   for example props 

% Revision History
%
% Created by Philippe C. Dixon May 2015


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
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 



% Set defaults
%
if nargin==0
    fld = uigetfolder;
    type = 'skates';
end

if nargin==1
    type = 'skates';
end


cd(fld)

fl = engine('fld',fld,'extension','zoo');


for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},['adding ',type,' to model'])
    data.zoosystem.Anthro.Feet = type;
    save(fl{i},'data'); 
end

