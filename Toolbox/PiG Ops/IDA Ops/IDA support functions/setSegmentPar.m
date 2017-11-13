function [data,body] = setSegmentPar(dim,bone,data,SegmentPar,body)

% [data,body] = SETSEGMENTPAR(dim,bone,data,SegmentPar,body) is standalone function used 
% primarily by kinetics_data


% Revision History
%
% Updated Nov 11th 2013
% - Made standalone for use with other functions on Nov 11th 2013
%
% Updated May 2014
% - Compatible with zoosystem v.1.2
%
% Updated by Philippe C. Dixon Nov 2017
% - Corrected proximal joint for the L/R foot

for i = 1:length(bone(:,1))
    
    d = cell(1,length(dim));
    
    for j = 1:length(dim)
        d{j} = data.([bone{i,1},dim{j}]).line;
    end
    
    bn = bone{i,2};
    
    switch bn
        
        case 'RightHand'
            pjoint = data.RRAO.line;
            djoint = data.RHNO.line;
            com = SegmentPar.Hand.com;
            
        case 'LeftHand'
            pjoint = data.LRAO.line;
            djoint = data.LHNO.line;
            com = SegmentPar.Hand.com;
        
        case 'RightHumerus'
            pjoint = data.RHUP.line;
            djoint = data.RHUO.line;
            com = SegmentPar.Humerus.com;
            
        case 'LeftHumerus'
            pjoint = data.LHUP.line;
            djoint = data.LHUO.line;
            com = SegmentPar.Humerus.com;
            
        case 'RightRadius'
            pjoint = data.RHUO.line;
            djoint = data.RRAO.line;
            com = SegmentPar.Radius.com;
            
        case 'LeftRadius'
            pjoint = data.LHUO.line;
            djoint = data.LRAO.line;
            com = SegmentPar.Radius.com;
            
        case 'Pelvis'
            
            pjoint = data.SACR.line; % garbage data
            
            if isfield(data,'LTRO')
                djoint = data.LTRO.line;  % garbage data
            else
                djoint = data.LTHI.line;  % garbage data
            end
            
            com = SegmentPar.Pelvis.com;
            
        case 'LeftFemur'
            pjoint = data.LFEP.line;
            djoint = data.LFEO.line;
            com = SegmentPar.Femur.com;
            
        case 'LeftTibia'
            pjoint = data.LFEO.line;
            djoint = data.LTIO.line;
            com = SegmentPar.Tibia.com;
            
        case 'LeftFoot'
            pjoint = data.LFOP.line;    % edited by PD Sept 2016 LFOO
            djoint = data.LFOO.line;    % edited by PD Sept 2016 LTOE
            com = SegmentPar.Foot.com;
            
        case 'RightFemur'
            pjoint = data.RFEP.line;
            djoint = data.RFEO.line;
            com = SegmentPar.Femur.com;
            
        case 'RightTibia'
            pjoint = data.RFEO.line;
            djoint = data.RTIO.line;
            com = SegmentPar.Tibia.com;
            
        case 'RightFoot'
            pjoint = data.RFOP.line;   % original was RFOO, this is an error use RFOP (edited by PD Sept 2016)
            djoint = data.RFOO.line;   % original was RTOE,RFOO is same (edited by PD Sept 2016)
            com = SegmentPar.Foot.com;
            
        case 'LeftTibiaOFM'
            pjoint = data.LFEO.line;
            djoint = data.LTIO.line;  % using the same tibia as PIG
            com = SegmentPar.TibiaOFM.com;
            
        case 'LeftHindFoot'
            pjoint = data.LHDF0.line;
            djoint = data.LFOF0.line;
            com = SegmentPar.HindFoot.com;
            
        case 'LeftForeFoot'
            pjoint = data.LFOF0.line;  % please check this
            djoint = data.LHLX.line;
            com = SegmentPar.ForeFoot.com;
            
        case 'RightTibiaOFM'
            pjoint = data.RFEO.line;
            djoint = data.RTIO.line;    % USe the same tibia as PIG
            com = SegmentPar.TibiaOFM.com;
            
        case 'RightHindFoot'
            pjoint = data.RHDF0.line;
            djoint = data.RFOF0.line;
            com = SegmentPar.HindFoot.com;
            
        case 'RightForeFoot'
            pjoint = data.RFOF0.line;  % please check this
            djoint = data.RHLX.line;
            com = SegmentPar.ForeFoot.com;
            
        otherwise
            
            continue
    end
    
    [ort,cm,pjnt,djnt] = getdata(d,pjoint,djoint,com);
    body.(bn).ort =ort;
    body.(bn).prox_end = pjnt/1000;       % output is in m
    body.(bn).dist_end = djnt/1000;       % output is in m
    body.(bn).com = cm/1000;              % output is in m
    
    if ~isfield(data,[(bn),'com'])
        data = addchannel_data(data,[(bn),'com'],cm,'Video');    % add to zoofile
    end
end
