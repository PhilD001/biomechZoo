function data = normalize_data(data,ch,datalength,method)

% data = NORMALIZE_DATA(data,ch,ndatalength,method) performs time normalization
%
% ARGUMENTS
%  ch         ... Channel(s) to operate on (single string or cell array of strings).
%                 Use 'Video','Analog', or 'all' to filter all video, analog or all
%                 channels, respectively.Defsult 'all'
%  datalength ... Normalize data to a specific length. Data will have datalength+1 frames.
%                 Default: 100 (101 frames)
%  method     ... method to interpolate data. Default 'linear'.
%                 See interp1 for more options
%
% RETURNS
%  data       ...  Zoo data with normalized channels
%
% See also interp1, bmech_normalize, normalize_line


% Revision history
%
% Created by Philippe C. Dixon March 2016
% - made standalone function based on existing code
%
% Updated by Philippe C. Dixon July 2016
% -renamed from normalizedata
% -bug fix for individual channel selection


% Set defaults/check arguments
%
if nargin==1
    ch = 'all';
    datalength = 100;
    method = 'linear';
end

if nargin ==2
    datalength=100;
    method = 'linear';
end

if nargin ==3
    method = 'linear';
end

if ismember(ch,{'Video','Analog'})                         % extract all video or
    ch = data.zoosystem.(ch).Channels;                     % analog channels
end

if strcmp(ch,'all');
    ch = setdiff(fieldnames(data),'zoosystem');
end

if ~iscell(ch)                                             % convert single channel string
    ch = {ch};                                             % to cell array of strings
end


for i = 1:length(ch)
    
    if ~isfield(data,ch{i})
        disp(['channel ',ch{i},'  does not exist'])
    else
        
        if i==1
            olength = length(data.(ch{i}).line);
        end
        
        nline = normalize_line(data.(ch{i}).line,datalength,method);
        
        if ~isempty(fieldnames(data.(ch{i}).event))
            event = fieldnames(data.(ch{i}).event);
            
            for e = 1:length(event)
                
                % if data.(ch{i}).event.(event{e})(2)~=999
                
                if data.(ch{i}).event.(event{e})(1)~=1 && ...
                        data.(ch{i}).event.(event{e})(1) ~= length(data.(ch{i}).line)
                    data.(ch{i}).event.(event{e})(1) = round(data.(ch{i}).event.(event{e})(1)/(olength)*datalength);
                elseif data.(ch{i}).event.(event{e})(1) == length(data.(ch{i}).line)
                    data.(ch{i}).event.(event{e})(1) = length(nline);
                    
                end
                
                % end
                
            end
        end
        
        data.(ch{i}).line  = nline;
        
    end
end

% Update zoosystem info
%
data.zoosystem.Video.Indx = (0:1:datalength)';
data.zoosystem.Analog.Indx = (0:1:datalength)';
