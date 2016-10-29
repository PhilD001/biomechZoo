function P = getFPLocalOriginDirector(zdata)

% P = GetFPLocalOrigin(zdata) extracts local origin from zdata.
%
%
% created by Philipe C. Dixon August 15th 2013
%
% Updated by Philipe C. DixonSept 15th 2015
% - returns warning if force plates cannot be rendered
% - unlimited number of force plates can be loaded

% - For oxford gait lab, the output of this function should be
%
% P.p1 = [0.0003302	0.0002286	0.04034];
% P.p2 = [0.001397	-0.0000254	0.03757];
% P.p3 = [0.0000508	-0.001473	0.03873];


r =  zdata.zoosystem.Analog.FPlates.LOCALORIGIN; % c3d file contains this info
P = struct;

if ~isempty(r)
    
    [~,nfps] = size(r);
    
    
    for i = 1:nfps
        P.(['p',num2str(i)]) = (r(:,i)/1000)' ;
    end
    
else
    disp('WARNING: Force plate locations unknown, cannot render')
    
end