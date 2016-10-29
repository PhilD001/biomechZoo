function data = renameevent_data(data,evt,nevt)

% data = RENAMEEVENT_DATA(data,evt,nevt,fl) will rename events in your data. 
%
% ARGUMENTS
%  data  ...  Zoo data
%  evt   ...  name of existing event as cell array of strings
%  nevt  ...  name of new event as cell array of string
%
% RETURNS
%  data  ... Zoo data with events renamed


% Revision History
%
% Made standalone by Philippe C. Dixon Oct 2016
%
% Updated by Philippe C. Dixon Oct 2016
% -More efficient code used


for i = 1:length(evt)
   [~,ch] = findfield(data,evt{i}); 
   data.(ch).event.(nevt{i})=data.(ch).event.(evt{i});  
   data.(ch).event = rmfield(data.(ch).event, evt{i});
end

% for i = 1:length(ch)
% 
%     if isfield(data.(ch{i}).event,evt)
%         disp(['rename event:',fl]);
%         data.(ch{i}).event.(nevt)=data.(ch{i}).event.(evt);  
%         data.(ch{i}).event = rmfield(data.(ch{i}).event, evt);
%     end
% end