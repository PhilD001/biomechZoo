function bmech_renamechannel(och,nch,fld)
      
% This m-file will rename channels in your data
%
% bmech_renamechannel(och,nch,fld)
% 
% ARGUMENTS
%  och        ...    name of old channels as cell array of strings ex. {'ch1','ch2','ch3'}
%  nch        ...    name of new channels as cell array of strings ex. {'RKNA','RANK','fz'}
%  fld        ...    optional argument. name of folder to operate on
%  section    ...    optional argument. Type (video or analog) of channel
%
% Created May 2009 
%
% Updated March 2011
% - Added optional 3rd argument
%
% Updated January 2014
% - updates channel list in relevant section (video or analog)
% - uses standalone renamechannel
%
%
%----------Part of the Zoosystem Biomechanics Toolbox 2006-2014------------------------------%
%                                                                                            %                
% MAIN CONTRIBUTORS                                                                          %
%                                                                                            %
% Philippe C. Dixon         Dept. of Engineering Science. University of Oxford, Oxford, UK   %
% JJ Loh                    Medicus Corda, Montreal, Canada                                  %
% Yannick Michaud-Paquette  Dept. of Kinesiology. McGill University, Montreal, Canada        %
%                                                                                            %
% - This toolbox is provided in open-source format with latest version available on          %
%   GitHub: https://github.com/phild001                                                      %
%                                                                                            %
% - Users are encouraged to edit and contribute to functions                                 %
% - Please reference if used during preparation of manuscripts                               %                                                                                           %
%                                                                                            %
%  main contact: philippe.dixon@gmail.com                                                    %
%                                                                                            %
%--------------------------------------------------------------------------------------------%


if nargin ==2
    fld = uigetfolder;
    cd(fld);
else
    fl = engine('path',fld,'extension','zoo');
end


if length(och)~=length(nch)
    disp('number of new name channels does not match number of old channel names to replace')
    return    
end
    

disp('renaming the following channels...')
disp(' ')

for i = 1:length(och)
    disp(['renaming ', och{i}, ' to ',nch{i}])
end

disp(' ')


for i = 1:length(fl)
    data = load(fl{i},'-mat');
    disp(['renaming channels for :',fl{i}]);
    data = data.data;
    data = renamech(data,och,nch);
    save(fl{i},'data');
end













