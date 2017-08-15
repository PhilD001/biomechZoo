function ensembler_msgbox(fld,msg)

% clears msg box for next run


% Find current directory if it exists
%
if isempty(fld)
    sfld = 'not selected';
else
    indx = strfind(fld,filesep);
    
    if length(indx)<=4
        sfld = fld;
    else
        sfld = fld(indx(end-4):end);
    end
    
end


% root message
%
rmsg = ['working directory: ',sfld];


% additional messages
%
if nargin==1
    msg = '';
end

mbox_hnd = findobj('tag','messagebox');

if ~isempty(mbox_hnd)
    set(mbox_hnd,'string',{'Messages:';rmsg;msg} )
end