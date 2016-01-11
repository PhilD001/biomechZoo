function normdata(type)

%--To plot only norm data from scratch
%
axes = findobj(gcf,'type','axes');
tax = get(axes(1),'Children'); %

if isempty(tax)
    id = blanknorm(type);
end


%----find normative figure data
%
sl = slash;
root = which('ensembler');
indx = strfind(root,sl);
nroot = root(1:indx(end-1)-1);
n = [nroot,sl,'Gait',sl,'Walking norm data',sl];

col =[.8 .8 .8];

speed = 'Free'; % for Scwartz only

figs = findobj('type','figure');

for j = 1:length(figs)
    
    figure(figs(j))
    name = get(gcf,'Name');
    axes = findobj(gcf,'type','axes');
    
    switch type
        
        case 'Schwartz Kinematics'
            
            n = [n,'Schwartz',sl];
            foot_off = 59;
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag,'APelvicTilt_AntPost')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Sagittal Angles (deg)','Post (-)  Ant (+)'})
                    title({'Pelvis',' '})
                    
                elseif isin(tag,'AHip_FlexExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Ext (-)   Flex (+)')
                    title({'Hip',''})
                    
                elseif  isin(tag,'AKnee_FlexExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Ext (-)  Flex (+)')
                    title({'Knee',''})
                    
                elseif  isin(tag,'AAnkle_DfPf')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Pla (-) Dor(+)')
                    title({'Ankle',' '})
                    
                    
                elseif isin(tag,'APelvicObliquity_UpDn')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Coronal Angles (deg)','Down (-) Up (+)'})
                    title('')
                    
                elseif isin(tag,'APelvicRotation_IntExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Transverse Angles (deg)','Ext Rot (-)  Int Rot (+)'})
                    title('')
                    
                    
                    
                elseif isin(tag,'AHip_AddAbd')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Abd (-)   Add (+)')
                    title('')
                    
                elseif isin(tag,'AHip_IntExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Ext Rot (-)  Int Rot (+)')
                    title('')
                    
                    
                    
                elseif  isin(tag,'AKnee_AddAbd')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Abd (-)   Add (+)')
                    title('')
                    
                elseif  isin(tag,'AKnee_IntExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Ext Rot (-)  Int Rot (+)')
                    title('')
                    
                    
                    
                elseif  isin(tag,'AFootProgress_IntExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Foot Progress Angle (deg)';'Ext Rot (-)  Int Rot (+)'})
                    title('')
                    
                else
                    continue
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
                     
        case 'Schwartz Kinetics'
            
            n = [n,'Schwartz',sl];
            foot_off = 59;
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag,'MHip_FlexExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Moment (Nm/kg)';'Flex (-)   Ext (+)'})
                    title({'Hip',''})
                    
                elseif  isin(tag,'MKnee_FlexExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Flex (-)  Ext (+)')
                    title({'Knee',''})
                    
                elseif  isin(tag,'MAnkle_DfPf')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Dor (-) Pla (+)')
                    title({'Ankle',''})
                    
                elseif isin(tag,'MHip_AddAbd')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Moment (Nm/kg)','Add (-)   Abd (+)'})
                    title('')
                    
                elseif  isin(tag,'MKnee_AddAbd')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Add (-)   Abd (+)')
                    title('')
                    
                elseif  isin(tag,'PHip')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Power (W/kg)';'Abs (-)  Gen (+)'})
                    title(' ')
                    
                elseif  isin(tag,'PKnee')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Abs (-)  Gen (+)')
                    title('')
                    
                elseif  isin(tag,'PAnk')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Abs (-)  Gen (+)')
                    title('')
                    
                    
                    
                else
                    continue
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
                       
        case 'Dixon GRF'
            
            n = [n,'Dixon2010GRF',sl];
            foot_off = 81;   % contralateral FS
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag,'F_ml')
                    p =load([n,tag]);
                    p =p.p.(tag);
                    title('')
                    ylabel('Lat (-)   Med (+)')
                    
                elseif isin(tag,'F_ap')
                    p =load([n,tag]);
                    p =p.p.(tag);
                    ylabel({'GRF (N/kg)';'Pos (-)   Ant(+)'})
                    
                    title('')
                    
                elseif  isin(tag,'F_v')
                    p =load([n,tag]);
                    p =p.p.(tag);
                    ylabel('Up(+)')
                    title('')
                    
                elseif  isin(tag,'T_z')
                    p =load([n,tag]);
                    p =p.p.(tag);
                    ylabel({'Tz','Ext Rot (-)  Int Rot (+)'})
                    title('')
                    
                else
                    continue
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
                     
        case 'Schwartz EMG'
            
            n = [n ,'Schwartz',sl];
            foot_off = 59;
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag,'MRectusFem')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Rect Fem (% Dyn Max)'})
                    title('')
                    
                elseif isin(tag,'MHamstringsLat')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    title('')
                    ylabel('Lat Ham (% Dyn Max)')
                    
                elseif isin(tag,'MHamstringsMed')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Med Ham (% Dyn Max)')
                    title('')
                    
                elseif isin(tag,'MGastrocnemiusMed')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Med Gas (% Dyn Max)')
                    title('')
                    
                elseif isin(tag, 'MTibialisAnt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Tib Ant (% Dyn Max)')
                    title('')
                    
                else
                    
                    continue
                    
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
                       
        case 'PiG GC'   % old case to be updated
            
            n = [n ,'PiG',sl];
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                % PIG lower limbs
                
                if isin(tag,'HPA_x') || isin(tag, 'HipAngles_x')
                    p =load([n,'HipAngles_x']);
                    p =p.HipAngles_x;
                    ylabel({'Hip Angles (deg)';'Flexion (+)'})
                    
                elseif isin(tag,'HPA_y') || isin(tag, 'HipAngles_y')
                    p =load([n,'HipAngles_y']);
                    p =p.HipAngles_y;
                    ylabel('Adduction (+)')
                    
                    
                elseif isin(tag,'HPA_z') || isin(tag, 'HipAngles_z')
                    p =load([n,'HipAngles_z']);
                    p =p.HipAngles_z;
                    ylabel('Internal (+)')
                    
                elseif isin(tag, 'KNA_x') || isin(tag, 'KneeAngles_x')
                    p =load([n,'KneeAngles_x']);
                    p =p.KneeAngles_x;
                    ylabel({'Knee Angles (deg)';'Flexion (+)'})
                    
                    
                elseif isin(tag,'KNA_y') || isin(tag, 'KneeAngles_y')
                    p =load([n,'KneeAngles_y']);
                    p =p.KneeAngles_y;
                    ylabel('Varus (+)')
                    
                    
                elseif isin(tag, 'KNA_z') || isin(tag, 'KneeAngles_z')
                    p =load([n,'KneeAngles_z']);
                    p =p.KneeAngles_z;
                    ylabel('Internal (+)')
                    
                    
                elseif isin(tag, 'ANA_x') || isin(tag, 'AnkleAngles_x')
                    p =load([n,'AnkleAngles_x']);
                    p =p.AnkleAngles_x;
                    
                elseif isin(tag, 'ANA_y') || isin(tag, 'AnkleAngles_y')
                    disp('no normative data')
                    
                    
                elseif isin(tag, 'ANA_z') || isin(tag, 'AnkleAngles_z')
                    disp('no normative data')
                    
                    % ---PIG MOMENTS-----------------
                    
                elseif isin(tag, 'AnkleMoment_x')
                    p =load([n,'AnkleMoment_x']);
                    p =p.AnkleMoment_x;
                    
                elseif isin(tag, 'AnkleMoment_y')
                    disp('no normative data')
                    
                elseif isin(tag, 'AnkleMoment_z')
                    disp('no normative data')
                    
                elseif isin(tag, 'KneeMoment_x')
                    p =load([n,'KneeMoment_x']);
                    p =p.KneeMoment_x;
                    
                elseif isin(tag, 'KneeMoment_y')
                    p =load([n,'KneeMoment_y']);
                    p =p.KneeMoment_y;
                    
                elseif isin(tag, 'KneeMoment_z')
                    disp('no normative data')
                    
                elseif isin(tag, 'HipMoment_x')
                    p =load([n,'HipMoment_x']);
                    p =p.HipMoment_x;
                    
                elseif isin(tag, 'HipMoment_y')
                    p =load([n,'HipMoment_y']);
                    p =p.HipMoment_y;
                    
                    % PIG POWER----------
                    
                elseif isin(tag, 'AnklePower')
                    p =load([n,'AnklePower']);
                    p =p.AnklePower;
                    
                elseif isin(tag, 'KneePower')
                    p =load([n,'KneePower']);
                    p =p.KneePower;
                    
                elseif isin(tag, 'HipPower')
                    p =load([n,'HipPower']);
                    p =p.HipPower;
                    
                else
                    continue
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
                      
        case 'OFM Kinematics'
            
            n = [n ,'OFM',sl];
            foot_off = 59; % assuming value for children from Sc
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag, 'HFTBA_x')
                    p =load([n,tag]);
                    p =p.(tag);
                    ylabel({'Sagittal Angles (deg)','Pla (-)  Dor (+)'})
                    title({'HF/TB',' '})
                    
                elseif isin(tag, 'HFTBA_y')
                    p =load([n,tag]);
                    p =p.(tag);
                    title('')
                    ylabel({'Coronal Angles (deg)','Eve (-)  Inv (+)'})
                    
                elseif isin(tag, 'HFTBA_z')
                    p =load([n,tag]);
                    p =p.(tag);
                    title(' ')
                    ylabel({'Transverse Angles (deg)','Ext (-)  Int (+)'})
                    
                elseif isin(tag, 'FFHFA_x')
                    p =load([n,tag]);
                    p =p.(tag);
                    ylabel('Pla (-)  Dor (+)')
                    title({'FF/HF',''})
                    
                elseif isin(tag, 'FFHFA_y')
                    p =load([n,tag]);
                    p =p.(tag);
                    ylabel('Pro (-)  Sup (+)')
                    title('')
                    
                elseif isin(tag, 'FFHFA_z')
                    p =load([n,tag]);
                    p =p.(tag);
                    ylabel('Abd (-)  Add (+)')
                    title('')
                    
                elseif isin(tag, 'HXFFA_x')
                    p =load([n,tag]);
                    p =p.(tag);
                    ylabel('Pla (-)  Dor (+)')
                    title({'HX/FF',''})
                    
                else
                    
                    continue
                    
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
                
        case 'PIG Stance'  % old case to be updated
            
            % create x vector
            
            a= 0:3.3:100;
            b = fliplr(a);
            x = [a,b]';
            
            n = [n ,'PiG',sl];
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                % PIG lower limb angles
                
                if isin(tag,'HPA_x') || isin(tag, 'HipAngles_x')
                    p =load([n,'HipAngles_x']);
                    p =p.HipAngles_x;
                    
                elseif isin(tag,'HPA_y') || isin(tag, 'HipAngles_y')
                    p =load([n,'HipAngles_y']);
                    p =p.HipAngles_y;
                    
                elseif isin(tag,'HPA_z') || isin(tag, 'HipAngles_z')
                    p =load([n,'HipAngles_z']);
                    p =p.HipAngles_z;
                    
                elseif isin(tag, 'KNA_x') || isin(tag, 'KneeAngles_x')
                    p =load([n,'KneeAngles_x']);
                    p =p.KneeAngles_x;
                    
                elseif isin(tag,'KNA_y') || isin(tag, 'KneeAngles_y')
                    p =load([n,'KneeAngles_y']);
                    p =p.KneeAngles_y;
                    
                elseif isin(tag, 'KNA_z') || isin(tag, 'KneeAngles_z')
                    p =load([n,'KneeAngles_z']);
                    p =p.KneeAngles_z;
                    
                elseif isin(tag, 'ANA_x') || isin(tag, 'AnkleAngles_x')
                    p =load([n,'AnkleAngles_x']);
                    p =p.AnkleAngles_x;
                    
                elseif isin(tag, 'ANA_y') || isin(tag, 'AnkleAngles_y')
                    disp('no normative data')
                    
                elseif isin(tag, 'ANA_z') || isin(tag, 'AnkleAngles_z')
                    disp('no normative data')
                    
                    % PIG MOMENTS------------
                    
                elseif isin(tag, 'AnkleMoment_x')
                    p =load([n,'AnkleMoment_x']);
                    p =p.AnkleMoment_x;
                    
                elseif isin(tag, 'AnkleMoment_y')
                    disp('no normative data')
                    
                    
                elseif isin(tag, 'AnkleMoment_z')
                    disp('no normative data')
                    
                elseif isin(tag, 'KneeMoment_x')
                    p =load([n,'KneeMoment_x']);
                    p =p.KneeMoment_x;
                    
                elseif isin(tag, 'KneeMoment_y')
                    p =load([n,'KneeMoment_y']);
                    
                elseif isin(tag, 'KneeMoment_z')
                    disp('no normative data')
                    
                elseif isin(tag, 'HipMoment_x')
                    p =load([n,'HipMoment_x']);
                    p =p.HipMoment_x;
                    
                elseif isin(tag, 'HipMoment_y')
                    p =load([n,'HipMoment_y']);
                    p =p.HipMoment_y;
                    
                    % PIG POWER----------
                    
                elseif isin(tag, 'AnklePower')
                    p =load([n,'AnklePower']);
                    p =p.AnklePower;
                    
                elseif isin(tag, 'KneePower')
                    p =load([n,'KneePower']);
                    p =p.KneePower;
                    
                elseif isin(tag, 'HipPower')
                    p =load([n,'HipPower']);
                    p =p.HipPower;
                    
                else
                    continue
                end
                
                p.y = normalizeline(p.y,101);
                y1 = p.y(1:31);
                y2=p.y(72:end);
                y = [y1;y2];
                h= patch(x,y,col);
                set(h,'Tag','Norm Data');
                
            end
            
        case 'OFM Stance'   % old case to be updated
            a= 0:3.3:100;
            b = fliplr(a);
            x = [a,b]';
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                %OFM Angles
                
                if isin(tag, 'HFTBA_x')
                    p =load([n,'HFTBA_x']);
                    p =p.HFTBA_x;
                    
                elseif isin(tag, 'HFTBA_y')
                    p =load([n,'HFTBA_y']);
                    p =p.HFTBA_y;
                    
                elseif isin(tag, 'HFTBA_z')
                    p =load([n,'HFTBA_z']);
                    p =p.HFTBA_z;
                    
                elseif isin(tag, 'FFHFA_x')
                    p =load([n,'FFHFA_x']);
                    p=p.FFHFA_x;
                    
                elseif isin(tag, 'FFHFA_y')
                    p =load([n,'FFHFA_y']);
                    p =p.FFHFA_y;
                    
                elseif isin(tag, 'FFHFA_z')
                    p =load([n,'FFHFA_z']);
                    p =p.FFHFA_z;
                    
                elseif isin(tag, 'HXFFA_x')
                    
                    p =load([n,'HXFFA_x']);
                    p =p.HXFFA_x;
                    
                else
                    
                    continue
                    
                end
                
                p.y = normalizeline(p.y,101);
                y1 = p.y(1:31);
                y2=p.y(72:end);
                y = [y1;y2];
                h= patch(x,y,col);
                set(h,'Tag','Norm Data');
                
            end
                       
        case {'Turning CB','Turning PB'}   % reads stored ensemble figures
            
            t = get(axes(1),'Tag');
            
            if isin(t,'Ipsi')
                pre = 'Ipsi';
            elseif isin(t,'Contra')
                pre= 'Contra';
            elseif isin(t,'Turn')
                pre = 'Turn';
                %             elseif isin(t,'L')
                %                 pre = 'Ipsi';
            else
                error('these may not be turning trials')
            end
            
            if isin(cycle,'turning CB')
                band = 'CB';
            else
                band = 'PB';
            end
            
            p =load([n,'TurningGait',sl,pre,band,'.mat']);
            p = p.p;
            
            names = fieldnames(p);
            
            c=1;
            w=1;
            
            while c ==1
                
                if isin(name,names{w})
                    p = p.(names{w});
                    c=0;
                else
                    w=w+1;
                end
                
            end
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag,'HPA_x')
                    x = p.([pre,'HPA_x']).x;
                    y = p.([pre,'HPA_x']).y;
                    
                elseif isin(tag,'HPA_y')
                    x = p.([pre,'HPA_y']).x;
                    y = p.([pre,'HPA_y']).y;
                    
                elseif isin(tag,'HPA_z')
                    x = p.([pre,'HPA_z']).x;
                    y = p.([pre,'HPA_z']).y;
                    
                elseif isin(tag,'KNA_x')
                    x = p.([pre,'KNA_x']).x;
                    y = p.([pre,'KNA_x']).y;
                    
                elseif isin(tag,'KNA_y')
                    x = p.([pre,'KNA_y']).x;
                    y = p.([pre,'KNA_y']).y;
                    
                elseif isin(tag,'KNA_z')
                    x = p.([pre,'KNA_z']).x;
                    y = p.([pre,'KNA_z']).y;
                    
                elseif isin(tag,'HFTBA_x')
                    x = p.([pre,'HFTBA_x']).x;
                    y = p.([pre,'HFTBA_x']).y;
                    
                elseif isin(tag,'HFTBA_y')
                    x = p.([pre,'HFTBA_y']).x;
                    y = p.([pre,'HFTBA_y']).y;
                    
                elseif isin(tag,'HFTBA_z')
                    x = p.([pre,'HFTBA_z']).x;
                    y = p.([pre,'HFTBA_z']).y;
                    
                elseif isin(tag,'FFHFA_x')
                    x = p.([pre,'FFHFA_x']).x;
                    y = p.([pre,'FFHFA_x']).y;
                    
                elseif isin(tag,'FFHFA_y')
                    x = p.([pre,'FFHFA_y']).x;
                    y = p.([pre,'FFHFA_y']).y;
                    
                elseif isin(tag,'FFHFA_z')
                    x = p.([pre,'FFHFA_z']).x;
                    y = p.([pre,'FFHFA_z']).y;
                    
                elseif isin(tag,'HXFFA_x')
                    x = p.([pre,'HXFFA_x']).x;
                    y = p.([pre,'HXFFA_x']).y;
                    
                elseif isin(tag,'HXFFA_y')
                    x = p.([pre,'HXFFA_y']).x;
                    y = p.([pre,'HXFFA_y']).y;
                    
                else
                    error('unidentified channel name')
                end
                
                
                y1 = y(1:length(y)/2);
                y2= y(length(y)/2+1:end);
                y = [y1;y2];
                h= patch(x,y,col);
                set(h,'Tag','Norm Data');
                
            end
    end
    
end


%-final spruce up
%
horline(0,'k')                                              % add horizontal line at 0
verline(foot_off,':k')                                            % add push off for free walking speed

pro = findobj('Tag','prompt');                              % remove prompt box

if ~isempty(pro)
    delete(pro)
end


for i = 1:length(axes)                                      % delete empty axes
    if isempty(get(get(axes(i),'YLabel'),'String'))
        delete(axes(i));
    end
end


pch = findobj('type','patch');                              % fix up patch properties

for j =1:length(pch)
    set(pch(j),'edgecolor','none','facealpha',0.9)
end

tick = 20;
xlim = get(gca,'XLim');                     % set xticks
xticks = xlim(1):tick:xlim(2);

ax = findobj('type','axes');
for i = 1:length(ax)
    set(ax(i),'XTick',xticks);
end

axisid(id)                                                      % add axis ids a,b,c,...
