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


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.


r = [];
chn = [];
if ~isstruct(data)
    return
else
    
    ch = fieldnames(data);
    indx = find(strcmp(lower(ch),lower(evt)));
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

 

