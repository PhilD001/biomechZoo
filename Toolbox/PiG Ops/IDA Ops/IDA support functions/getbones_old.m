function [pgbone,oxbone,jnt,data] = getbones(data)

% This function retrieves bone information from data struct and creates
% joints. This is used for grood and suntay calculations 
%
% ARGUMENTS
% data    ....  struct containing marker data
%
% RETURNS
% bone   ....   The names of the different bone segments
% jnt    ...    The joint name and the bones used to calculate the joint
%               angle ex. RightMTP joint is calculated from RightForeFoot and RightHallux
%
% Updated Dec 2010
% -more simple code
% - used for both OFM and PG models
%
% Updated May 2014
% - compatible with zoosystem v.1.2



pgbone = [];
oxbone = [];
jnt = [];


% Using AJC improves measurement and matches the OFM outputs (see OFM
% powerpoint that says this must be the origin)

if isfield(data,'RAJC')
    data = addchannel_data(data,'RTIB0',data.RAJC.line,'Video');
    data.RTIB0.event= struct;
    data = addchannel_data(data,'LTIB0',data.LAJC.line,'Video');
    data.LTIB0.event= struct;
end


ch = fieldnames(data);

%---Plugin gait modl joints and bones


if ismember({'PELO','RFEO'},ch)  
    [TF,indx]=ismember({'PELO'},ch);
    chname = ch{indx};
    
    jplate = {'RightHip','Pelvis','RightFemur'};
    bplate = {chname(1:3),'Pelvis'};   
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end


if ismember({'RFEO','RTIO'},ch)
    [TF,indx]=ismember({'RFEO'},ch);
    chname = ch{indx};
    
    jplate = {'RightKnee','RightFemur','RightTibiaPG'};
    bplate = {chname(1:3),'RightFemur'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end


if ismember({'RTIO','RFOO'},ch)
    [TF,indx]=ismember({'RTIO'},ch);
    chname = ch{indx};
    
    jplate = {'RightAnklePG','RightTibiaPG','RightFoot'};
    bplate = {chname(1:3),'RightTibiaPG'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember('RFOO',ch)
    [TF,indx]=ismember({'RFOO'},ch);
    chname = ch{indx};

    bplate = {chname(1:3),'RightFoot'};
    pgbone = [pgbone;bplate];
end




if ismember({'PELO','LFEO'},ch)
    [TF,indx]=ismember({'PELO'},ch);
    chname = ch{indx};
    
    jplate = {'LeftHip','Pelvis','LeftFemur'};
    bplate = {chname(1:3),'Pelvis'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];  
end

if ismember({'LFEO','LTIO'},ch)
    [TF,indx]=ismember({'LFEO'},ch);
    chname = ch{indx};
    
    jplate = {'LeftKnee','LeftFemur','LeftTibiaPG'};
    bplate = {chname(1:3),'LeftFemur'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end





if ismember({'LTIO','LFOO'},ch) 
    [TF,indx]=ismember({'LTIO'},ch);
    chname = ch{indx};
    
    jplate = {'LeftAnklePG','LeftTibiaPG','LeftFoot'};
    bplate = {chname(1:3),'LeftTibiaPG'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember('LFOO',ch)
    [TF,indx]=ismember({'LFOO'},ch);
    chname = ch{indx};

    bplate = {chname(1:3),'LeftFoot'};
    pgbone = [pgbone;bplate];
end

%---Oxford Foot Model joints and bones---

if ismember({'RTIB0','RHDF0'},ch)   
    [TF,indx]=ismember({'RTIB0'},ch);
    chname = ch{indx};
    
    jplate = {'RightAnkleOFM','RightTibiaOFM','RightHindFoot'};
    bplate = {chname(1:4),'RightTibiaOFM'};  
    
    jnt=[jnt;jplate];
    oxbone = [oxbone;bplate];
end

if ismember({'RHDF0','RFOF0'},ch)  
    [TF,indx]=ismember({'RHDF0'},ch);
    chname = ch{indx};
    
    jplate = {'RightMidFoot','RightHindFoot','RightForeFoot'};
    bplate = {chname(1:4),'RightHindFoot'};   
        
    jnt=[jnt;jplate];    
    oxbone = [oxbone;bplate];
end


if ismember({'RFOF0','RHLX0'},ch)
    [TF,indx]=ismember({'RFOF0'},ch);
    chname = ch{indx};

    jplate = {'RightMTP','RightForeFoot','RightHallux'};
    bplate = {chname(1:4),'RightForeFoot'};

    jnt=[jnt;jplate];
    oxbone = [oxbone;bplate];
end

if ismember('RHLX0',ch)
    [TF,indx]=ismember({'RHLX0'},ch);
    chname = ch{indx};

    bplate = {chname(1:4),'RightHallux'};
    oxbone = [oxbone;bplate];
end

if ismember({'LTIB0','LHDF0'},ch)
    [TF,indx]=ismember({'LTIB0'},ch);
    chname = ch{indx};

    jplate = {'LeftAnkleOFM','LeftTibiaOFM','LeftHindFoot'};
    bplate = {chname(1:4),'LeftTibiaOFM'};

    jnt=[jnt;jplate];
    oxbone = [oxbone;bplate];
end

if ismember({'LHDF0','LFOF0'},ch)
    [TF,indx]=ismember({'LHDF0'},ch);
    chname = ch{indx};

    jplate = {'LeftMidFoot','LeftHindFoot','LeftForeFoot'};
    bplate = {chname(1:4),'LeftHindFoot'};

    jnt=[jnt;jplate];
    oxbone = [oxbone;bplate];
end

if ismember({'LFOF0','LHLX0'},ch)
    [TF,indx]=ismember({'LFOF0'},ch);
    chname = ch{indx};

    jplate = {'LeftMTP','LeftForeFoot','LeftHallux'};
    bplate = {chname(1:4),'LeftForeFoot'};

    jnt=[jnt;jplate];
    oxbone = [oxbone;bplate];
end

if ismember('LHLX0',ch)
    [TF,indx]=ismember({'LHLX0'},ch);
    chname = ch{indx};

    bplate = {chname(1:4),'LeftHallux'};
    oxbone = [oxbone;bplate];
end



%== UPPPER BODY FOR FUTURE REFERENCE===


% if ismember({'TRXO','PELO'},ch)
%     plate = {'Trunk','Thorax','Pelvis'};
%     jnt=[jnt;plate];
% end
% 
% if ismember({'RRAO','RHNO'},ch)
%     plate = {'RightWrist','RightRadius','RightHand'};
%     jnt=[jnt;plate];
% end
% 
% if ismember({'RHUO','RRAO'},ch)
%     plate = {'RightElbow','RightHumerus','RightRadius'};
%     jnt=[jnt;plate];
% end
% 
% if ismember({'TRXO','RHUO'},ch)
%     plate = { 'RightShoulder','Thorax','RightHumerus'};
%     jnt=[jnt;plate];
% end
% 
% if ismember({'LRAO','LHNO'},ch)
%     plate = {'LeftWrist','LeftRadius','LeftHand'};
%     jnt=[jnt;plate];
% end
% 
% if ismember({'LHUO','LRAO'},ch)
%     plate = {'LeftElbow','LeftHumerus','LeftRadius'};
%     jnt=[jnt;plate];
% end
% 
% if ismember({'TRXO','LHUO'},ch)
%     plate = { 'LeftShoulder','Thorax','LeftHumerus'};
%     jnt=[jnt;plate];
% end


