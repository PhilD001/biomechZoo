function [r,chn] = findfield(data,evt)

% [r,chn] = FINDFIELD(st,evt) searches through all subbranches in a structured array
%
% ARGUMENTS
%  data        ...  structured array
%  evt       ...  name of event in structured array as string
%
% RETURNS
%  r         ...  value of subbranch evt
%  ch        ...   name of branch containing evt


% Revision History
%
% created by JJ Loh 
%
% Updated by Philippe C.  Dixon November 2011
% - function now also outputs channel containing evt


r = [];
chn = [];
if ~isstruct(data)
    return
else
    
    ch = fieldnames(data);
    indx = find(strcmpi(ch,evt));
    if ~isempty(indx)
        r = getfield(data,ch{indx});
    else
        for i = 1:length(ch)
            r = findfield(getfield(data,ch{i}),evt);
            if ~isempty(r)               
                 chn = ch{i};
                break
            end
            
        end
    end
    
    
    
end


% JJ Original Code
% function r = findfield(st,evt)
% 
% 
% r = [];
% 
% if ~isstruct(st)
%     return
% else
%     ch = fieldnames(st);
%     indx = find(strcmp(lower(ch),lower(evt)));
%     if ~isempty(indx)
%         r = getfield(st,ch{indx});
%     else
%         for i = 1:length(ch)
%             chn = ch{i};
%             r = findfield(getfield(st,chn),evt);
%             if ~isempty(r)
%                 break
%             end
%         end
%     end
% end

 

