function ch = rmemptych(ch)

% Just a short cut to this difficult code I can never remember
%
% Created April 3rd 2013

ch(cellfun(@isempty,ch)) = [];   % That's some hot programming
