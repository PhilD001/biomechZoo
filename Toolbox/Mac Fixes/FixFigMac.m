function FixFigMac

% FIXFIGMAC attempts tp fix figure patch problems on mac platform
%
% NOTES:
% - Patch objects created in ensembler on windows platforms will not display properly 
%   on mac, this workaroud will allow user to properly display (and edit) graphs 



% Revision History
%
% Created by Philippe C. Dixn March 2015


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt


pch = findobj(gcf,'type','patch');
set(pch,'FaceAlpha',1)

