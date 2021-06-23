function [version_num,version_date] = zooinfo(verbose)

% The biomechZoo biomechanics Toolbox Copyright (c) 2006-2020 (Main contributors)
%
% Main contributor:
% Philippe C. Dixon, PhD

% philippe.dixon@gmail.com 
% 
% Web:
% https://www.biomechzoo.com
%
% Ressources (Repositories):
% Code: https://github.com/PhilD001/biomechZoo
% Help: https://github.com/PhilD001/biomechZoo-help
% manuscript: http://www.biomechzoo.com/s/biomechZoo_Dixon2017.pdf
%
% License
% biomechZoo is released under the Apache license version 2.0:
% http://www.apache.org/licenses/LICENSE-2.0
%
% Referencing:
% Please reference us if biomechZoo was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. biomechZoo: An open-source toolbox 
% for the processing, analysis, and visualization of biomechanical movement data
% Computer Methods and Programs in Biomedicine. 2017. 140:1-10.
% DOI: http://dx.doi.org/10.1016/j.cmpb.2016.11.007

if nargin == 0
    verbose = true;
end

% get version number
e=which('engine'); % returns path to ensemlber
path = pathname(e) ;  % local folder where ensembler resides
defaultvalfile = [path,'biomechZoo_version_number.mat'];
version = load(defaultvalfile,'-mat');
version= version.version;
        
version_num = version.number;
version_date = version.date;

if verbose
    help zooinfo
    disp(['  Latest version: ',num2str(version_num),' (', version_date, ')'])
    disp(' ')
    disp('  List of available functions available at ')
    disp('  <a href="https://phild001.github.io/biomechZoo-help">https://phild001.github.io/biomechZoo-help</a>')
end



