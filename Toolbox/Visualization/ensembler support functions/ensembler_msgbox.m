function ensembler_msgbox(fld,msg)

% ENSEMBLER_MSGBOX(fld,msg) creates message box at bottom of figure


% clears msg box for next run
%
if nargin==1
    msg = '';
end

% Find current directory if it exists
%
if isempty(fld) && isempty(msg)
    sfld = 'not selected';
else
    indx = strfind(fld,filesep);
    
    if length(indx)<=4
        sfld = fld;
    else
        sfld = fld(indx(end-4):end);
    end
    
end


% additional messages
%
mbox_hnd = findobj('tag','messagebox');

if ~isempty(mbox_hnd)
    
    fsize = get(gcf,'position');
    fsize = fsize(3);
    
    % shrink line 2 message (rmsg)
    count = 1;
    while true
        rmsg = ['working directory: ',sfld];
        set(mbox_hnd,'string',{'Messages:';rmsg;msg} )

        tsize = get(mbox_hnd,'extent');
        if length(tsize) < 3
            break
        end
        tsize = tsize(3);
        
        if count > 50
            break
        elseif ceil(tsize) > fsize
            sfld = concatPrompt(sfld);
            count = count+1;
        else
            break
        end
    end
    
    % do it again for msg if required
    %     if length(msg) > length(sfld)
    %           msg = concatPrompt(msg,length(sfld));
    %           set(mbox_hnd,'string',{'Messages:';rmsg;msg} )
    %     end
        
        
end