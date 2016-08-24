function COM=comass(data,f)


%   COM returns center of mass quantities for inverse dynamics 
%
%   ARGUMENTS
%   data    ...  structured array of segment data retured from c3d2com
%   fsamp   ...  sampling rate of signal
%   f       ...  choice of filtering 0 = no, 1 = yes (with default) or f =
%                struct with filter properties (see bmech filter)
%
%   RETURNS
%   COM     ... structured array containing positon and acceleration of center
%                of mass
%
% - Verified against Vaughan Data Jan 2011. Good match
%
%
% updated april 15th 2013
% - replaced call to function 'my_deriv' by 'bmech_deriv'
%
% Updated February 14th 2014
% - allow for full customization of filter properties


% -----1 - PLUGINGAIT BONES--------
fsamp = data.fsamp;



dsegments = {'RightFemur','LeftFemur','RightTibia','LeftTibia','RightFoot','LeftFoot'};
comsegments = {'RightThigh','LeftThigh','RightShank','LeftShank','RightFoot','LeftFoot'};

for i = 1:length(dsegments)
    COM.(comsegments{i}).Pos = data.(dsegments{i}).com;
end

for i = 1:length(comsegments)
    COM.(comsegments{i}).Acc = deriv_line(deriv_line(COM.(comsegments{i}).Pos,fsamp,f),fsamp,f);
end
    


% -----2 - OXFORD BONES--------

if isfield(data,'RightForeFoot')

    dsegments = {'RightTibiaOFM','LeftTibiaOFM','RightHindFoot','LeftHindFoot','RightForeFoot','LeftForeFoot'};
    comsegments = {'RightShankOFM','LeftShankOFM','RightHindFoot','LeftHindFoot','RightForeFoot','LeftForeFoot'};

    for i = 1:length(dsegments)
        COM.(comsegments{i}).Pos = data.(dsegments{i}).com;
        COM.(comsegments{i}).Acc = deriv_line(deriv_line(data.(dsegments{i}).com,fsamp,f),fsamp,f);
    end
end
    