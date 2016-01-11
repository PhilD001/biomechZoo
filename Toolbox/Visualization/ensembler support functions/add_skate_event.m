

function add_skate_event(ch,num,type)

h=datacursormode;
set(h,'DisplayStyle','window','Enable','on','SnapToData','on')

hnd = gcf;
pause
% setWindowOnTop(hnd,'true')

hnd = gcf;
dcm_obj=datacursormode(hnd);
info_struct = getCursorInfo(dcm_obj);
position = info_struct.Position;
ln = info_struct.Target;


fl = get(ln,'UserData');
data = load(fl,'-mat');
data = data.data;

switch type
    
    case 'peak'
        zone = data.(ch).line(position(1)-3:position(1)+3);
        [m,indx] = max(zone);
        position =[position(1)-3+indx-2 m];
        
    case 'start'
        if position(1)>4
            zone = data.(ch).line(position(1)-3:position(1)+3);
            [m,indx] = min(zone);
            position =[position(1)-3+indx-2 m];
        else
            zone =  data.(ch).line(1:position(1)+3);
            [m,indx] = min(zone);
            position =[position(1)+indx-2 m];
        end
        
    case 'end'
        l = length(data.(ch).line);
        if position(1)<= l-3
            zone = data.(ch).line(position(1)-3:position(1)+3);
            [m,indx] = min(zone);
            position =[position(1)-3+indx-2 m];
        end
        
    case 'min'
        zone = data.(ch).line(position(1)-3:position(1)+3);
        [m,indx] = min(zone);
        position =[position(1)-3+indx-2 m];
        
end

data.(ch).event.([type(1),num2str(num)]) = [position(1) position(2) 0];
save(fl,'data');

disp('event tagged')
datacursormode off
% setWindowOnTop(hnd,'false')