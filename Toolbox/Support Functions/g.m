function r=g(city)

% r=G(city) returns value of acceleration in different cities. You can get really nerdy and
% use a city input if you like
%
% ARGUMENTS
%  city  ...  optional input to specificy gravitational acceleration based
%             on location. Default standard 9.807
%
% RETURNS
%  r     ...  gravitational acceleration constant


% Revision history: 
%
% Updated August 16th 2013 by Philippe C. Dixon
%
% Updated May 2015 by Philippe C. Dixon
% - Help improved
% - extra cities added based on http://en.wikipedia.org/wiki/Gravity_of_Earth


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




if nargin==0
    city = 'standard';
end

switch city
    
    case 'Brussels'
        r = 9.815;
        
    case 'London'
        r = 9.816;
        
    case 'Montreal'
        r=9.809;
           
    case 'Singapore'
        r = 9.776;
               
    case 'standard'
        r = 9.807;
        
    otherwise
        error(['gravitational constant in ', city, ' unknown']) 
        
end


