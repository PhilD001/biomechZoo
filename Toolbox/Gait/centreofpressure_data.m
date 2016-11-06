function data = centreofpressure_data(data,localOr,globalOr,orientFP,thresh)

% data = CENTREOFPRESSURE_DATA(data,localOr,globalOr,thresh) computes COP in global
% coordinate system for force plates 1,2,3
%
% ARGUMENTS
%  data     ...  Zoo struct containing required channel data
%  localOr  ...  Coordinates of FP origin in local coordinate system
%  globalOr ...  Coordinates of FP origin in global coordinate system
%  orientFP ...  Orientation matrix of FP for tranformation of COP data
%                into global coordinates
%  thresh   ...  Threshold force (N) to compute COP. Default = 20N (Agrees with Vicon)
%
% RETURN
%  data     ...  Zoo struct with centre of pressure data appended
%
% NOTES
% - see http://www.kwon3d.com/theory/grf/cop.html
%
% See also getFPLocalOrigin, getFPGlobalOrigin


% Revision history
%
% Created by Philippe C. Dixon Jan 2008
%
% updated by Philippe C. Dixon May 1st 2013
% - can be used with 3 force plates
%
% Updated by Philippe C. Dixon August 23rd 2013
% - translation of COP from local to global is done in a sloppy fashion. Current code 
%   works for OGL, but probably won't work for other gait lab setups. Check for possible 
%   improvements
%
% Updated August 2015
% - use of FP orientation matrix to transform COP in global. Previous issue
%   fixed!


% Set defaults
%
if nargin == 4
    thresh = 20;
end
  
if isfield(data,'ForceFx1')
    forceSuf = 'ForceF';
    momentSuf = 'MomentM';
else
    forceSuf = 'F';
    momentSuf = 'M';
end


plates =fieldnames(localOr);

% [~,dir] = getDir(data);

for i = 1:length(plates)
    
    ag = globalOr.(plates{i})(1)*1000;                       % global coordinates x
    bg = globalOr.(plates{i})(2)*1000;                       % global coordinates y
    cg = globalOr.(plates{i})(3)*1000;                       % global coordinates z
    
    a = localOr.(plates{i})(1)*1000;                         % local coordinates x
    b = localOr.(plates{i})(2)*1000;                         % local coordinates y
    c = localOr.(plates{i})(3)*1000;                         % local coordinates z
    
    Fx = data.([forceSuf,'x',num2str(i)]).line;              % N
    Fy = data.([forceSuf,'y',num2str(i)]).line;              % N
    Fz = data.([forceSuf,'z',num2str(i)]).line;              % N
    Mx = data.([momentSuf,'x',num2str(i)]).line;             % Nmm
    My = data.([momentSuf,'y',num2str(i)]).line;             % Nmm
    Mz = data.([momentSuf,'z',num2str(i)]).line;             % Nmm
    
    COP = COP_oneplate([Fx Fy Fz],[Mx My Mz],a,b,c,thresh); 
    COP = ctransform_line(COP,gunit,orientFP.(['FP',num2str(i)]));       
   
    COP(:,1) = COP(:,1) + ag;  
    COP(:,2) = COP(:,2) + bg;
    COP(:,3) = COP(:,3) + cg;
    
    COP(isnan(COP)) = 0 ;  
    
    data = addchannel_data(data,['COP',num2str(i)],COP,'Video');
end



% add unit information
%
data.zoosystem.Units.CentreOfPressure = 'mm';


