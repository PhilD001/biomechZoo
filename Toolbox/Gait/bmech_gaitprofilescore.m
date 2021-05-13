function turninggait_gaitprofilescoreOGL(fld,cycle,ch, dataset)

% turninggait_gaitprofilescoreOGL(nfld,fld,ch) computes gait variable score (GVS)
% and gait profile score (GPS) based on the OGL database of TD children.
%
% ARGUMENTS
%  fld          ...   folder of subjects to operate on
%  cycle        ...   choice to use simple 'gait cycle' (100%) or 'turning cycle' (162%)
%  ch           ...   channels to use for GPS calculation. Default Baker channels
%  dataset      ...   OGL or turning. Default OGL
%
% NOTES
% - Determination of More/Less affected side is done solely via the
%   straight trials, i.e. if a straight trial shows that the left limb is the
%   MA side, than that information will be added to all turn trial metainfo
%   branch.
% - BelfastPelvis_x is int/ext rotation while BelfastPelvis_z is flex/ext
% Created by Philippe C. Dixon April 17th 2014 based on other
% gaitprofilescore functions



% Set Defaults
%
switch nargin
    
    case 0
        
        fld = uigetfolder;
        cycle = 'gait cycle';
        ch = {'BelfastPelvisAngles_x', 'BelfastPelvisAngles_y','BelfastPelvisAngles_z',...
            'HipAngles_x','HipAngles_y','HipAngles_z','KneeAngles_x','AnkleAngles_x',...
            'FootProgressAngles_z'}';
        dataset = 'OGL';
        
        
    case 1
        
        cycle = 'gait cycle';
        ch = {'BelfastPelvisAngles_x', 'BelfastPelvisAngles_y','BelfastPelvisAngles_z',...
            'HipAngles_x','HipAngles_y','HipAngles_z','KneeAngles_x','AnkleAngles_x',...
            'FootProgressAngles_z'}';
        dataset = 'OGL';
        
    case 2
        
        ch = {'BelfastPelvisAngles_x', 'BelfastPelvisAngles_y','BelfastPelvisAngles_z',...
            'HipAngles_x','HipAngles_y','HipAngles_z','KneeAngles_x','AnkleAngles_x',...
            'FootProgressAngles_z'}';
        dataset = 'OGL';
        
    case 3
        dataset = 'OGL';
end


cd(fld)


% Backwards compatibility
%
if isin(cycle,'GC')
    cycle = 'gait cycle';
elseif isin(cycle,'TC')
    cycle = 'turning cycle';
end


% Extract data subject by subject
%
[~,subs] = extract_filestruct(fld);


%---get normative data----
%
for i = 1:length(subs)
    
    sub = subs{i};
    indx = strfind(sub,slash);
    short_sub = sub(indx(end)+1:end);
    
    fl = engine('path',sub,'extension','zoo');
    
    if ~isempty(fl)
        
        tdata =  zload(fl{1});  % load the first to check age and sex
        [group, ndata] = iddataset(tdata,dataset);
        disp(' ')
        disp(['computing GPS for subject ',short_sub, ' using ',cycle,' for ',group,' age group'])
        
        sidestk = cell(size(fl));
        GPSstk = NaN*ones(size(fl));
        
        for j = 1:length(fl)
            data = zload(fl{j});
            
            if isin(cycle,'gait cycle')
                batchdisplay(fl{j})
                
                if isfield(data.SACR.event,'FSminus1') && isfield(data.SACR.event,'FSapex') && isfield(data.SACR.event,'FSplus1')  && isfield(data.SACR.event,'FSplus2')
                    [GPS_side1,GPS_side2,r] = computegps(data,ndata,ch,cycle,fl{j});
                    data = addgps(data,GPS_side1,GPS_side2,r,cycle);
                    
                    if isin( data.zoosystem.CompInfo.Condition,'Straight')
                        sidestk{j} = data.zoosystem.CompInfo.GC_MoreAffectedSide;
                        GPSstk(j) = data.SACR.event.GC_GPS_diff(2);
                    end
                    save(fl{j},'data');
                else
                    warning('short trial identified')
                    delfile(fl{j})
                end
                
                
            elseif isin(cycle,'turning cycle')
                
                if isfield(data.SACR.event,'FSminus1') && isfield(data.SACR.event,'FOplus1')
                    batchdisplay(fl{j})
                    [GPS_side1,GPS_side2,r,~,GPS_red_side1,GPS_red_side2] = computegps(data,ndata,ch,cycle,fl{j});
                    data = addgps(data,GPS_side1,GPS_side2,r,cycle,GPS_red_side1,GPS_red_side2);
                    save(fl{j},'data');
                else
                    disp('deleting short trials')
                    delfile(fl{j})
                end
                
            else
                error('unknown condition')
            end
            
            
        end
        
        if isin(cycle,'gait cycle')
            checkconsis(sub,sidestk,GPSstk)
        end
        
        
        %     else
        %         rmdir(subs{i})
    end
    
end


function checkconsis(sub,sidestk,GPSstk)

% check consistency amongs straight trials
fl = engine('path',sub,'extension','zoo');

sidestk(cellfun(@isempty,sidestk)) = [];   % That's some hot programming
sides1 = unique(sidestk);

if length(sides1)>1 && nanmean(GPSstk)>1.6
    
    disp('Different sides selected for more affected!')
    
    if isin(sub,'TD')
        
        for d = 1:length(fl)
            delfile(fl{d})
        end
        rmdir(sub)
        
    else
        error('remove bad trial')
    end
    
elseif length(sides1)>1 && nanmean(GPSstk)<1.6
    fix = 'yes';
    disp('small disagreement across sides, picking random side')
    side = sidestk{1}; % this is random
elseif isempty(sides1)
    disp('deleting subject with no straight trials')
    rmdir(sub,'s')
else
    fix = 'no';
    side = sides1{1}; % there is only 1 and it is always the same
    
end


fl = engine('path',sub,'extension','zoo');



for j = 1:length(fl)  % cycle through again correcting turning
    
    data = zload(fl{j});
    
    
    if ~isin(data.zoosystem.CompInfo.Condition,'Straight')
        cside = data.zoosystem.CompInfo.GC_MoreAffectedSide;
        
        if cside ~=side
            batchdisplay(fl{j},'correcting MA limb based on straight')
            data.zoosystem.CompInfo.GC_MoreAffectedSide = sidestk{1};
            save(fl{j},'data');
        end
        
    elseif isin( data.zoosystem.CompInfo.Condition,'Straight') && isin(fix,'yes')
        cside = data.zoosystem.CompInfo.GC_MoreAffectedSide;
        
        if cside ~=side
            batchdisplay(fl{j},'making all straight the same ')
            data.zoosystem.CompInfo.GC_MoreAffectedSide = side;
            save(fl{j},'data');
        end
        
    end
    
    
    
    
end




function data = addgps(data,GPS_side1,GPS_side2,r,cycle,GPS_red_side1,GPS_red_side2)

if nargin==5
    GPS_red_side1 = [];
    GPS_red_side2 = [];
end

%---simple GPS computations
%
gps = nanmean([GPS_side1 GPS_side2]);
gps_diff = abs(GPS_side1-GPS_side2);


% extract info
%
[~,ech] = findfield(data,'FSapex');
ApexFoot = data.zoosystem.CompInfo.ApexFoot;


if isin(cycle,'gait cycle')
    cycle = 'GC';
else
    cycle = 'TC';
end

if isin(cycle,'TC') && isin(ApexFoot,'Left')      % IPSI=Left, CONTRA=RIGHT
    side = {'L','R'};
    
elseif isin(cycle,'TC') && isin(ApexFoot,'Right') % IPSI = Right CONTRA = LEFT
    side = {'R','L'};
    
elseif isin(cycle,'GC')                           % IN GC sides always RIGHT, LEFT
    side = {'R','L'};
else
    error('unknown condition')
end


% Add GPS events
%
% data.(ech).event.([cycle,'_GPS_Ipsi'])   = [1 GPS_side1 0];  % extract Ipsi
% data.(ech).event.([cycle,'_GPS_Contra']) = [1 GPS_side2 0];  % extract Contra

data.(ech).event.([cycle,'_GPS_',side{1}]) = [1 GPS_side1 0];  % OGL always comes out as side1-->R, side2-->L
data.(ech).event.([cycle,'_GPS_',side{2}]) = [1 GPS_side2 0];
data.(ech).event.([cycle,'_GPS_diff'])     = [1 gps_diff 0];
data.(ech).event.([cycle,'_GPS_tot'])      = [1 gps 0];

if ~isempty(GPS_red_side1)
    
    gps_red = nanmean([GPS_red_side1 GPS_red_side2]);
    gps_red_diff = abs(GPS_red_side1-GPS_red_side2);
    
    data.(ech).event.([cycle,'_GPS_red_Ipsi'])   = [1 GPS_red_side1 0];  % extract Ipsi
    data.(ech).event.([cycle,'_GPS_red_Contra']) = [1 GPS_red_side2 0];  % extract Contra
    
    data.(ech).event.([cycle,'_GPS_red_',side{1}]) = [1 GPS_red_side1 0];  % OGL always comes out as side1-->R, side2-->L
    data.(ech).event.([cycle,'_GPS_red_',side{2}]) = [1 GPS_red_side2 0];
    data.(ech).event.([cycle,'_GPS_red_diff'])     = [1 gps_red_diff 0];
    data.(ech).event.([cycle,'_GPS_red_tot'])      = [1 gps_red 0];
    
end

% Add GVS info from r struct
%
rch = fieldnames(r);

if isin(cycle,'GC')
    
    for i = 1:length(rch)
        
        rchn = rch{i};
        under = strfind(rchn,'_');
        dim = rchn(under:end);
        chn = rchn(1:under-1);
        
        if isin(rchn,'RBelfastPelvisAngles_x')
            data.RPLA.event.([cycle,'_GVS_z']) =  r.(rch{i}).event.gvs;
            
        elseif isin(rchn,'RBelfastPelvisAngles_y')
            data.RPLA.event.([cycle,'_GVS_y']) = r.(rch{i}).event.gvs;
            
        elseif  isin(rchn,'RBelfastPelvisAngles_z')
            data.RPLA.event.([cycle,'_GVS_x']) = r.(rch{i}).event.gvs;
            
        elseif  isin(rchn,'RFootProgressAngles_z')
            data.RFPA.event.([cycle,'_GVS_x']) = r.(rch{i}).event.gvs;
            
        elseif isin(rchn,'LBelfastPelvisAngles_x')
            data.LPLA.event.([cycle,'_GVS_z']) =  r.(rch{i}).event.gvs;
            
        elseif isin(rchn,'LBelfastPelvisAngles_y')
            data.LPLA.event.([cycle,'_GVS_y']) = r.(rch{i}).event.gvs;
            
        elseif  isin(rchn,'LBelfastPelvisAngles_z')
            data.LPLA.event.([cycle,'_GVS_x']) = r.(rch{i}).event.gvs;
            
        elseif  isin(rchn,'LFootProgressAngles_z')
            data.LFPA.event.([cycle,'_GVS_x']) = r.(rch{i}).event.gvs;
            
        elseif isfield(data,chn)
            data.(chn).event.([cycle,'_GVS',dim]) = r.(rch{i}).event.gvs;
            
        else
            error('missing field for GVS event')
            
        end
    end
    
else
    
    for i = 1:length(rch)
        
        rchn = rch{i};
        
        if isin(rchn,'Ipsi')
            tmp = strrep(rchn,'Ipsi',side{1});
            r.(tmp) = r.(rchn);
            r = rmfield(r,rchn);
            
        elseif isin(rchn,'Contra')
            tmp = strrep(rchn,'Contra',side{2});
            r.(tmp) = r.(rchn);
            r = rmfield(r,rchn);
        end
        
        under = strfind(tmp,'_');
        dim = tmp(under:end);
        chn = tmp(1:under-1);
        
        if isin(tmp,'RBelfastPelvisAngles_x')
            data.RPLA.event.([cycle,'_GVS_z']) = r.(tmp).event.gvs;
            
        elseif isin(tmp,'RBelfastPelvisAngles_y')
            data.RPLA.event.([cycle,'_GVS_y']) = r.(tmp).event.gvs;
            
        elseif  isin(tmp,'RBelfastPelvisAngles_z')
            data.RPLA.event.([cycle,'_GVS_x']) = r.(tmp).event.gvs;
            
        elseif isin(tmp,'RFootProgressAngles_z')
            data.RFPA.event.([cycle,'_GVS_x']) = r.(tmp).event.gvs;
            
        elseif isin(tmp,'LBelfastPelvisAngles_x')
            data.LPLA.event.([cycle,'_GVS_z']) = r.(tmp).event.gvs;
            
        elseif isin(tmp,'LBelfastPelvisAngles_y')
            data.LPLA.event.([cycle,'_GVS_y']) = r.(tmp).event.gvs;
            
        elseif  isin(tmp,'LBelfastPelvisAngles_z')
            data.LPLA.event.([cycle,'_GVS_x']) = r.(tmp).event.gvs;
            
        elseif isin(tmp,'LFootProgressAngles_z')
            data.LFPA.event.([cycle,'_GVS_x']) = r.(tmp).event.gvs;
            
        elseif isfield(data,chn)
            data.(chn).event.([cycle,'_GVS',dim]) = r.(tmp).event.gvs;
            
        else
            error('missing field for GVS event')
        end
        
    end
end


% Add info about More affected side
%
if GPS_side1 > GPS_side2
    data.zoosystem.CompInfo.([cycle,'_MoreAffectedSide']) = side{1};
else
    data.zoosystem.CompInfo.([cycle,'_MoreAffectedSide']) = side{2};
end






function [group, ndata] = iddataset(data,dataset)

if isin(dataset,'OGL')
    group = findgpsgroup(data);
    ndata = GetOGLnormGPS(group);
    
elseif isin(dataset,'Turning')
    ndata = GetTurningnormGPS;
    group = 'Turning';
else
    error('dataset not identified')
end








