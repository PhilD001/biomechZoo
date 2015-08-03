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


%----COMPUTE SPATIAL COORDINATES--

if nargin==2

StepTime1 = FS2-FS1;
StepTime2 = FS3-FS2;

StrideTime = [];

else


StrideTime = FS3-FS1;

end