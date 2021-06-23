function updateZoo(version_num)

% UPDATEZOO should be run before pushing new commits to the repository
%
% ARGUMENTS
% version_num ... string. The biomechzoo version number associated with your commit
%
% NOTES
% - users should first run checkZoo to make sure update has not broken any processess
% - m2html repo must be installed in common root directory with biomechZoo,
%   download m2html here: https://github.com/phild001/m2html


% set up default path
e=which('engine'); % returns path to engine
path = pathname(e) ;  % local folder where ensembler resides
defaultvalfile = [path,'biomechZoo_version_number.mat'];

% prompt for no arguments with default previous version
if nargin == 0
    prompt = {'Enter new version number:'};
    dlgtitle = 'biomechZoo version number';
    dims = [1 35];
    defaultvalfile = [path,'biomechZoo_version_number.mat'];
    version = load(defaultvalfile,'-mat');
    version= version.version;
    
    version_num = version.number;
    definput = {version_num};
    
    version = inputdlg(prompt,dlgtitle,dims,definput);
    version_num = version{1};
end

% update zoo version
version = struct;
version.number = version_num;
version.date = date;
save(defaultvalfile,'version')

% update documentation
s = filesep;
e=which('engine'); % returns path to engine
indx = strfind(e, s);
fld_root = e(1:indx(end-3));
fld_m2html = [fld_root, s, 'm2html'];
if ~exist(fld_m2html, 'dir')
    error(['you must have the m2html repo installed at ', fld_m2html])
end
addpath(fld_m2html)  
biomechZoo_documentation
