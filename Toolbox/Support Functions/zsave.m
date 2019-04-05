function zsave(fl,data,message)

% ZSAVE(fl,data,message) saves zoo files to disk with processing step information appended to the 
% zoosystem 'Processing' branch.
%
% ARGUMENTS
%  fl       ...  Full path to file (string)
%  data     ...  Zoo data
%  message  ...  Further details about processing step (string). Default: Current date.
%
% e.g.1 If the function bmech_partition is run, then calling zsave(fl,data)
% will add 'bmech_partition' to the branch 'data.zoosystem.processing'
%
% e.g.2 If the function bmech_removechannel is called to remove the
% channels ch = {'RKneeAngle_x','LAnkleAngle_y'} then calling
% zsave(fl,data,ch) will add 'bmech_removechannel 'RKneeAngle_x','LAnkleAngle_y'
% to the branch 'data.zoosystem.processing'
%
% See also save, zload


% Revision History
%
% Created by Philippe C. Dixon Sept 15th 2015
%
% Updated by Philippe C. Dixon July 2016
% - explicit mat file save to version 7 added. Note that v7.3 results in
%   larger files, explained here http://www.mathworks.com/help/matlab/ref/save.html#inputarg_version
% - Date stamp appended to message
% - renamed branch from 'processing' to 'Processing' for consistency with
%   other data.zoosystem fields 
%
% Updated by Philippe C. Dixon Feb 2017
% - Speed tests conducted showed that v6 are faster than v7
%
% Updated by Philippe C. Dixon August 2018
% - zsave can be called from outside a batch process function


% version type for file save
%
% version = '-v7';                               % v7 files are smaller than v7.3
version = '-v6';                                 % v6 permit faster writing than v7

% determine which function called zsave
%
ST = dbstack(1);
if isempty(ST)
    process = 'process';
else
    process = ST.name;
end

% Add additional processing info
%
if nargin==2
    message = '';
end

process = [process,' ',message,' (',date,')'];

% write processing step to zoosystem
%
if ~isfield(data.zoosystem,'Processing')
    data.zoosystem.Processing = {process};
else
    r = data.zoosystem.Processing;
    r{end+1,1} = process;
    data.zoosystem.Processing = r;
end    

% check write status of file
%
% 
% if exist(fl,'file')==2
%     [~,values] = fileattrib(fl);
%     if values.UserWrite ==0
%         check = false;
%     end
% end


% if exist(fl,'file')==2 
%    check = true;
%    maxCount = 100;
%    count = 1;
%    while check
%      [~,values] = fileattrib(fl);
%      
%      if values.UserWrite && count < maxCount
%          check = false;
%      else
%          count = count+1;
%          disp('file locked for writing, trying again...')
%      end
%    
%    end
% end



% traditional save
%
save(fl,'data',version);








