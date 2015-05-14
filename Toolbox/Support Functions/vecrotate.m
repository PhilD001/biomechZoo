function vout = vecrotate(vin,ang,ax)

% VECROTATE rotates a vector any number of degrees about any axis
%
% vout = vecrotate(vin,ang,dim);
%
% this function will rotate a vector ang (degrees) about ax
% ARGUMENTS
%   vin     ...    a n by 3 matrix to rotate
%   ang     ...    number of degrees to rotate (in degrees)
%   ax      ...    axes as a scalar 'x' 'y' or 'z'
%
% Created by JJ Loh


ang = deg2rad(ang);
if length(ang) == 1
    switch ax
        case 'z'
            t = [cos(ang),-sin(ang),0;sin(ang),cos(ang),0;0,0,1];
            vout = vin*t';
        case 'y'
            t = [cos(ang),0,-sin(ang);0,1,0;sin(ang),0,cos(ang)];
            vout = vin*t';
        case 'x'
            t = [1,0,0;0,cos(ang),-sin(ang);0,sin(ang),cos(ang)];
            vout = vin*t';
    end
    
else
    switch ax
        case 'z'
            x = vin(1)*cos(ang)-vin(2)*sin(ang);
            y = vin(1)*sin(ang)+vin(2)*cos(ang);
            z = ones(size(y))*vin(3);                        
            vout = [makecolumn(x),makecolumn(y),makecolumn(z)];
        case 'y'
            x = vin(1)*cos(ang)-vin(3)*sin(ang);
            y = ones(size(x))*vin(2);                        
            z = vin(1)*sin(ang)+vin(3)*cos(ang);
            
            vout = [makecolumn(x),makecolumn(y),makecolumn(z)];                       
        case 'x'
            y = vin(2)*cos(ang)-vin(3)*sin(ang);
            x = ones(size(y))*vin(1);                        
            z = vin(2)*sin(ang)+vin(3)*cos(ang);
            
            vout = [makecolumn(x),makecolumn(y),makecolumn(z)];  
            
    end
end

function r = deg2rad(ang)
r = ang*pi/180;