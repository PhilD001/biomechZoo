function out=teximage(s,varargin)
%TEXIMAGE display a LaTeX string as a bitmap image
%  H = TEXIMAGE(S) creates an image of the LaTeX string S and
%   displays it in the current figure. Click and drag to
%   move the image and use the context menu to change properties.
%   The image handle is returned in H, if specified. If S is a cell
%   array of strings then each is made into a separate image and
%   the resulting handles are returned as a vector. S can also be a
%   symbolic expression (see SYM).
%
%  H = TEXIMAGE(S,PARAM1,VALUE1,PARAM2,VALUE2,...) creates the image
%   with options given by the parameter-value pairs. The argument S
%   can be a string or the image handle H returned by a previous
%   call to TEXIMAGE or a cell array of strings or vector of handles.
%   The legal parameter strings and values are:
%
%    'antialias'        one of the strings 'on' or 'off'
%      antialiasing will produce more readable text on-screen
%      but will sacrifice printout quality (default on)
%
%    'convolution'      an integer
%      the size of the convolution matrix for antialiasing (default 7)
%      smaller numbers will result in sharper text
%
%    'background'       a colorspec
%      specifies the background color (default white) 
%      background color 'none' means no background (requires OpenGL renderer)
%
%    'scale'            a double
%      multiplies the image size by specified scale (default 1)
%
%    'resolution'       a double
%      the font resolution to use (default 600)
%
%    'displaymode'      one of the strings 'math', 'text' or 'none'
%      specifies the TeX display mode to use (default 'math')
%      The 'none' displaymode will put the string S directly into
%      the TeX file without any surrounding $ or $$.
%
%    'rotation'         a multiple of 90
%      rotates the image counterclockwise in degrees (default 0)
%
%    'position'         a 2 element vector 
%      specifies the position of the center of the bitmap on the
%      figure (default [.5 .5])
%
%    'units'            an HG units string ('normalized','inches',...)
%      specifies the units for the position property (default 'normalized')
%
%    'parent'           a figure handle
%      specifies the figure to use (default current figure)
%
%  When the input S is a handle a new TeX string can be specified
%  with the parameter 'texstring'. To get the current parameter
%  value for a given handle call GETAPPDATA with the handle and
%  the name of the parameter. eg,
%    scale = getappdata(h,'scale');
%
%  The default parameter values can be set in R12(or later) by calling 
%  SETPREF. eg, 
%    setpref('teximage','resolution',300);
%    setpref('teximage','background',get(0,'DefaultFigureColor'));
%  and in R11 by modifying STARTUP.M to call setappdata as follows:
%    setappdata(0,'teximage',struct(...
%      'resolution',300,'background',get(0,'DefaultFigureColor'));
%
%  H = TEXIMAGE('-noHG',S,PARAM1,VALUE1,...) generates the bitmap
%  but does not create an HG image object. The bitmap is return in
%  H as a height x width x 3 matrix of doubles.
%
%  Important note: LaTeX must be installed before running this
%  function. To obtain a LaTeX distribution see your system 
%  administrator or go to the web site http://www.tug.org
%  This function was tested with MikTeX on PCs and Web2c7.2 on Unix.
%
%  Examples:
%   h = teximage('\dot{x} = \sqrt{x+1}','scale',2);
%   teximage(h,'antialias','off');
%   h2 = teximage('\lim_{n \rightarrow \infty} \left(1+\frac{1}{n}\right)^n')
%   h3 = teximage('Math $x^2+1$ inline.','displaymode','none');
%
%  See also: TEXT, SYM, LATEX

%  Copyright 2002-2009 The MathWorks, Inc.

%TODO: 
%  better text with transparent backgrounds - need darken/lighten?
%  support arbitrary rotation angles
%  support user-specified tex file template
%  better support on old TeX versions and old MATLAB versions
%  test more PC distributions and add them to the registry query

if isunix
  exe_ext = '';
else
  exe_ext = '.exe';
end
noHG = logical(0);

% first handle the callbacks
if isa(s,'char')
  switch(lower(s))
   case {'startmove','mousemove','endmove','figuremoved'}
    feval(lower(s),varargin{:});
    return;
   case '-nohg'
    noHG = logical(1);
    s = varargin{1};
    varargin(1) = [];
    % note no return
   case '-setup'
    texbin = locateTeX;
    if isequal(texbin,0)
      texbin = promptForTeX(exe_ext);
      if isequal(texbin,0)
	error(['No TeX installed. See www.tug.org for' ...
	       'a list of distributions.']);
      end
    end
    if ~isempty(texbin)
      Lsetpref('teximage','texpath',texbin);
    end
    return;
   case {'increasesize','decreasesize','whitecolor','transparent',...
	'figurecolor','togglealias','sharpentex','blurtex',...
	'rotclockwise','rotcounterclock'}
    docallback(s,varargin{:});
    return;
  end
end

% handle vectorized inputs
if isa(s,'cell') | (ishandle(s) & length(s) > 1)
  iscell = isa(s,'cell');
  y = zeros(1,length(s));
  for n=1:length(s)
    if iscell
      y(n) = teximage(s{n},varargin{:});
    else
      y(n) = teximage(s(n),varargin{:});
    end
  end
  if nargout > 0
    out = y;
  end
  return;
elseif isa(s,'sym') % handle symbolic expressions
  s = latex(s);
end

% get the default values for the options
ishndl = ishandle(s);
antialias =   getdefault(ishndl,s,'antialias','on');
convolution = getdefault(ishndl,s,'convolution',7);
resolution =  getdefault(ishndl,s,'resolution',600);
background =  getdefault(ishndl,s,'background',[1 1 1]);
scale =       getdefault(ishndl,s,'scale',1);
displaymode = getdefault(ishndl,s,'displaymode','math');
rotation =    getdefault(ishndl,s,'rotation',0);
position =    getdefault(ishndl,s,'position',[.5 .5]);
units =       getdefault(ishndl,s,'units','normalized');
parent =      getdefault(ishndl,s,'parent','gcf');
if ishndl
  oldHandle = s;
  s = getappdata(s,'texstring');
end

%process param-value pairs
while length(varargin) > 0
  if isa(varargin{1},'char') & (length(varargin) > 1)
    switch lower(varargin{1})
     case 'antialias'
      antialias = lower(varargin{2});
     case 'convolution'
      convolution = varargin{2};
     case 'resolution'
      resolution = varargin{2};
     case 'background'
      background = varargin{2};
     case 'scale'
      scale = varargin{2};
     case 'displaymode'
      displaymode = lower(varargin{2});
     case 'rotation'
      rotation = varargin{2};
     case 'texstring'
      s = varargin{2};
     case 'position'
      position = varargin{2};
     case 'units'
      units = lower(varargin{2});
     case 'parent'
      parent = varargin{2};
     otherwise
      error(['Unrecognized parameter:' varargin{1} '.']);
    end
  end
  varargin(1:2) = [];
end

if convolution < 1
  convolution = 1;
end
rotation90 = round(rotation/90);

if ishndl & canreusebits(oldHandle,resolution,displaymode,s)
  bits = getappdata(oldHandle,'texbitmap');
else
  olddir = pwd;
  file = tempname;
  cd(tempdir);
  try
    tex(file,s,displaymode,exe_ext);
    dvips(file,resolution,exe_ext);
    bits = ghostscript(file,resolution,exe_ext);
  catch
    delete([file '*']);
    cd(olddir);
    error(deblank(lasterr));
  end
  delete([file '*']);
  cd(olddir);
end
y = makeimage(bits,background,antialias,convolution,rotation90);
if noHG
  out = y;
  return;
end

% make an image in the current figure and set up callbacks
if isa(parent,'char')
  parent = eval(parent);
end
fig = parent;
fpos = convertUnits(get(fig,'units'),get(fig,'position'),'inches');
center = convertUnits(units,[position 10 10],'inches',fpos,'inches');

ys = [size(y,2) size(y,1)] * scale / resolution;
if ishndl
  h = oldHandle;
  ax = get(h,'parent');
  set(ax,'position',[center(1)-ys(1)*.5 center(2)-ys(2)*.5 ys(1) ...
		     ys(2)]);
  set(h,'cdata',y);
  try
    if isequal(background,'none')
      set(h,'alphadata',1-y(:,:,1));
      if ~isequal(get(fig,'renderer'),'opengl')
	set(fig,'renderer','opengl');
      end
    else
      set(h,'alphadata',1);
    end
  end
  set(ax,'xlim',[1 size(y,2)],'ylim',[1 size(y,1)]);
else
  ax = axes('parent',fig,'visible','off',...
	    'handlevis','off','units','inch','tag','teximage_axes');
  set(ax,'position',[center(1)-ys(1)*.5 center(2)-ys(2)*.5 ys(1) ...
		     ys(2)]);
  h = image('cdata',y,'parent',ax,'tag','teximage');
  try
    if isequal(background,'none')
      set(h,'alphadata',1-y(:,:,1));
      if ~isequal(get(fig,'renderer'),'opengl')
	set(fig,'renderer','opengl');
      end
    else
      set(h,'alphadata',1);
    end
  end
  set(ax,'xlim',[1 size(y,2)],'ylim',[1 size(y,1)],...
	 'xtick',[],'ytick',[],'ydir','reverse');
  set(h,'uicontextmenu',makecontextmenu(h));
  set(h,'buttondownfcn','teximage(''startmove'',gcbo)');
  oldResize = get(fig,'resizefcn');
  newResize = 'teximage(''figuremoved'',gcbo);';
  if ~isempty(oldResize) & ~isequal(oldResize,newResize)
    warning('Overwriting existing ResizeFcn property of figure.');
  end
  set(fig,'resizefcn',newResize);
end
setappdata(h,'resolution',resolution);
setappdata(h,'antialias',antialias);
setappdata(h,'convolution',convolution);
setappdata(h,'background',background);
setappdata(h,'scale',scale);
setappdata(h,'displaymode',displaymode);
setappdata(h,'texstring',s);
setappdata(h,'texbitmap',bits);
setappdata(h,'rotation',rotation);
setappdata(h,'position',position);
setappdata(h,'units',units);
setappdata(h,'parent',parent);
setantialiasmenu(h,antialias);
if nargout > 0
  out = h;
end

function tex(file,s,displaymode,exe_ext)
tex_file = [file '.tex'];
tex_fid = fopen (tex_file, 'w');
if (tex_fid < 0)
    error('Unable to create temporary file')
end

% write out the TeX file
fprintf(tex_fid, '%%&latex\n'); % this tells the TeX to use latex.fmt
fprintf(tex_fid, '\\documentclass{minimal}\n');
fprintf(tex_fid, '\\begin{document}\n');
if isequal(displaymode,'math')
  fprintf(tex_fid, '$$');
  fwrite(tex_fid, s);
  fprintf(tex_fid, '$$ \n');
elseif isequal(displaymode,'text')
  fprintf(tex_fid, '$');
  fwrite(tex_fid, s);
  fprintf(tex_fid, '$ \n');
else
  fwrite(tex_fid, s);
  fprintf(tex_fid, '\n');
end
fprintf(tex_fid, '\\end{document}\n');
fclose(tex_fid);

%now run TeX
if Lispref('teximage','texpath')
  texbin = Lgetpref('teximage','texpath');
else
  texbin = locateTeX;
  if isequal(texbin,0)
    error(['Cannot automatically locate TeX installation. ' ...
	   'Run ''teximage -setup'' to manually locate TeX. ']);
  end
  if ~isempty(texbin)
    Lsetpref('teximage','texpath',texbin);
  end
end
[s,r] = run_system_cmd(['echo X | "' fullfile(texbin,['tex' exe_ext]) ...
                    '" "' tex_file '"']);
if ~exist([file '.dvi'])
  ind1 = findstr('!',r);
  if ~isempty(ind1)
    ind2 = findstr(sprintf('\n'),r(ind1+1:end));
    r = r(ind1-1:ind1+ind2(3)-1);
  end
  error(['Error running TeX: ' r]);
end

function dvips(file,res,exe_ext)
dvi_file = [file '.dvi'];
ps_file = [file '.ps'];
if Lispref('teximage','texpath')
  texbin = Lgetpref('teximage','texpath');
else
  texbin = '';
end
[s,r] = run_system_cmd(['"' fullfile(texbin,['dvips' exe_ext]) ...
                    '" -D ' int2str(res) ' -E -o "' ps_file ...
                    '" "' dvi_file '"']);
if ~exist(ps_file)
  ind1 = findstr('!',r);
  if ~isempty(ind1)
    r = r(ind1:end);
  end
  error(['Error running DVIPS: ' r]);
end

function bits = ghostscript(file,res,exe_ext);
origpsfile = [file '.ps'];
psfile = [file '2.ps'];
%some postscript hacking to translate the equation to 0,0
origps_fid = fopen (origpsfile, 'r');
F=fread(origps_fid); % read the whole thing in
fclose(origps_fid);
F=char(F');
bbox=findstr('BoundingBox',F) + 13; % skip to start of numbers
bboxstr = F(bbox:bbox+50);
bbox = sscanf(bboxstr,'%d',4);      % read in bounding box
endsetup=findstr('EndSetup',F)+8;
while isspace(F(endsetup))
  endsetup = endsetup + 1;
end
F=[F(1:endsetup-1) int2str(-bbox(1)) ...
   ' ' int2str(-bbox(2)) ' translate ' F(endsetup:end)];
ps_fid = fopen (psfile, 'w');
fwrite(ps_fid,F);
fclose(ps_fid);

% now go and rasterize the translated file
pcx_file = [file '.pcx'];
rsp_file = [file '.rsp'];
rsp_fid = fopen (rsp_file, 'w');

ghostDir = fullfile( matlabroot, 'sys', 'ghostscript' );
if ~exist(ghostDir)
  error( ['Can not find the directory for Ghostscript in ' matlabroot] )
end

fprintf(rsp_fid, '-dNOPAUSE -q \n');
v = version;
if (v(1) > '6') | ((v(1) == '6') & (v(3) > '0'))
  fprintf(rsp_fid, '-I"%s"\n', fullfile( ghostDir, 'ps_files'));
  fprintf(rsp_fid, '-I"%s"\n', fullfile( ghostDir, 'fonts'));
  fprintf(rsp_fid, '-sOutputFile="%s"\n', pcx_file );
else
  fprintf(rsp_fid, '-I%s\n', fullfile( ghostDir, 'ps_files',' '));
  fprintf(rsp_fid, '-I%s\n', fullfile( ghostDir, 'fonts',' '));
  fprintf(rsp_fid, '-sOutputFile=%s\n', pcx_file );
end
fprintf(rsp_fid, '-sDEVICE=pcxmono\n');
width = ceil(bbox(3)-bbox(1))*res/72;
height = ceil(bbox(4)-bbox(2))*res/72;
fprintf( rsp_fid, ['-g' int2str(width) 'x' int2str(height) '\n'] );
fprintf( rsp_fid, ['-r' int2str(res) '\n'] );
fclose(rsp_fid);

if isunix
  gsPath = fullfile(ghostDir,'bin',getenv('ARCH'));
else
  gsPath = fullfile(ghostDir,'bin','win32');
  if ~exist(gsPath,'dir')
    gsPath = fullfile(ghostDir,'bin','nt');
  end
end  
[s, r] = run_system_cmd( ['echo quit | "' fullfile(gsPath, ['gs' exe_ext])...
                    '" "@' rsp_file '" "' psfile '"']);
if ~exist(pcx_file)
  error(['Error running Ghostscript: ' r]);
end
bits = double(imread(pcx_file,'pcx'));

function im = makeimage(p,color,antialias,csize,angle)
p = rot90(p,angle);
mask = p == 1;
F = repmat(1/(csize*csize),[csize csize]);
if isa(color,'char')
  switch lower(color)
   case 'y'
    color = [1 1 0];
   case 'm'
    color = [1 0 1];
   case 'c'
    color = [0 1 1];
   case 'r'
    color = [1 0 0];
   case 'g'
    color = [0 1 0];
   case 'b'
    color = [0 0 1];
   case 'w'
    color = [1 1 1];
   case 'k'
    color = [0 0 0];
   case 'none'
    color = [1 1 1];
  end
end
if (color(1) ~= color(2)) | (color(2) ~= color(3))
  p1 = p; p1(mask) = color(1);
  p2 = p; p2(mask) = color(2);
  p3 = p; p3(mask) = color(3);
  if isequal(antialias,'on')
    p1 = doblur(p1,F);
    p2 = doblur(p2,F);
    p3 = doblur(p3,F);
  end
  im = cat(3,p1,p2,p3);
else
  p(mask) = color(1);
  if isequal(antialias,'on')
    p = doblur(p,F);
  end
  im = repmat(p,[1 1 3]);
end

function out = doblur(p,F)
out = conv2(p,F,'valid'); % reduces p
out(out>1) = 1;out(out<0) = 0;

function menu = makecontextmenu(h)
menu = uicontextmenu;
item = uimenu('parent',menu,'label','Increase Size','callback',...
	       'teximage(''increasesize'',gcbo)','userdata',h);
item = uimenu('parent',menu,'label','Decrease Size','callback',...
	       'teximage(''decreasesize'',gcbo)','userdata',h);
item = uimenu('parent',menu,'label','Sharpen','callback',...
	       'teximage(''sharpentex'',gcbo)','userdata',h);
item = uimenu('parent',menu,'label','Blur','callback',...
	       'teximage(''blurtex'',gcbo)','userdata',h);
item = uimenu('parent',menu,'label','AntiAlias','callback',...
	       'teximage(''togglealias'',gcbo)','userdata',h);
item = uimenu('parent',menu,'label','Background');
sub = uimenu('parent',item,'label','White','callback',...
	       'teximage(''whitecolor'',gcbo)','userdata',h);
sub = uimenu('parent',item,'label','Figure Color','callback',...
	       'teximage(''figurecolor'',gcbo)','userdata',h);
sub = uimenu('parent',item,'label','Transparent','callback',...
	       'teximage(''transparent'',gcbo)','userdata',h);
item = uimenu('parent',menu,'label','Angle');
sub = uimenu('parent',item,'label','Rotate Counterclockwise','callback',...
	       'teximage(''rotcounterclock'',gcbo)','userdata',h);
sub = uimenu('parent',item,'label','Rotate Clockwise','callback',...
	       'teximage(''rotclockwise'',gcbo)','userdata',h);

function setantialiasmenu(h,antialias)
menu = get(h,'uicontextmenu');
ch = get(menu,'children');
set(ch(3),'checked',antialias);

function startmove(h)
ax=get(h,'parent');
fig=get(ax,'parent');
setappdata(fig,'teximagemotion',h);
setappdata(h,'mousemove',get(fig,'windowbuttonmotionfcn'));
setappdata(h,'mouseup',get(fig,'windowbuttonupfcn'));
fpos = convertUnits(get(fig,'units'),get(fig,'position'),'inches');
cp = convertUnits(get(fig,'units'),[get(fig,'currentpoint') 10 10],...
		  'inches',fpos,'inches');
setappdata(h,'currentpos',cp(1:2));
set(fig,'windowbuttonmotionfcn','teximage(''mousemove'',gcbo)');
set(fig,'windowbuttonupfcn','teximage(''endmove'',gcbo)');

function mousemove(fig)
h = getappdata(fig,'teximagemotion');
ax=get(h,'parent');
apos = get(ax,'position');
oldpos = getappdata(h,'currentpos');
funits = get(fig,'units');
fpos = convertUnits(funits,get(fig,'position'),'inches');
cp = convertUnits(funits,[get(fig,'currentpoint') 10 10],'inches',...
		  fpos,'inches');
newpos = cp(1:2);
diffs = newpos-oldpos;
apos(1:2) = apos(1:2) + diffs;
set(ax,'position',apos);
setappdata(h,'currentpos',newpos);
oldcenter = getappdata(h,'position');
cunits = getappdata(h,'units');
cp = convertUnits(cunits,[oldcenter 10 10],'inches',fpos,'inches');
cp(1:2) = cp(1:2) + diffs;
cp = convertUnits('inches',cp,cunits,fpos,'inches');
setappdata(h,'position',cp(1:2));

function endmove(fig)
h = getappdata(fig,'teximagemotion');
set(fig,'windowbuttonmotionfcn',getappdata(h,'mousemove'));
set(fig,'windowbuttonupfcn',getappdata(h,'mouseup'));

function docallback(s,menuh)
h = get(menuh,'userdata');
fig = get(get(h,'parent'),'parent');
op=get(fig,'pointer');
set(fig,'pointer','watch');
switch (s)
 case 'increasesize'
  teximage(h,'scale',getappdata(h,'scale') * 1.25);
 case 'decreasesize'
  teximage(h,'scale',getappdata(h,'scale') / 1.25);
 case 'sharpentex'
  teximage(h,'convolution',getappdata(h,'convolution') - 2);
 case 'blurtex'
  teximage(h,'convolution',getappdata(h,'convolution') + 2);
 case 'whitecolor'
  teximage(h,'background','w');
 case 'figurecolor'
  teximage(h,'background',get(fig,'color'));
 case 'transparent'
  teximage(h,'background','none');
 case 'togglealias'
  a = getappdata(h,'antialias');
  if isequal(a,'on')
    teximage(h,'antialias','off');
  else
    teximage(h,'antialias','on');
  end
 case 'rotcounterclock'
  teximage(h,'rotation',getappdata(h,'rotation') + 90);
 case 'rotclockwise'
  teximage(h,'rotation',getappdata(h,'rotation') - 90);
end
set(fig,'pointer',op);

function figuremoved(fig);
fpos = convertUnits(get(fig,'units'),get(fig,'position'),'inches');
H = findall(fig,'type','image','tag','teximage');
H=H(:)';
for h=H
  ax = get(h,'parent');
  hunits = getappdata(h,'units');
  if hunits(1) == 'n'
    apos = get(ax,'pos');
    pos = getappdata(h,'position');
    center = convertUnits(hunits,[pos 10 10],'inches',fpos,'inches');
    apos(1:2) = center(1:2) - .5*apos(3:4);
    set(ax,'pos',apos);
  end
end
  
function texbin = locateTeX
texbin = 0;
if isunix
  [s,path] = unix('which tex');
  if s == 0      % tex is on the system path so
    texbin = ''; % we don't need to include an explicit path
  end
else
  % first try looking for MiKTeX
  try
    texbin = winqueryreg('HKEY_LOCAL_MACHINE',...
	'SOFTWARE\MiK\MiKTeX\CurrentVersion\MiKTeX','Install Root');
  catch
    return
  end
  texbin = fullfile(texbin,'miktex','bin');
end

function texbin = promptForTeX(exe_ext)
oldcd = pwd;
cd(matlabroot); % so that the user doesn't start navigating
                % from the TEMP directory.
[file,texbin] = uigetfile(['*' exe_ext],'Locate TeX Executable');
cd(oldcd);

function val = getdefault(ishndl,s,str,default)
if ishndl
  val = getappdata(s,str);
elseif Lispref('teximage',str)
  val = Lgetpref('teximage',str);
else
  val = default;
end

function [s,r] = run_system_cmd(cmd);
if isunix
  [s, r] = unix(cmd);
else
  [s, r] = dos(cmd);
end

function val2 = convertUnits(units1,val1,units2,ref,refunits)
%Persistent figure so that we can get the figure position 
%  in inches instead of its units. This way we don't change 
%  the original figure. Also used to convert any units.
persistent teximage_figure_for_units;
persistent teximage_axes_for_units;
if isempty(teximage_figure_for_units)
  teximage_figure_for_units = figure('visible','off',...
				     'handlevis','off',...
				     'integerhandle','off');
  teximage_axes_for_units=axes('parent',teximage_figure_for_units);
end
set(teximage_figure_for_units,'units','inches');
if nargin == 3
  set(teximage_figure_for_units,'units',get(0,'Units'));
  set(teximage_figure_for_units,'position',get(0,'ScreenSize'));
else
  set(teximage_figure_for_units,'units',refunits);
  set(teximage_figure_for_units,'position',ref);
end
set(teximage_axes_for_units,'units',units1);
set(teximage_axes_for_units,'position',val1);
set(teximage_axes_for_units,'units',units2);
val2 = get(teximage_axes_for_units,'position');

function out = canreusebits(h,resolution,displaymode,s)
res  = getappdata(h,'resolution');
disp = getappdata(h,'displaymode');
str  = getappdata(h,'texstring');
out  = isequal(res,resolution) & isequal(disp,displaymode) & ...
      isequal(str,s);

% preferences API that works on both R11 and R12
function out = Lispref(s1,s2)
oldwarn = warning;
warning('off');
out = logical(0);
try
  out = ispref(s1,s2);
catch
  if isappdata(0,s1)
    h = getappdata(0,s1);
    out = isfield(h,s2);
  end
end
warning(oldwarn);

function out = Lgetpref(s1,s2)
oldwarn = warning;
warning('off');
try
  out = getpref(s1,s2);
catch
  if isappdata(0,s1)
    h = getappdata(0,s1);
    out = getfield(h,s2);
  else
    error(['No preference for ' s2]);
  end
end
warning(oldwarn);

function Lsetpref(s1,s2,val)
oldwarn = warning;
warning('off');
try
  setpref(s1,s2,val);
catch
  setappdata(0,'teximage',struct(s2,val));
  disp('Copy the following line into your startup.m:');
  if isa(val,'char')
    disp(['setappdata(0,''teximage'',struct(''' s2 ''', ''' val '''));']);
  end
end
warning(oldwarn);


