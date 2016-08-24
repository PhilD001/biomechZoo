function r=g(city)

% value of acceleration in different cities. You can get really nerdy and
% use a city input if you like
%
% Updated August 16th 2013 by Philippe C. Dixon

if nargin==0
    city = 'standard';
end

switch city
    
    case 'Montreal'
        r=9.809;
        
    case 'London'
        r = 9.816;
        
    case 'Singapore'
        r = 9.776;
        
    case 'standard'
        r = 9.807;
        
end