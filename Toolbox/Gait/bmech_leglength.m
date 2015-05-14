function bmech_leglength(fld)

% BMECH_LEG_LENGTH(fld) computes average leg length from right and left leg length
%
% ARGUMENTS
% fld   ...   folder to operate on
%
% NOTES
% - This function reads left and right leg length data from zoosystem branch of zoo files
%   and computes average
%


% Revision History
%
% Created March 31st 2015
%


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
    fld = uigetfolder;
end

cd(fld)



% Batch process
%
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'computing average leg-length')
    data= av_leg(data);
    save(fl{i},'data');
end


function data = av_leg(data)

% Error checking
% 
if ~isfield(data.zoosystem.Anthro,'LLegLength') || ~isfield(data.zoosystem.Anthro,'RLegLength')
    error('missing leg length information')
end

% Compute average leg-length
%
LLeg = data.zoosystem.Anthro.LLegLength;
RLeg = data.zoosystem.Anthro.RLegLength;

Leg = mean([LLeg RLeg]);

% Add to zoosystem
%
data.zoosystem.Anthro.LegLength = Leg;