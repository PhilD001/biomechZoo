function m=magnitude(r)

% m = MAGNITUDE(r) takes the magnitude of a signal
%
% ARGUMENTS
%  r       ....     n x 3 signal
%  
% RETURNS
%  m       ....    magnitude of the signal


% Revision History
%
% Created by JJ Loh 
%
% updated by Phil Dixon june 2010
%  - can accept 1,2,or 3 dimensional data
%
% updated by Phil Dixon august 2012
% - case where we have a column (or row) vector fixed to remove negative values
%
%
% © Part of the Biomechanics Toolbox, Copyright ©2008, 
% Phil Dixon, Montreal, Qc, CANADA

m = makecolumn(r);

[~,col]=size(r);

if col ==1
    m = sqrt(r.*r);
    
elseif col==2
    
    x=r(:,1);
    y=r(:,2);
    
    m=sqrt(x.*x+y.*y);
    
elseif col==3
      
    x=r(:,1);
    y=r(:,2);
    z=r(:,3);
    
    m=sqrt(x.*x+y.*y+z.*z);
    
else
    disp('your vector is not 1,2,or 3 dimensional')
    return
end