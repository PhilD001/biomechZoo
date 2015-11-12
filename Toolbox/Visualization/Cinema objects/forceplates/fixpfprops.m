function fixpfprops

% forceplate2.prop in the original JJ set have some strange behavior
% with new zoo files. Since foreplate1.prop is okay. We make a copy of 
% forceplate1.prop, rename it as forceplate2.prop and run this file to
% change its id from '1' to '2'. The other properties don't matter as they
% will be filled in with the correct data once a file is loaded

d = which('director'); % returns path to ensemlber
path = pathname(d) ;  % local folder where director resides


% fix force plates

for i = 2:9
    
    fp = ['forceplate',num2str(i),'.prop'];
    
    t = load([path,'Cinema objects',slash,'forceplates',slash,fp],'-mat');
    object = t.object;
    object.id = num2str(i);
    
    save([path,'Cinema objects',slash,'forceplates',slash,fp],'object')
    
end
