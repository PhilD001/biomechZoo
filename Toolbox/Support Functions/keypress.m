function keypress

cky = get(gcf,'currentkey');
[md,num] = currentmode;
[tp,hnd] = currentobject;

switch currentperson
case 'cameraman'        
    switch cky
    case 'add'
        cameraman('zoom');
        return
    case 'subtract'
        cameraman('fullscreen');
        return
    case 'tab'
        switchmode;
        return
    end
    switch md
    case 'displacement'
        cameraman('movespacekeypress',num);
    case 'rotation'
        cameraman('rotatespacekeypress',num);
    case 'volume'
        cameraman('resizespacekeypress',num);
    end
    return
end


if isempty(tp)
    return
end
switch tp
case 'actor'
case 'bargraph'
    switch md
    case 'displacement'
        bargraphfxn('local move',cky);
    case 'rotation'
        bargraphfxn('local rotation',cky);
    case 'volume'
        bargraphfxn('increment face',cky);
    end
end