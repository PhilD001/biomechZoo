function [r,chn] = findfield(st,evt)

% Searches through all subbranches in a structured array
%
% [r,chn] = findfield(st,evt)
%
% ARGUMENTS
% st        ...  structured array
% evt       ...  subbranch in structured arraw (st)
%
% RETURNS
% r         ...  value of subbranch evt
% ch        ...   name of branch containing evt
%
%
% created by JJ Loh 
%
% Updated by Phil DixonNovember 2011
% - function now also outputs channel containing evt


r = [];
chn = [];
if ~isstruct(st)
    return
else
    
    ch = fieldnames(st);
    indx = find(strcmp(lower(ch),lower(evt)));
    if ~isempty(indx)
        r = getfield(st,ch{indx});
    else
        for i = 1:length(ch)
            r = findfield(getfield(st,ch{i}),evt);
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

 

