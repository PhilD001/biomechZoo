function data = addevent_data(data,ch,ename,type)

% data = ADDEVENT_DATA(data,ch,ename,type) called by bmech_addevent to add data to event branches.
%
% ARGUMENTS
%  data     ...  Zoo data
%  ch       ...  Channels to add event to (cell arrray of strings). 
%  ename    ...  The name of the new event branch in zoo file as string
%  type     ...  See line 47 ('max' 'min' 'toe off' heel strike'...) string
%
% RETURNS
%  data     ...  Zoo data with new event data appended
%
% NOTES
% - Users are encouraged to modify event functions for specific needs
% - Not all events have been tested
%
% See also bmech_addevent, bmech_removeevent, bmech_renameevent

% Revision notes
%
% Updated by Philippe C. Dixon Sept 2015
% - Additional argument 'sfld' can be used to exclude folder 'sfld' from
%   addevent algorithm. This can be useful when events do not 'make sence' for
%   a particular sub folder. e.g. a subfolder of static pose cannot have a
%   foot strike event. For these files the event would show [1 NaN 0]
%
% Updated by Philippe C. Dixon March 2016
% - added ability to identify gait events using force plate data
%   (see FPevents)
%
% Updated by Philippe C. Dixon July 2017
% - Bug fix for option 'all' for ch (github bug report #4)
%
% Updated by Philippe C. Dixon Nov 2017
% - Bug fix for reaction force check


% Some settings
%
FP_thresh = 0;         % threshold (Newtons) for finding force plate events

if ~iscell(ch)
    ch = {ch};
end

if length(ch)==1 && strcmp(ch{1},'all')
    ch = fieldnames(data);
end

ch = setdiff(ch,{'zoosystem'});

for i = 1:length(ch)
    
    if isempty(ename)
        data.(ch{i}).event = struct;
        continue
    end
    
    if ~isfield(data,ch{i})
        disp(['channel : ',ch{i}, ' does not exist'])
        continue
    end
    
    yd = data.(ch{i}).line;
    [rows, cols] = size(yd); %#ok<ASGLU>
    if cols > 1
        warning(['Your data has ', num2str(cols), 'columns, unexpected behavior...'])
    end
    
    switch lower(type)
        
        case 'absmax'  
            [eyd,exd] = max(abs(yd));
            
        case 'first'
            exd = 1;
            eyd = yd(exd);
            
        case 'last'
            exd = length(yd);
            eyd = yd(exd);
            
        case 'max'
            [eyd,exd] = max(yd);
            
        case 'min'
            [eyd,exd] = min(yd);
            
        case 'rom'
            eyd = max(yd)-min(yd);
            exd = 1;
            
        case {'fs_fp','fo_fp'}
            AVR = data.zoosystem.AVR;
            if AVR ~=1
                error('Video and Analog channels must be at same sampling rate, use bmech_resample')
            end
            units = data.zoosystem.Units.Forces;
            if strcmp(units,'N/kg')
                m = getanthro(data,'Bodymass');
            else
                m = 1;
            end
            
            if isempty(strfind(ch{i},'_'))
                yd = data.(ch{i}).line(:,3);
            else
                yd = data.(ch{i}).line;
            end
            
            peak = peakSign(yd);
            
            if strfind(type,'FS')
                exd = find(peak*yd*m>FP_thresh,1,'first');
                exd = exd-1;
            else
                exd = find(peak*yd*m>FP_thresh,1,'last');
                exd = exd+1;
            end
            
            eyd = yd(exd);
         
        case {'rfs','rfo','lfs','flo'}
            exd = ZeniEventDetect(data,type(1),type(2:end));
            
            if isnan(exd)
                eyd = NaN;
                ename = [ename,'1']; 
            elseif length(exd)==1
                eyd = yd(exd);
                ename = [ename,'1']; %#ok<*AGROW>
            end
            
            
        case 'staticstart'        % trims early frame from a static trial
            exd = length(yd)-10;
            eyd = 0;
            
        case 'staticend'          
            exd = length(yd);
            eyd = 0;
        
        case 'first_fs'
             exd_r = ZeniEventDetect(data, 'R', 'FS');
             exd_l = ZeniEventDetect(data, 'L', 'FS');
             
             if exd_r(1) < exd_l(1)
                exd = exd_r;
             else
                 exd = exd_l;
             end
         
            
        otherwise
            error(['event type: ',type,' does not exist'])
            
    end
    
    if isempty(exd)
        error('no event found')
    end
    
    
    if length(exd) > 1 % many events
        
        for j = 1:length(exd)
            eyd = yd(exd(j));
            data.(ch{i}).event.([ename,num2str(j)]) = [exd(j),eyd,0];
        end
        
    else
        data.(ch{i}).event.(ename) = [exd,eyd,0];
    end
    
    
end