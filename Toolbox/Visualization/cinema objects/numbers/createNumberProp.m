function createNumberProp(n)

if nargin==0
    n = 1;
end



object.id = num2str(n);

object.vertices = [
     0     0     0
    10     0     0
    10     0     2
     0     0     2
    10     1     0
    10     1     2
     0     1     2
     0     1     0];

object.faces = [
     1     2     3     4
     2     5     6     3
     4     3     6     7
     8     5     6     7
     1     8     7     4
     1     2     5     8];

 
 % save object 
d = which('director'); % returns path to ensemlber
path = pathname(d) ;   % local folder where director resides
s = filesep;           % determine slash direction based on computer type



prp = 'one.prop';

save([path,'Cinema objects',s,'numbers',s,prp],'object')


