function [f_width,f_height,xwid,ywid,msgbox_space,msg] = ensemble_figsize(nrows,ncols,xwid,ywid,units)

% figures out good ensembler size based on nmber of rows and columns
% and width of each axis
%
%

% set defaults
% 
x_btw_space = 1.8;  % space between axes set at 20% of height/width of axis
y_btw_space = 1.8;  % space between axes set at 20% of height/width of axis

msg = '';
% get screen size
%
set(0,'units',units)
ssize= get(0,'screensize');
s_width = ssize(3);
s_height = ssize(4);

msgbox_space = s_height*0.10; 


% min height and width
%
min_height = s_height*0.5;
min_width = s_width*0.5;

max_height = s_height*0.75;
max_width  = s_width*0.75;

if min_height > s_height
    min_height = s_height*0.9-msgbox_space;
end

if min_width > s_width
    min_width = s_width*0.9;
end


% get height
%
f_height = xwid*nrows*y_btw_space;                     % minimum width no space
%f_height = f_height + (nrows+1)*xwid*btw_space;    % add 10% of ywid for each cols


% get width
%
f_width = ywid*ncols*x_btw_space;                      % minimum width no space
%f_width = f_width + (ncols+1)*ywid;      % add 10% of ywid for each cols



% check if height and width are too small for ensembler GUI elements
%
if f_height < min_height
    f_height = min_height;
end

if f_width < min_width
    f_width = min_width;
end

% check if height and width are too large for the screen (recursively)
% - axes are also forces to be square
% 
if f_height > max_height
    xwid = xwid*0.8;
    ywid = xwid;
    [f_width,f_height,xwid,ywid] = ensemble_figsize(nrows,ncols,xwid,ywid,units);
    msg = 'axes resized to fit screen';
end

if f_width > max_width
    ywid = ywid*0.9;
    xwid = ywid;
    [f_width,f_height,xwid,ywid] = ensemble_figsize(nrows,ncols,xwid,ywid,units);
    msg = 'axes resized to fit screen';
end

a = 1;
