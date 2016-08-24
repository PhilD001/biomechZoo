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



data.zoosystem.Anthro.RStaticPlantFlex = mean(deg2rad(sdata.RightAnkleStaticAngle_x.line));
data.zoosystem.Anthro.RStaticRotOff = mean(-deg2rad(sdata.RightAnkleStaticAngle_z.line));

data.zoosystem.Anthro.LStaticPlantFlex = mean(deg2rad(sdata.LeftAnkleStaticAngle_x.line));
data.zoosystem.Anthro.LStaticRotOff = mean(deg2rad(sdata.LeftAnkleStaticAngle_z.line));
