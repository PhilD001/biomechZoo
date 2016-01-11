

function id =blanknorm(type)

close all

if isin(computer,'MACI64')
    disp('using default settings for MacBook pro laptop')
    
    xwid =1.5;
    ywid = 1.5;
    xspace = 0.8;
    yspace = 0.8;
    fw = 12;
    fh = 10;
    
else
    disp('using default for PC')
    
    xwid =1.2;
    ywid = 1.2;
    xspace = 0.8;
    yspace = 0.5;
    fw = 8;
    fh = 8;
    
end



switch type
    
    case 'Schwartz Kinematics'
        
        startup_ensembler('NormData',3,4,xwid,ywid,xspace,yspace,fw,fh)
        
        % list =  {'APelvicRotation_IntExt','AHip_IntExt','AKnee_IntExt','AFootProgress_IntExt',...
        %             'APelvicObliquity_UpDn','AHip_AddAbd','AKnee_AddAbd','',...
        %             'APelvicTilt_AntPost','AHip_FlexExt','AKnee_FlexExt','AAnkle_DfPf'};
        
        list =  {'AAnkle_DfPf', '' ,'AFootProgress_IntExt',...
            'AKnee_FlexExt','AKnee_AddAbd','AKnee_IntExt',...
            'AHip_FlexExt','AHip_AddAbd','AHip_IntExt',...
            'APelvicTilt_AntPost','APelvicObliquity_UpDn','APelvicRotation_IntExt'};
        
        id = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','','(h)','(i)','(j)','(k)','(l)'};
        
        
        
    case 'Schwartz Kinetics'
        
        startup_ensembler('NormData',3,3,xwid,ywid,xspace,yspace,fw,fh)
        
        list = {'MAnkle_DfPf',' ','PAnkle','MKnee_FlexExt','MKnee_AddAbd','PKnee',...
            'MHip_FlexExt','MHip_AddAbd','PHip'};
        
        id = {'(a)','(b)','(c)','(d)','(e)','','(f)','(g)','(h)'};
        
        
    case 'Dixon GRF'
        
        startup_ensembler('NormData',2,3,xwid,ywid,xspace,yspace,fw,fh)
        
        list = {'F_v',' ','F_ap',' ','F_ml','T_z'};
        
        id  = [];
        
    case 'Schwartz EMG'
        
        startup_ensembler('NormData',2,3,xwid,ywid,xspace,yspace,fw,fh)
        
        list = {'MHamstringsLat',' ','MHamstringsMed','MGastrocnemiusMed','MRectusFem','MTibialisAnt'};
        
    case 'OFM Kinematics'
        
        startup_ensembler('NormData',3,3,xwid,ywid,xspace,yspace,fw,fh)
        
        list = {'HXFFA_x','','','FFHFA_x','FFHFA_y','FFHFA_z','HFTBA_x','HFTBA_y','HFTBA_z'};
        
        id = {'(a)','(b)','(c)','(d)','(e)','','(f)','(g)'};
        
        
    case 'OFM Kinetics'
        list ={};
end




figs = findobj('type','figure');

for j = 1:length(figs)
    
    ax = findobj(figs(j),'type','axes');
    
    for i = 1:length(list)
        txt = get(ax(i),'title');
        set(ax(i),'tag',list{i});
        set(txt,'string',list{i})
    end
    
    dax = findobj(figs(j),'type','axes','tag','3 5');
    delete(dax)
    
end


