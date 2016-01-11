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

options.Resize = 'on';
a = inputdlg({'name','figure width (inches)','figure height (inches)','rows','columns','width (inches)','height (inches)','horizontal spacing (inches)','vertical spacing (inches)'},'axes',1,...
    {fstring,fwid,fheig,nrows,ncols,xwid,ywid,hspac,vspac},options);

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
    startup_ensembler(nm{i},nrows,ncols,xwid,ywid,xspace,yspace,fwid,fheig,i,nfigs)
end

