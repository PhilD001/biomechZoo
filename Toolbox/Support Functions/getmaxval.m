function [maxval,temp,mult] = getmaxval(fld,ch,alpha,ax,nboots,check)

% getmaxval automatically checks all axes for maxdifference between conditons for later graphing
%
%
% ARGUMENTS
% fld          ...   directory where data resides
% ch           ...   channel of zoo file to investigate (string)
% ax           ...   axis handle
%
% RETURNS
% maxval       ...   maxval of all differences for color bar legend
%
%
%
%
% Created July 29th 2013 by Philippe C. Dixon
%
% Updatec October 23rd 2013
% - conditions can handle the '+' identifier in ensembler






%---EXTRACT DATA INFORMATION------------------------------------------------------------
%
fl = engine('path',fld,'extension','zoo');
ln = findobj(ax,'type','line');

cons = cell(1,length(ln));
for i = 1:length(ln)
    
    if ~isempty(get(ln(i),'Tag')) && ~isin(get(ln(i),'Tag'),'hline')
        r =  get(ln(i),'Tag');
        
%         if isin(r,'+')
%             indx = strfind(r,'+');
%             r = r(indx+1:end);
%         end
        
        cons{i} =r;
        
        
        
    end
end

cons = sort(cons);


%---CREATE R STRUCT-----------------------------------------------------------------------
%
[temp,cons] = grouplines(fld,cons,ch);

%---COMPUTE MAXVAL---------------------------------------------------
%
[~,maxval,mult] = computecolorbars(temp,cons,ch,fl,nboots,alpha,check,'no disp');


%======EMBEDDED FUNCTIONS====================================================================






function  [temp,ncons] = grouplines(fld,cons,ch)


temp = struct;


ncons = cell(size(cons));

for c = 1:length(cons)
    
    con = cons{c};
    stk = [];
    
    if isin(con,'+')
        
        indx = strfind(con,'+');
        part1 = con(1:indx-1);
        part2 = con(indx+1:end);
        
        con = [part1,'_and_',part2];
        
        fl1 = engine('path',fld,'extension','zoo','search',part1);
        fl2 = engine('path',fld,'extension','zoo','search',part2);
        
        fl = intersect(fl1,fl2);
        
    else
        fl = engine('path',fld,'extension','zoo','search path',con);
        
    end
    
    
    for i = 1:length(fl)
        
            data = zload(fl{i});
            plate = data.(ch).line';
            stk = [stk; plate];
            
    end
    
    [rows,~] = size(stk);
    temp.(ch).(con).lines = stk;
    temp.(ch).(con).nlines = rows;
    
    ncons{c} = con;
end
% end






