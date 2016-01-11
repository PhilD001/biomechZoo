function coupling_angles(fld)

% COUPLING_ANGLES is a standalone function for ensembler

% Updated by Philippe C. Dixon December 1 2015
% - works with latest engine function
% - cleans up figure

disp(' ')
disp('************** RUNNING COUPLING ANGLE ROUTINE ******************')
disp('*                                                              *')
disp('* - ydata from each axis will be combined into a single graph  *')
disp('*                                                              *')
disp('* - Data must not be ensembled or combined                     *')
disp('* - only 2 axes can be run per session                         *')
disp('* - Function does not work on single trial                     *')
disp('* - Function not tested for processing of event data           *')
disp('*                                                              *')
disp('****************************************************************')

fig = findobj('type','figure');

for i= 1:length(fig)
    
    ax = findobj(fig(i),'type','axes');
    name = get(fig(i),'Name');
    
    if i==1
        ch1 = get(ax(1),'tag');
        ch2 = get(ax(2),'tag'); 
        chns = {ch1,ch2};
     
        a = associatedlg(chns,{'x-axis','y-axis'});
        indx = find(ismember(a,'x-axis')==1);
        
        if indx==4
            ch_x = a{2};
            ch_y = a{1};
        elseif indx==3
            ch_x = a{1};
            ch_y = a{2};
        else
            error('unknown axis choice')
        end
        
    end
    
    lines = findobj(fig(i),'type','line');
    delete(lines);
    
    if isin(name,'+')
        indx = strfind(name,'+');
        name1 =  engine('path',fld,'extension','zoo','search path',name(1:indx-1));
        name2 =  engine('path',fld,'extension','zoo','search path',name(indx+1:end));
        
        fl = intersect(name1,name2);
        
    else
        
        fl = engine('path',fld,'extension','zoo','search path',name);
        
    end
    
    for j = 1:length(fl)
        
        data = zload(fl{j});
        ln = line('parent',ax(1),'xdata',data.(ch_x).line,'ydata',data.(ch_y).line,'userdata',fl{j},...
            'buttondownfcn',get(ax(1),'buttondownfcn'));
                
        evt1 = fieldnames(data.(ch_x).event);
        evt2 = fieldnames(data.(ch_y).event);
        
        evt = [evt1, evt2];
        
        for e = 1:length(evt)
            
            event = findfield(data,evt{e});
            
            if event~=999
                
                chxpos = data.(ch_x).line(event(1));
                chypos = data.(ch_y).line(event(1));
                
                text('parent',ax(1),'position',[chxpos chypos],...
                    'tag',evt{e},'string','\diamondsuit','verticalalignment',...
                    'middle','horizontalalignment','center','color',[1 0 0],...
                    'buttondownfcn',get(ax,'buttondownfcn'),'userdata',ln);
            end
        end
    end
    
    % identify new axes and clean up
    xlabel(ch_x)
    set(get(ax(1),'XLabel'),'String',ch_x)
    set(get(ax(1),'YLabel'),'String',ch_y)
    set(get(ax(1),'Title'),'String','Coupling Angles')

    resize_ensembler
     
end