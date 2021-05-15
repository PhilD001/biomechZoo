function [pgbone,jnt,data,oxbone] = getbones_data(data)

% [bone,jnt,data] = GETBONES_DATA(data) retrieves bone information from data struct and creates
% joints. This is used for grood and suntay calculations 
%
% ARGUMENTS
% data    ....  struct containing marker data
%
% RETURNS
% bone   ....   The names of the different bone segments
% jnt    ...    The joint name and the bones used to calculate the joint
%               angle ex. RightMTP joint is calculated from RightForeFoot and RightHallux


% Revision History
%
% Updated Dec 2010 by Philippe C. Dixon
% - more simple code
% - used for both OFM and PG models
%
% Updated April 2016 by Philippe C. Dixon
% - Removed backwards Matlab compatibility 
%
% Updated June 2017 by Philippe C. Dixon
% - upperbody bones head and thorax tested



pgbone = [];
oxbone = [];
jnt = [];


% Add on to improve agreement with vicon
%
if isfield(data,'RAJC') && isfield(data,'LAJC')
    data = addchannel_data(data,'RTIB0',data.RAJC.line,'Video');
    data.RTIB0.event= struct;
    data = addchannel_data(data,'LTIB0',data.LAJC.line,'Video');
    data.LTIB0.event= struct;
elseif isfield(data,'RAJC') && ~isfield(data,'LAJC')          
    data = addchannel_data(data,'RTIB0',data.RAJC.line,'Video');
    data.RTIB0.event= struct;
    data = addchannel_data(data,'LTIB0',data.LAnkleJC.line,'Video');
    data.LTIB0.event= struct;
    disp('OFM model not correctly processed for left side')
end



ch = fieldnames(data);

%---Plugin gait model joints and bones

if ismember({'PELO','RFEO'},ch)  
    [~,indx]=ismember({'PELO'},ch);
    chname = ch{indx};
    
    jplate = {'GlobalPelvis','Global','Pelvis'};
    bplate = {'GLB_PEL','Global'};   
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
    
    jplate = {'GlobalBelfastPelvis','GlobalBelfast','Pelvis'};
    bplate = {'GLB_PEL','GlobalBelfast'};   
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
    
    jplate = {'RightHip','Pelvis','RightFemur'};
    bplate = {chname(1:3),'Pelvis'};   
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
    
    jplate = {'LeftHip','Pelvis','LeftFemur'};
    bplate = {chname(1:3),'Pelvis'};   
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember({'RFEO','RTIO'},ch)
    [~,indx]=ismember({'RFEO'},ch);
    chname = ch{indx};
    
    jplate = {'RightKnee','RightFemur','RightTibia'};
    bplate = {chname(1:3),'RightFemur'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember({'RTIO','RFOO'},ch)
    [~,indx]=ismember({'RTIO'},ch);
    chname = ch{indx};
    
    jplate = {'RightAnkle','RightTibia','RightFoot'};
    bplate = {chname(1:3),'RightTibia'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember('RFOO',ch)
    [~,indx]=ismember({'RFOO'},ch);
    chname = ch{indx};

    bplate = {chname(1:3),'RightFoot'};
    pgbone = [pgbone;bplate];
end

if ismember({'LFEO','LTIO'},ch)
    [~,indx]=ismember({'LFEO'},ch);
    chname = ch{indx};
    
    jplate = {'LeftKnee','LeftFemur','LeftTibia'};
    bplate = {chname(1:3),'LeftFemur'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember({'LTIO','LFOO'},ch) 
    [~,indx]=ismember({'LTIO'},ch);
    chname = ch{indx};
    
    jplate = {'LeftAnkle','LeftTibia','LeftFoot'};
    bplate = {chname(1:3),'LeftTibia'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember('LFOO',ch)
    [~,indx]=ismember({'LFOO'},ch);
    chname = ch{indx};

    bplate = {chname(1:3),'LeftFoot'};
    pgbone = [pgbone;bplate];
end

% Gloabl upper body
%
if ismember({'HEDO'},ch)
    [~,indx]=ismember({'HEDO'},ch);
    chname = ch{indx};
    
    jplate = {'GlobalHead','Global','Head'};
    bplate = {chname(1:3),'Head'};   
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember({'TRXO'},ch)
    [~,indx]=ismember({'TRXO'},ch);
    chname = ch{indx};
    
    jplate = {'GlobalThorax','Global','Thorax'};
    bplate = {chname(1:3),'Thorax'};   
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

%== UPPPER BODY (NOT TESTED)==
%
if ismember({'RHUO','RRAO'},ch)
    [~,indx]=ismember({'RHUO'},ch);
    chname = ch{indx};
    
    jplate = {'RightElbow','RightHumerus','RightRadius'};
    bplate = {chname(1:3),'RightHumerus'};  

    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end


if ismember({'LHUO','LRAO'},ch)
    [~,indx]=ismember({'LHUO'},ch);
    chname = ch{indx};
    
    jplate = {'LeftElbow','LeftHumerus','LeftRadius'};
    bplate = {chname(1:3),'LeftHumerus'};  

    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end


if ismember({'RRAO','RHNO'},ch)
    [~,indx]=ismember({'RRAO'},ch);
    chname = ch{indx};
    
    jplate = {'RightWrist','RightRadius','RightHand'};
    bplate = {chname(1:3),'RightRadius'};
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end


if ismember({'LRAO','LHNO'},ch)
     [~,indx]=ismember({'LRAO'},ch);
    chname = ch{indx};
    
    jplate = {'LeftWrist','LeftRadius','LeftHand'};
    bplate = {chname(1:3),'LeftRadius'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember('RHNO',ch)
    [~,indx]=ismember({'RHNO'},ch);
    chname = ch{indx};

    bplate = {chname(1:3),'RightHand'};
    pgbone = [pgbone;bplate];
end

if ismember('LHNO',ch)
    [~,indx]=ismember({'LHNO'},ch);
    chname = ch{indx};

    bplate = {chname(1:3),'LeftHand'};
    pgbone = [pgbone;bplate];
end



% if ismember({'RRAO','RHNO'},ch)
%     [~,indx]=ismember({'RRAO'},ch);
%     chname = ch{indx};
%     
%     jplate = {'RightWrist','RightRadius','RightHand'};
%     bplate = {chname(1:3),'Radius'};  
%     
%     pgbone = [pgbone;bplate];
% 
% end
% 
% if ismember({'RHUO','RRAO'},ch)
%     jplate = {'RightElbow','RightHumerus','RightRadius'};
%     jnt=[jnt;jplate];
% end
% 
% if ismember({'TRXO','RHUO'},ch)
%     jplate = { 'RightShoulder','Thorax','RightHumerus'};
%     jnt=[jnt;jplate];
% end
% 
% if ismember({'LRAO','LHNO'},ch)
%     jplate = {'LeftWrist','LeftRadius','LeftHand'};
%     jnt=[jnt;jplate];
% end
% 
% if ismember({'LHUO','LRAO'},ch)
%     jplate = {'LeftElbow','LeftHumerus','LeftRadius'};
%     jnt=[jnt;jplate];
% end
% 
% if ismember({'TRXO','LHUO'},ch)
%     jplate = { 'LeftShoulder','Thorax','LeftHumerus'};
%     jnt=[jnt;jplate];
% end


% PiG static trial bones
%
if ismember({'RF1O'},ch) 
    [~,indx]=ismember({'RF1O'},ch);
    chname = ch{indx};
    
    jplate = {'RightAnkleStatic','RightTibiaStatic','RightFootStatic'};
    bplate = {chname(1:3),'RightTibiaStatic'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember('RF2O',ch)
    [~,indx]=ismember({'RF2O'},ch);
    chname = ch{indx};
    bplate = {chname(1:3),'RightFootStatic'};
    pgbone = [pgbone;bplate];
end

if ismember('RF3O',ch)
    [~,indx]=ismember({'RF3O'},ch);
    chname = ch{indx};
    bplate = {chname(1:3),'RightFootStatic'};
    pgbone = [pgbone;bplate];
end

if ismember({'LF1O'},ch) 
    [~,indx]=ismember({'LF1O'},ch);
    chname = ch{indx};
    
    jplate = {'LeftAnkleStatic','LeftTibiaStatic','LeftFootStatic'};
    bplate = {chname(1:3),'LeftTibiaStatic'};  
    
    jnt=[jnt;jplate];
    pgbone = [pgbone;bplate];
end

if ismember('LF2O',ch)
    [~,indx]=ismember({'LF2O'},ch);
    chname = ch{indx};
    bplate = {chname(1:3),'LeftFootStatic'};
    pgbone = [pgbone;bplate];
end

if ismember('LF3O',ch)
    [~,indx]=ismember({'LF3O'},ch);
    chname = ch{indx};
    bplate = {chname(1:3),'LeftFootStatic'};
    pgbone = [pgbone;bplate];
end



%---Oxford Foot Model joints and bones---

if ismember({'RTIB0','RHDF0'},ch)   
    [~,indx]=ismember({'RTIB0'},ch);
    chname = ch{indx};
    
    jplate = {'RightAnkleOFM','RightTibiaOFM','RightHindFoot'};
    bplate = {chname(1:4),'RightTibiaOFM'};  
    
    jnt=[jnt;jplate];
    oxbone = [oxbone;bplate];
end

if ismember({'RHDF0','RFOF0'},ch)  
    [~,indx]=ismember({'RHDF0'},ch);
    chname = ch{indx};
    
    jplate = {'RightMidFoot','RightHindFoot','RightForeFoot'};
    bplate = {chname(1:4),'RightHindFoot'};   
        
    jnt=[jnt;jplate];    
    oxbone = [oxbone;bplate];
end


if ismember({'RFOF0','RHLX0'},ch)
    [~,indx]=ismember({'RFOF0'},ch);
    chname = ch{indx};

    jplate = {'RightMTP','RightForeFoot','RightHallux'};
    bplate = {chname(1:4),'RightForeFoot'};

    jnt=[jnt;jplate];
    oxbone = [oxbone;bplate];
end

if ismember('RHLX0',ch)
    [~,indx]=ismember({'RHLX0'},ch);
    chname = ch{indx};

    bplate = {chname(1:4),'RightHallux'};
    oxbone = [oxbone;bplate];
end

if ismember({'LTIB0','LHDF0'},ch)
    [~,indx]=ismember({'LTIB0'},ch);
    chname = ch{indx};

    jplate = {'LeftAnkleOFM','LeftTibiaOFM','LeftHindFoot'};
    bplate = {chname(1:4),'LeftTibiaOFM'};

    jnt=[jnt;jplate];
    oxbone = [oxbone;bplate];
end

if ismember({'LHDF0','LFOF0'},ch)
    [~,indx]=ismember({'LHDF0'},ch);
    chname = ch{indx};

    jplate = {'LeftMidFoot','LeftHindFoot','LeftForeFoot'};
    bplate = {chname(1:4),'LeftHindFoot'};

    jnt=[jnt;jplate];
    oxbone = [oxbone;bplate];
end

if ismember({'LFOF0','LHLX0'},ch)
    [~,indx]=ismember({'LFOF0'},ch);
    chname = ch{indx};

    jplate = {'LeftMTP','LeftForeFoot','LeftHallux'};
    bplate = {chname(1:4),'LeftForeFoot'};

    jnt=[jnt;jplate];
    oxbone = [oxbone;bplate];
end

if ismember('LHLX0',ch)
    [~,indx]=ismember({'LHLX0'},ch);
    chname = ch{indx};

    bplate = {chname(1:4),'LeftHallux'};
    oxbone = [oxbone;bplate];
end





