function loaddata(fld,figs)

% LOADDATA(fld,figs) loads line and event data into ensembler


% Updated by Philippe C. Dixon Sept 2016
% - edited for faster reading


settings.string = '\diamondsuit';
settings.verticalalignment = 'middle';
settings.horizontalalignment = 'center';
settings.FontSize = 14;
settings.color = [1 0 0];


fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    
    data = zload(fl{i});                     % load zoo data
    fig = findfigure(fl{i},figs);            % find in which figure it belongs
    
    batchdisplay(fl{i},'loading');           % display loading info to command window
%     pmt = findobj(fig,'tag','prompt');     % get the figure prompt
%     set(pmt,'string',fl_cat)               % write to figure prompt
    
    createlines(fig,data,fl{i},settings);             % draw line
end


% pmt = findobj('tag','prompt');             % clear prompt
% for i = 1:length(pmt)
%     set(pmt,'string','')
% end


% function fl_cat = batchdisplay(fl,type)
% 
% 
% 
% if nargin==1
%     type = 'processing';
% end
% 
% s = filesep; 
% indx = strfind(fl,s);
% 
% if length(indx)<=4
%     fl_cat = fl;
% else
%     fl_cat = fl(indx(end-4):end);
% end


% disp([type,' for: ',fl_cat])
