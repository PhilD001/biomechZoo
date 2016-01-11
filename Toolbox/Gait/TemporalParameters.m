function [ StepTime1, StepTime2,StrideTime] = TemporalParameters(FS1,FS2,FS3)


% computes temporal parameters using heel kinematic data
%
% ARGUMENTS
% FS1            ... time of 1st ipsilateral foot strike
% FS2            ... time of 1st contraleral foot strike
% FS3            ... time of 2nd ipsilateral foot strike
%
% RETURNS
% StrideTime     ... Stride time in same units as input units
% StepTime       ... Step time in same units as input units

% Created by Phil Dixon November 24th 2011
% 
% updated January 18 2012
% - StrideTime becomes optional


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


%----COMPUTE SPATIAL COORDINATES--

if nargin==2

StepTime1 = FS2-FS1;
StepTime2 = FS3-FS2;

StrideTime = [];

else


StrideTime = FS3-FS1;

end