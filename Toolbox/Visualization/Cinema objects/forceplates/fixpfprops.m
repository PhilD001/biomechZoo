function fixpfprops

% forceplate2.prop in the original JJ set have some strange behavior
% with new zoo files. Since foreplate1.prop is okay. We make a copy of 
% forceplate1.prop, rename it as forceplate2.prop and run this file to
% change its id from '1' to '2'. The other properties don't matter as they
% will be filled in with the correct data once a file is loaded

d = which('director'); % returns path to ensemlber
path = pathname(d) ;  % local folder where director resides

f2 = 'forceplate2.prop';
f3 = 'forceplate3.prop';

% fix fp2
t = load([path,'Cinema objects',slash,'forceplates',slash,f2],'-mat');
object = t.object;
object.id = '2';

save([path,'Cinema objects',slash,'forceplates',slash,f2],'object')


% fix fp3
t = load([path,'Cinema objects',slash,'forceplates',slash,f3],'-mat');
object = t.object;
object.id = '3';

save([path,'Cinema objects',slash,'forceplates',slash,f3],'object')
