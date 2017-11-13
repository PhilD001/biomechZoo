function ensembler_processing(fld)

% ENSEMBLER_PROCESSING(fld,action) saves, loads, and runs processing

% get button information
%
bhnd = gcbo;                  % which button was just pressed
action = get(bhnd,'label');   % label of current button
phnd = get(bhnd,'parent');    % extract root menu
label = get(phnd,'label');    % label of root menu

% find process file
%
tfile = engine('fld',fld,'extension','txt','search file','process_record');

% create blank text file (overwrites any existing file)
%
if strcmp(action,'set working directory')
    
    if exist(tfile, 'file')
        delete(tfile)
        ensembler_msgbox(fld,'removing old process record file')
    else
        timestamp = datestr(clock);
        timestamp = strrep(timestamp,':','');
        tfile = [fld,filesep,'process_record_',timestamp,'.txt'];
        f = fopen( tfile, 'w' );
        fclose(f);
    end
    
elseif strcmp(label,'Processing')
    
else
    return
end
    
    % write to process file depending on button pressed
    %

%     switch label
%         
%         case 'Processing'
%            fid = fopen(tfile{1});
%            txt = textscan(fid, '%s', 'delimiter', ','); 
%            txt = [txt;action];
%            fwrite(fid,txt);
%            fclose(fid);
%            
%         case 'Events'
%             
%             
%         otherwise
%             return
%     end
%     
%     
% end

%file = ensembler('fld',fld,'extension','txt','search file','process_record');





%
% switch action
%
%     case 'save process record'
%
%         % load a single file wich should be representative of all
%         % processing
% %         fl_static = engine('fld',fld,'extension','zoo','search path','tatic');
% %         fl_all = engine('fld',fld,'extension','zoo');
% %         fl = setdiff(fl_static,fl_all);
% %         if isempty(fl)
% %             msg = 'no files found';
% %             return
% %         else
% %             data = zload(fl{1});  % load the first file, should be good
% %             process = data.zoosystem.Processing;
% %         end
% %
%
%     case 'load process record'
% %         pdata = engine('fld',fld,'extension','.txt','search file','processing_record');
% %
% %         if length(pdata) > 1
% %             msg = 'multiple records found, please remove unwanted process records')
% %             return
% %         end
% %
% %         if isempty(pdata)
% %             msg = 'no process records found';
% %             return
% %         end
%
%
%
%     otherwise
%         return
%
% end

% something like this
% fid = fopen( 'results.txt', 'wt' );
% for image = 1:N
%   [a1,a2,a3,a4] = ProcessMyImage( image );
%   fprintf( fid, '%f,%f,%f,%f\n', a1, a2, a3, a4);
% end
% fclose(fid);