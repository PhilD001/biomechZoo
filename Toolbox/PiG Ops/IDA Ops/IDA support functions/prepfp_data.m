function data = prepfp_data(data,filt,localOr, globalOr,orientFP)

% data = PREPFP_DATA(data,filt,localOr, globalOr,orientFP) prepared force plate data
% for inverse dynamics analysis
%
% ARGUMENTS
%  data       ... Zoo data
%  filt       ... Filter settings (struct)
%  localOr    ... true local FP origin
%  glboalOr   ... FP global origin/orient
%  orientFP   ... Orientation of FP wrt global coordinate system
%
% RETURNS
%  data        ...  zoo data with processed GRF quantities

               

% Updated October 20th 2013
% - Full functionality with FP3
%
% Updated by Philippe C. Dixon August 2016
% - Made more consisten with BiomechZoo version 1.3


% find gait direction in lab
%
[data,dir] = getDir(data);
data.zoosystem.CompInfo.Direction = dir;


% Process GRF data      
%
data = filter_data(data,data.zoosystem.Analog.FPlates.LABELS,filt);     
data = resample_data(data,data.zoosystem.Analog.FPlates.LABELS);                                 % resample all analog
data = centreofpressure_data(data,localOr,globalOr,orientFP);  % compute cop w orientFP
data = forceplate2limbside_data(data);                         % ass limb side w FP
data = fprename_data(data);                                         % rename 'RightGroundRea...'
data = massnormalize_data(data,data.zoosystem.Analog.FPlates.LABELS);
data = grfref_data(data,orientFP);





