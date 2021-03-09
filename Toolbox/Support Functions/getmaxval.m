function [maxval,temp,mult] = getmaxval(fld,ch,alpha,ax,nboots,check,cohen)

% getmaxval automatically checks all axes for maxdifference between conditons for later graphing
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
        cons{i} =r;
    end
end

cons = sort(cons);


%---CREATE R STRUCT-----------------------------------------------------------------------
%
[temp,cons] = grouplines(fld,cons,ch);

%---COMPUTE MAXVAL---------------------------------------------------
%
[~,maxval,mult,~,~,~,~,~,cohenmaxval] = computecolorbars(temp,cons,ch,fl,nboots,alpha,check,'no disp',cohen);

if cohen
    mult = 1;
    maxval = cohenmaxval;
end

%======EMBEDDED FUNCTIONS====================================================================

function  [temp,ncons] = grouplines(fld,cons,ch)


temp = struct;


ncons = cell(size(cons));

for c = 1:length(cons)
    
    con = cons{c};
    stk = [];
    
    nplus = strfind(con,'+');
    
    if length(nplus)==1
            
        indx = strfind(con,'+');
        part1 = con(1:indx-1);
        part2 = con(indx+1:end);
        
        con = [part1,'_and_',part2];
        
        fl1 = engine('path',fld,'extension','zoo','search path',part1);
        fl2 = engine('path',fld,'extension','zoo','search path',part2);
        
        fl = intersect(fl1,fl2);
        
    elseif length(nplus)==2
        indx = strfind(con,'+');
        part1 = con(1:indx(1)-1);
        part2 = con(indx(1)+1:indx(2)-1);
        part3 = con(indx(2)+1:end);
        
        con = [part1,'_and_',part2,'_and_',part3];
        
        fl1 = engine('path',fld,'extension','zoo','search path',part1);
        fl2 = engine('path',fld,'extension','zoo','search path',part2);
        fl3 = engine('path',fld,'extension','zoo','search path',part3);

        fl = intersect(fl1,fl2);
        fl = intersect(fl,fl3);
    else
        fl = engine('path',fld,'extension','zoo','search path',con);
        
    end
    
    
    for i = 1:length(fl)
        
            data = zload(fl{i});
            
            if ~isfield(data,ch)
                batchdisp(fl{i},'channel does not exist')
            end
            
            plate = data.(ch).line';
            stk = [stk; plate];
            
    end
    
    [rows,~] = size(stk);
    temp.(ch).(con).lines = stk;
    temp.(ch).(con).nlines = rows;
    
    ncons{c} = con;
end
% end






