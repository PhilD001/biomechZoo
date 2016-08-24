function [data,dir] = getDir(data,ch)

% updated November 2012
%
% updated Jan 8th
% - compliant with zoosystem v1.1
%
% Updated June 2016
% - any channel can be used to determine direction. Not just SACR. It is recommended
%   that a trunk or pelvis marker should be used

if nargin==1
    
    if isfield(data,'LPSI')
        SACR = (data.LPSI.line + data.RPSI.line)/2;
        data = addchannel(data,'SACR',SACR,'video');
    end
    ch = 'SACR';
end



if ~isfield(data.zoosystem,'Freq')
    fsamp = data.zoosystem.Video.Freq;
else
    fsamp = data.zoosystem.Freq;
end

istart = find(~isnan(data.(ch).line(:,1)),1,'first');
iend = find(~isnan(data.(ch).line(:,1)),1,'last');


%FSminus1 = data.CentreOfMass.event.FSminus1(1);
%FSapex = data.CentreOfMass.event.FSapex(1);

SACR =  mean(deriv_line(data.(ch).line(istart:iend,2),fsamp));


if SACR < 0 %
    dir = 'Jneg'; % negative slope
else
    dir = 'Jpos';
end

data.zoosystem.CompInfo.Direction = dir;