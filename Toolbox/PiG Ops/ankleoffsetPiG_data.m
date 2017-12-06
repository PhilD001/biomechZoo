function data = ankleoffsetPiG_data(data,sdata)

% data = ankleoffsetPiG_data(data,sdata) adds the Plantarflexion and Rotation offset
% computed from a static (anatomical pose) trial to a given dynamic
% (movement) trial. 
%
% ARGUMENTS
%  data   ...  Zoo file representing dynamic trial data
%  sdata  ...  Zoo file representing static trial data
%
% RETURNS
%  data   ...  dynamic trial data with offsets appended to file
%
% NOTES
% - This is a likely source of error between PiG and biomechZoo. Further
%   work could explore why the two estimates sometimes differ

% Updated by Philippe C. Dixon Dec 2017
% - use of nanmean to avoid problems with missing data

data.zoosystem.Anthro.RStaticPlantFlex = nanmean(deg2rad(sdata.RightAnkleStaticAngle_x.line));
data.zoosystem.Anthro.RStaticRotOff = nanmean(-deg2rad(sdata.RightAnkleStaticAngle_z.line));

data.zoosystem.Anthro.LStaticPlantFlex = nanmean(deg2rad(sdata.LeftAnkleStaticAngle_x.line));
data.zoosystem.Anthro.LStaticRotOff = nanmean(deg2rad(sdata.LeftAnkleStaticAngle_z.line));
