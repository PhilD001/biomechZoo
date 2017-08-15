function vout = vecrotate(vin,ang,ax)

% vout = VECROTATE(vin,ang,ax) rotates a vector any number of degrees about any axis
%
% ARGUMENTS
%  vin     ...    n x 3 matrix to rotate
%  ang     ...    Angular rotation (in degrees)
%  ax      ...    Axes to rotate about (string): 'x','y','z' or 'i','j','k'
%
% RETURN
%  vout    ...    Rotated n x 3 matrix
%
% See also ctransform

% Created by JJ Loh 2006 or earlier
%
% Updated by Philippe C. Dixon July 2016
% - user can also input 'i','j','k' as axes


ang = deg2rad(ang);
if length(ang) == 1
    switch ax
        case {'k','z'}
            t = [cos(ang),-sin(ang),0;sin(ang),cos(ang),0;0,0,1];
            vout = vin*t';
        case {'j','y'}
            t = [cos(ang),0,-sin(ang);0,1,0;sin(ang),0,cos(ang)];
            vout = vin*t';
        case {'i','x'}
            t = [1,0,0;0,cos(ang),-sin(ang);0,sin(ang),cos(ang)];
            vout = vin*t';
    end
    
else
    switch ax
        case {'k','z'}
            x = vin(1)*cos(ang)-vin(2)*sin(ang);
            y = vin(1)*sin(ang)+vin(2)*cos(ang);
            z = ones(size(y))*vin(3);                        
            vout = [makecolumn(x),makecolumn(y),makecolumn(z)];
        case {'j','y'}
            x = vin(1)*cos(ang)-vin(3)*sin(ang);
            y = ones(size(x))*vin(2);                        
            z = vin(1)*sin(ang)+vin(3)*cos(ang);
            
            vout = [makecolumn(x),makecolumn(y),makecolumn(z)];                       
        case {'i','x'}
            y = vin(2)*cos(ang)-vin(3)*sin(ang);
            x = ones(size(y))*vin(1);                        
            z = vin(2)*sin(ang)+vin(3)*cos(ang);
            
            vout = [makecolumn(x),makecolumn(y),makecolumn(z)];  
            
    end
end

