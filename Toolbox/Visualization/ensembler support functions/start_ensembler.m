function start_ensembler

% START_ENSEMBLER is a stand-alone function to control startup window of
% options for ensembler GUI


% NOTES
%
% - functions 'start_ensembler' and 'startup_ensembler' control icons
%   in ensembler GUI
% - additional icons to control new functions can be added under the
%   uimenu section of startup_ensembler
% - Some functions have been commented out to keep the basic ensembler
%   version clean, but may still work


% Updated Aug 2017 by Philippe C. Dixon
% - Support for message box added
% - ensembler finds the correct sizing for you. Thus, the fig width and height options
%   have been removed. See 'ensembler_figsize' for details


e=which('ensembler'); % returns path to ensemlber
path = pathname(e) ;  % local folder where ensembler resides

defaultvalfile = [path,'default_ensembler_values.mat'];

dval = load(defaultvalfile,'-mat');
dval = dval.a;

fstring = dval{1};      
nrows = dval{2};
ncols = dval{3};
xwid = dval{4};
ywid = dval{5};
hspac = dval{6};
vspac = dval{7};
font = dval{8};
fontsize = dval{9};
units = dval{10};

options.Resize = 'on';
boxwidth = 50; % width of initial dialog box
% a = inputdlg({'Group names','Figure width','Figure height','Rows','Columns',...
%     'Axis width','Axis height','Horizontal spacing','Vertical spacing',...
%     'Font Name','Font size','Units'},...
%     'Ensembler Setup Window',[1 boxwidth],{fstring,fwid,fheig,nrows,ncols,xwid,ywid,hspac,vspac,font,fontsize,units},options);

a = inputdlg({'Group names','Rows','Columns',...
    'Axis width','Axis height','Horizontal spacing','Vertical spacing',...
    'Font Name','Font size','Units'},...
    'Ensembler Setup Window',[1 boxwidth],{fstring,nrows,ncols,xwid,ywid,hspac,vspac,font,fontsize,units},options);


if isempty(a)
    disp('exiting ensembler')
    return
end

nrows = str2double(a{2});
ncols = str2double(a{3});
xwid = str2double(a{4});
ywid = str2double(a{5});
fontName = a{8};
fontSize = str2double(a{9});
units = a{10};

% error check on units before save
%
if strcmp(units,'cm')
    units = 'centimeters';
    a{10} = 'centimeters';
end
save(defaultvalfile,'a')

if ~ismember(units,{'inches','centimeters','normalized'})
    error('please choose ''inches'', ''centimeters'' or ''normalized'' as ensembler units')
end


if strcmp(a{6},'even')
    xspace = a{6};
else
    xspace = str2double(a{6});
end

if strcmp(a{9-2},'even')
    yspace = a{9-2};
else
    yspace = str2double(a{9-2});
end

nm = partitionname(a{1});

nfigs = length(nm);

[fwid,fheig,nxwid,nywid,msgbox_space,msg] = ensemble_figsize(nrows,ncols,xwid,ywid,units);


% save default val (possible after fix above)
%
if nxwid ~=xwid
    a{4} = num2str(nxwid);
    xwid = nxwid;
    save(defaultvalfile,'a')
end
if nywid ~=ywid
    a{5} = num2str(nywid); %#ok<*NASGU>
    ywid = nywid;
    save(defaultvalfile,'a')
end


for i = 1:length(nm)
    startup_ensembler(nm{i},nrows,ncols,xwid,ywid,xspace,yspace,fwid,fheig,i,...
                      nfigs,fontName,fontSize,units,msgbox_space,msg)
end





