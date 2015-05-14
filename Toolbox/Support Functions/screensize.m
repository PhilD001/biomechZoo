function ss = screensize(unt);
sunt = get(0,'units');
set(0,'units',unt);
ss = get(0,'screensize');
set(0,'units',sunt);