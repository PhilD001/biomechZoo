function r = longunit(m,comp)

% r = LONGUNIT(m,comp) creates unit vector same size as vector m along dimension of comp
%
% ARGUMENTS
%  m      ...  vector used for sizing
%  comp   ...  direction. 'i','j','k' or 'x', 'y', 'z'
%
% RETURNS
%  r      ...  unit vector size of m
%
% Example
% m = randn(100,1);
% r = longunit(m,'j') returns an 100 x 3 matrix with colums 1 and 3
% containing zeros and column 2 containing ones


% Revision history: 
%
% Created 2012 by Philippe C. Dixon 
%
% Updated May 2015 by Philippe C. Dixon
% - Help improved


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
% 
% Contact: 
% philippe.dixon@gmail.com
%
% Web: 
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis 
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in 
% Aduts and Children. Rome, Italy.Sept 29-Oct 4th 2014. 






%--check size of m---

[r,c] = size(m);

if c > 3
    m = m';
end

[r,c] = size(m);


if c >3
    disp('vector should not have more than 3 dimensions')
end


%--create unit vectors---

Ze = zeros(r,1);
One = ones(r,1);


switch comp
    
    case {'i','x'}
        
        r = [One Ze Ze];
        
    case {'j','y'}
        r = [Ze One Ze];
        
    case {'k','z'}
        r = [Ze Ze One];
        
end