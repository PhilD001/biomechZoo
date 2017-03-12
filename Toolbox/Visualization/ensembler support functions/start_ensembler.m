function start_ensembler

% START_ENSEMBLER is a stand-alone function to control startup of
% ensembler GUI


% NOTES
%
% - functions 'start_ensembler' and 'startup_ensembler' control icons
%   in ensembler GUI
% - additional icons to control new functions can be added under the
%   uimenu section of startup_ensembler
% - Some functions have been commented out to keep the basic ensembler
%   version clean, but may still work

e=which('ensembler'); % returns path to ensemlber
path = pathname(e) ;  % local folder where ensembler resides

defaultvalfile = [path,'default_ensembler_values.mat'];

dval = load(defaultvalfile,'-mat');
dval = dval.a;

fstring = dval{1};
fwid = dval{2};
fheig = dval{3};
nrows = dval{4};
ncols = dval{5};
xwid = dval{6};
ywid = dval{7};
hspac = dval{8};
vspac = dval{9};
font = dval{10};
fontsize = dval{11};
units = dval{12};

options.Resize = 'on';
a = inputdlg({'Names','Figure width','Figure height','Rows','Columns',...
    'Axis width','Axis height','Horizontal spacing','Vertical spacing',...
    'Font Name','Font size','Units'},...
    'axes',1,{fstring,fwid,fheig,nrows,ncols,xwid,ywid,hspac,vspac,font,fontsize,units},options);

if isempty(a)
    disp('exiting ensembler')
    return
end

save(defaultvalfile,'a')

fwid = str2double(a{2});
fheig = str2double(a{3});
nrows = str2double(a{4});
ncols = str2double(a{5});
xwid = str2double(a{6});
ywid = str2double(a{7});
fontName = a{10};
fontSize = str2double(a{11});
units = a{12};

% error check on units
%
if strcmp(units,'cm')
    units = 'centimeters';
    a{12} = 'centimeters';
    save(defaultvalfile,'a')
end

if ~ismember(units,{'inches','centimeters','normalized'})
    error('please choose ''inches'', ''centimeters'' or ''normalized'' as ensembler units')
end


if strcmp(a{8},'even')
    xspace = a{8};
else
    xspace = str2double(a{8});
end

if strcmp(a{9},'even')
    yspace = a{9};
else
    yspace = str2double(a{9});
end

nm = partitionname(a{1});

nfigs = length(nm);

for i = 1:length(nm)
    startup_ensembler(nm{i},nrows,ncols,xwid,ywid,xspace,yspace,fwid,fheig,i,...
                      nfigs,fontName,fontSize,units)
end

