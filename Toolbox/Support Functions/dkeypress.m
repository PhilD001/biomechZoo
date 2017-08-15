function dkeypress


cky = get(gcf,'currentkey');
[md,num] = currentunits;
[tp,hnd] = currentobject;
if isglobalkey(cky)
    return
end


switch currentperson
    case 'cameraman'
        r = cameraman('keypress');
        
        if r
            return
        end
                
end
        

if isempty(tp)
    return
end

switch tp
    case 'graph'
        switch cky
            case 'delete'
                delete(hnd)
                set(finddobj('current object'),'string','');
                return
        end
        switch md
            case 'volume'
                grips('resize graph',cky);
        end
    case 'image'
        switch md
            case 'volume'
                grips('resize graph',cky);
        end
    case 'internal image'
        switch cky
            case 'delete'
                delete(hnd)
                set(finddobj('current object'),'string','');
                return
        end
        switch md
            case 'displacement'
                grips('move iimage',cky);
        end
    case 'accessory'
        switch cky
            case 'delete'
                delete(hnd)
                set(finddobj('current object'),'string','');
                return
            case 'c'
                accessoryfxn('copy',hnd);
        end
        switch md
            case 'volume'
                accessoryfxn('resize',cky);
            case 'displacement'
                accessoryfxn('displacement',cky);
            case 'rotation'
                accessoryfxn('rotation',cky);
        end
    case 'special object'
        specialobject('keypress',hnd,cky);
    case 'tool'
        sculpttool('keypress',hnd);
    case 'costume'
        costume('keypress');
    case 'props'
        props('keypress',hnd);
    case 'prop marker'
        props('keypress',hnd);
end


function r = isglobalkey(cky)
r = 1;
switch cky
    case 'rightarrow'
        switchmode;
    case 'leftarrow'
        switchmode('reverse');
    case 'uparrow'
        modevalue('increase');
    case 'downarrow'
        modevalue('decrease');
    case 'pageup'
        director('next mark');
    case 'pagedown'
        director('prev mark');
    case 'numpad8'
        cameraman('keypress');
    case 'numpad2'
        cameraman('keypress');
    case 'numpad4'
        cameraman('keypress');
    case 'numpad6'
        cameraman('keypress');
    case 'numpad5'
        cameraman('keypress');
    otherwise
        r = 0;
end


function modevalue(action)

hnd = finddobj('units');
ud = get(hnd,'userdata');
switch action
    case 'increase'
        ud = ud+.1;
    case 'decrease'
        ud = ud-.1;
end
str = get(hnd,'string');
indx = findstr(str,' ');
str = [num2str(ud,'%2.2f'),str(indx:end)];
set(hnd,'userdata',ud,'string',str);