function [data,dir] = getDir(data)

% updated November 2012
%
% updated Jan 8th
% - compliant with zoosystem v1.1




% USe SACRAL marker to determine posiiton
%
if ~isfield(data,'SACR')
    
    if isfield(data,'SACR_x')
        SACR = [data.SACR_x.line  data.SACR_y.line data.SACR_z.line];
        
    elseif isfield(data,'RPSI')                                     % in cases where SACR
        RPSI = data.RPSI.line;                                  % marker was not used
        LPSI = data.LPSI.line;                                  % it can be computed
        SACR = (RPSI+LPSI)/2;                                   % from RPSI and LPSI
    else
        error('No SACR marker present')
        
    end
    
else
    SACR = data.SACR.line;
end



% Avoid NanNs
%
istart = find(~isnan(SACR(:,1)),1,'first');
iend = find(~isnan(SACR(:,1)),1,'last');

SACR = SACR(istart:iend,:);

% Determine if most of motion is along global X or Y
%
if ~isfield(data.zoosystem,'Freq')
    fsamp = data.zoosystem.Video.Freq;
else
    fsamp = data.zoosystem.Freq;
end
X = abs(SACR(1,1)-SACR(end,1));
Y = abs(SACR(1,2)-SACR(end,2));

if Y > X % moving along Y
    axis = 'J';
    dim = 2;
else     % moving along X
    axis = 'I';
    dim = 1;
    
end

SACR =  mean(deriv_line(SACR(:,dim),fsamp));


if SACR < 0 %
    dir = 'neg'; % negative slope
else
    dir = 'pos';
end

dir = [axis,dir];
data.zoosystem.CompInfo.Direction = dir;