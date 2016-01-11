function [StrideLength, StepLength,StrideWidth] = SpatialParameters(FS1,FS2,FS3)


% computes spatial-temporal parameters for any walking condition
% based on 'Defining spatial parameters for non-linear walking' 
% Gait & Posture 23 (2006) Huxham et al.
%
% ARGUMENTS
% FS1            ... coordinates of 1st ipsilateral foot strike
% FS2            ... coordinates of 1st contraleral foot strike
% FS3            ... coordinates of 2nd ipsilateral foot strike
%
% RETURNS
% StrideLength  ... Stride Length in same units as input units
% StepLength    ... Step Length in same units as input units
% StrideWidth   ... Stride width in same units as input units




% Created by Phil Dixon November 24th 2011


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
a = magnitude(FS2-FS1);   % based on fig 4 of Huxham
b = magnitude(FS3-FS2);
c = magnitude(FS3-FS1);

StrideLength = c;

StepLength =  (b^2 + c^2  - a^2)/(2*c);

StrideWidth = sqrt(b^2 - StepLength^2);

