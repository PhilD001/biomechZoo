function fl = engine(varargin)

% fl = ENGINE(varargin) is a file searching algorithm
%
% inputs are in pairs where the first element is the property name and the second is a property value
% The 'path' property is required.  All other properties are optional. All arguments must be strings.
%
% ARGUMENTS
%  'path' or 'fld' ...  folder path to begin the search as string
%  'extension'     ...  type of file to search as string. ex. '.c3d' or 'csv'
%  'search file'   ...  return only files containing specific string ex. '_g_'
%  'search path'   ...  search for a particular string in the path name ex 'hello' in data/hello
%  'folder'        ...  search only in folders of a specific name located downstream from the path (string)
%
% RETURNS
%  fl              ...  list of files as cell array of strings  
%
% e.g. #1 Return all files in the root folder C:/Users/Public which contain the
% string 'imba':
% fl = engine('path','C:/Users/Public','search file','imba')
%
% e.g. #2 Return all files in the root folder C:/Users/Public which are
% located in the subfolder Sample Music: 
% fld = 'C:/Users/Public';
% fl = engine('path',fld,'search path','Sample Music')


% Revision History
%
% Created by JJ Loh  2006/09/20
% Departement of Kinesiology
% McGill University, Montreal, Quebec Canada
%
% Updated by JJ Loh 2006/10/23
% - function now searches for partners.
%   the search function will search in the path and not the filename.
%
% Updated by Phil Dixon 2008/02/05
% - engine can now be used on mac intel. functionality on older mac has not
%   been tested
%
% Updated by Phil Dixon 2011/05/03
% - updated help menu. It is now clear that you can limit search to files
%   containing a specific string
% - multiple options can fit into 'options', but only 1 will work currently
%
% Updated by Phil Dixon 05.02.2015
% -fixed bug when 'option' contains 2 options
% - argument 'folder' not tested
% - use off both options and search path does not work
%
% Updated by Philippe C. Dixon April 2015
% - fixed small bug on MAC platform
% - Users can select 'extension' and 'search file' simultaneously
% - extra error checking added
%
% Updated by Philippe C. Dixon June 2015
% - improved help with examples
%
% Updated by Philippe C. Dixon Jan 2016
% - replaced call to function 'slash' with Matlab embedded 
%   function 'filesep'


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
% 
% Contact: 
% philippe.dixon@gmail.com
%
% Web: 
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis 
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in 
% Aduts and Children. Rome, Italy.Sept 29-Oct 4th 2014. 


% Set arguments
%
pth = '';
fld = 'all';
src = 'all';
other = [];

if ~iseven(nargin)
    error('missing argument pair')
end

for i = 1:2:nargin

    switch varargin{i}
          
        case {'pth','path','fld'}
            pth = varargin{i+1};
        
        case 'folder'
            fld = varargin{i+1};
            
        case {'search','search path'}
            src = varargin{i+1};
  
        otherwise
            other = [other; varargin(i),varargin(i+1)];
    end
end


if isempty(pth)
    fl = {};
    return
end


% Check for use of 2 'other' cases
%
[r,~] = size(other);

if r <=1
    fl = fldengine(pth,fld,src,other);
elseif r==2    
    fl1 = fldengine(pth,fld,src,other(1,:));
    fl2 = fldengine(pth,fld,src,other(2,:));
    fl = intersect(fl1,fl2);
else
    error('too many arguments for other input')
end



% == EMBEDDED FUNCTIONS ========================================================


function fl =fldengine(pth,fld,src,other)

s = filesep;    % determine slash direction based on computer type

if ~strcmp(pth(end),s)
    pth = [pth,s];
end

fl = {};
if strcmp(fld,'all')  %if true, doesn't recurse, goes to src engine
    fl = srcengine(pth,src,other);
    
else
    [~,p] = directory(pth);
    
    for i = 1:length(p)
        if strcmp(p{i},fld)
            plate = srcengine([pth,p{i}],src,other);
        else
            plate = fldengine([pth,p{i}],fld,src,other);
        end
        fl = [fl;plate];
    end
end


function fl = srcengine(pth,src,other)

s = filesep;

if ~strcmp(pth(end),s)
    pth = [pth,s];
end

fl = {};
[f,p] = directory(pth);    %if pth is terminal folder f contains files p is empty


if strcmp(src,'all') %if you specify no folder, defaults 'all';see if there are any of the spec files in the folder
    fl = initiatefxn(pth,f,other); % change
    
elseif ~isempty(strfind(pth,src));
    fl = initiatefxn(pth,f,other);
end

for i = 1:length(p)%this recursive step will occur downstream from the folder
    plate = srcengine([pth,p{i}],src,other);            %recurse, but now the path is now the subfolder
    fl = [fl;plate];
end

if isin(computer, 'MACI') %searches for anymore weird '\' in mac intel
    for i = 1:length(fl)
        indx  = strfind(fl{i},'\');
        if ~isempty(indx)
            fl{i} = [fl{i}(1:indx-1), fl{i}(indx+1:end)];
        end
    end
end


function fl = initiatefxn(pth,filename,other)


if isempty(other)
    fl = concatfiles(pth,filename);
else
    
    switch other{1,1}
        
        case 'extension'
            fl = findextension(pth,filename,other{1,2});                 %filename can be a cell array of filenames
            
        case 'search file'
            fl = searchfile(pth,filename,other{1,2}); 
    end
end


function r = concatfiles(pth,fls)
r = [];
for i = 1:length(fls)
    r = [r;{concatfile(pth,fls{i})}];
end


function r = findextension(pth,fl,ext)
r = [];
ext = strrep(ext,'.','');

for i = 1:length(fl)
    indx = max(findstr(fl{i},'.'));
    if isempty(indx)
        continue
    elseif strcmpi(fl{i}(indx+1:end),ext)
        r = [r;{concatfile(pth,fl{i})}];
    end
end


function r = searchfile(pth,fl,src)

r = [];
for i = 1:length(fl)
    if ~isempty(findstr(fl{i},src))
        r = [r;{concatfile(pth,fl{i})}];
    end
end