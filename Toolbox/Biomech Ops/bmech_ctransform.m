function bmech_ctransform(fld,ch,c1, c2)

% BMECH_CTRANSFORM(fld,ch,c1,c2) batch process coordinate transformation
%
% ARGUMENTS
%  fld      ...  Folder to batch process (string). 
%  ch       ...  Channel(s) to operate on (single string or cell array of strings) 
%  c1       ...  original coordinate system (3 x 3 matrix)
%  c2       ...  New coordinate system (3 x 3 matrix). Default, global [1 0 0; 0 1 0; 0 0 1]
%
% See also ctransform_data, ctransform_line, gunit





fl = engine('path',fld,'extension','zoo');
cd(fld)


% Error check
%
if ~iscell(ch)
    ch = {ch};
end

if nargin ==3
    c2 = gunit;
end
    


% Batch process each dynamic trial, but find associated static trial
%
for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'changing coordinate systems')
    data = ctransform_data(data,ch,c1,c2);
    zsave(fl{i},data);
end

