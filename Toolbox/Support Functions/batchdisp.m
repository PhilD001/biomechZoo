function batchdisp(fl,type)

% BATCHDISP(fl,type) produces a shortened display of file path 
%
% ARGUMENTS
% fl    ... name of file being processed
% type  ... message specifyer. Default 'processing'
%
%
% Created June 2013 by Philippe C. Dixon
%
% Updated January 9th 2014 by Philippe C. Dixon
% - simplification of algorithm
%
% Updated Sept 23rd 2014 by Philippe C. Dixon
% - fixed bug when length(indx)==4
%
% Updated Aug 2017 by Philippe C. Dixon
% - Support for ensembler: if original caller function is ensembler, then
%   disp will be pushed to ensembler message window

if nargin==1
    type = 'processing';
end


if isin(type,'copying')
    eword = ' from: ';
elseif isempty(fl)
    eword = '';
else
    eword = ' for: ';
end

s = filesep; 
indx = strfind(fl,s);

if length(indx)<=4
    fl_cat = fl;
else
    fl_cat = fl(indx(end-4):end);
end

msg = [type,eword,fl_cat];


% check if ensembler is the original caller function
%
ST = dbstack;
count = 1;

while count <= length(ST)
    process = ST(count).name;
    
    if strcmp(process,'ensembler')
        break
    else
        process = '';
        count = count+1;
    end
    
end

if isempty(process)
    disp(msg)
else
    ensembler_msgbox(pwd,msg)
    pause(1e-10)
end
