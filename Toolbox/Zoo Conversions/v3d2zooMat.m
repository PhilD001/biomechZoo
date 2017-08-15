function v3d2zooMat(varargin)

% v3d2zooMat(varargin) converts mat files created by visual3D into
% zoosystem files
%
% ARGUMENTS
%   fld        ...    folder to operate on
%   del        ...   choice to delete the source files. 'on' or 'yes' for yes
%                     'off' or 'no' for no. Default is off
% NOTES
% - This function is specific to the requirements of the McGill Ice Hockey
%   Research Group processing pipelines. Function will need to be updated
%   for general use, but can be used as a guide


% Revision History
%
% Created by Philippe C. Dixon Jan 2015 based on 'Import_data_visual3d'
% from Shawn Robbins
%
% Updated by Philippe C. Dixon May 2015
% - Improved functionality with events
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt



% Set defaults
%
tic
del = 'off';
s = filesep;    % determine slash direction based on computer type

for i = 1:2:nargin
    
    switch varargin{i}
        
        case 'fld'
            fld = varargin{i+1};
            
        case 'del'
            del =  varargin{i+1};
            
        otherwise
            
    end
end

och = {'FILE_NAME','FRAME_RATE','ANALOG_VIDEO_FRAME_RATIO'};        % non-physica channel list
indx = 1;                                                           % store event in ch{indx}


% Error checking
%
if ~isin(fld(end),s)
    fld = [fld,s];
end

cd(fld)

% Extract data from visual3d and save in zoo format
%
fl = engine('path',fld,'extension','mat');


for i = 1:length(fl)
    
    if isin(fl{i},'Waveform')
        
        % A) EXTRACT WAVE DATA FROM 'Waveform_SHOT.mat' FILE
        %
        [spth,name] = fileparts(fl{i});                              % subject subfolder
        type = strrep(name,'Waveform_','');
        wdata = load(fl{i},'-mat');                                  % load waveform data
        
        trial_names = wdata.FILE_NAME;                               % all trial names
        fsamp = wdata.FRAME_RATE;                                    % all sampling rates (should be all same)
        ch = setdiff(fieldnames(wdata),och)';                         % data channels only
        
        % B) EXTRACT DISCRETE EVENT DATA FROM 'Event_TYPE.mat' FILE
        %
        dfl = engine('path',spth,'search file',['Event_',type,'.mat']);
        ddata = load(dfl{1},'-mat');                                 % load discrete data
        ech = setdiff(fieldnames(ddata),och)';                        % evt channels only
        
        
        % C) EXTRACT DEMOGRAPHICS DATA FROM 'Demographics.mat' FILE
        %
        demo = engine('path',spth,'search file','Demographics.mat');
        
        if isempty(demo)
           error(['no demographics file for ',fl{i}])
        end
        
        if ~exist(demo{1},'file')==2
            error(['no demographics file for ',fl{i}])
        end
        
        demodata = load(demo{1},'-mat');                                 % load discrete data
        ach = setdiff(fieldnames(demodata),och);
        
        Anthro = struct;
        for k = 1:length(ach)
            r = demodata.(ach{k});
            Anthro.(ach{k}) = r{1};
        end
        
        
        % D) CREATE ZOOFILES FOR EACH CHUNK FROM WAVE AND DISCRETE FILES
        %
        for j=1:length(trial_names)
            
            batchdisplay(trial_names{j},'creating zoo file')
            
            data = struct;
            data.zoosystem.Video.Channels = {};
            
            for k = 1:length(ch)
                yd = wdata.(ch{k});
                yd = yd{j};
                
                [r,c] = size(yd);                               % check size of yd for problems
                if c > 3
                    yd = yd(:,1:3);
                end
                
                if isin(ch{k},'__')
                     rr = strrep(ch{k},'__','_');
                     data = addchannel_data(data,rr,yd,'Video');       % add physical channel
                else
                    data = addchannel_data(data,ch{k},yd,'Video');       % add physical channels
                end
                
            end
            
            for k = 1:length(ech)
                evt = ddata.(ech{k});
                evt = round(evt{j}*fsamp{j}+1);                  % convert event time to frame
                
                if isempty(evt) 
                    disp(['empty event field for ',ech{k}])
                    evt = 999;

                    if ismember(ech{k},{'ROFF','LOFF','RON','LON'})
                         data.(ch{indx}).event.([ech{k},'1']) = [evt 0 0 ];
                    else
                        data.(ch{indx}).event.(ech{k}) = [evt 0 0 ];                        
                    end

                else
                    
                    if length(evt)~=1 

                        for m = 1:length(evt)
                            data.(ch{indx}).event.([ech{k},num2str(m)]) = [evt(m) 0 0 ];
                        end
                    
                    elseif ismember(ech{k},{'ROFF','LOFF','RON','LON'})
                          data.(ch{indx}).event.([ech{k},'1']) = [evt 0 0 ];
                        
                    else
                        data.(ch{indx}).event.(ech{k}) = [evt 0 0 ];
                    end
                    
                end
                    
 
            end
            
            
            data.zoosystem.Video.Indx = (1:1:r)';
            data.zoosystem.Video.Freq = fsamp{j};
            data.zoosystem.SourceFile = trial_names{j};
            
            data.zoosystem.Anthro = Anthro;
            data.zoosystem.Units.Height = 'm';
            data.zoosystem.Units.Mass = 'kg';
            data.zoosystem.Units.BMI = 'kg/m^2';
            data.zoosystem.Units.Markers = 'mm';

            
            data.zoosystem.Codes.Sex.Female = 0;
            data.zoosystem.Codes.Sex.Male = 1;
            
            data.zoosystem.Codes.Level.Rec = 0;
            data.zoosystem.Codes.Level.Elite = 1;
            
            data.zoosystem.Codes.Side.Left = 0;
            data.zoosystem.Codes.Side.Right = 1;
                        
            tname = trial_names{j};
            indxx = strfind(tname,'\');  % alwayws a PC slash
            tname = tname(indxx(end)+1:end-4);
             
            zfl = [spth,s,tname,'.zoo'];
            zsave(zfl,data)
            
%             save([spth,s,tname,'.zoo'],'data');
            
        end
        
    end
    
    if isin(fl{i},'Static_Angles')
        
        % A) EXTRACT STATIC ANGLE DATA FROM 'Static_angles.mat' FILE
        %
        spth = fileparts(fl{i});                              % subject subfolder
        wdata = load(fl{i},'-mat');                                  % load waveform data
        
        trial_names = wdata.FILE_NAME;                               % all trial names
        fsamp = wdata.FRAME_RATE;                                    % all sampling rates (should be all same)
        ch = setdiff(fieldnames(wdata),och)';                         % data channels only
        
        
      
        % C) EXTRACT DEMOGRAPHICS DATA FROM 'Demographics.mat' FILE
        %
        demo = engine('path',spth,'search file','Demographics.mat');
        
        if isempty(demo)
           error(['no demographics file for ',fl{i}])
        end
        
        if ~exist(demo{1},'file')==2
            error(['no demographics file for ',fl{i}])
        end
        
        demodata = load(demo{1},'-mat');                                 % load discrete data
        ach = setdiff(fieldnames(demodata),och);
        
        Anthro = struct;
        for k = 1:length(ach)
            r = demodata.(ach{k});
            Anthro.(ach{k}) = r{1};
        end
        
        
        % D) CREATE ZOOFILES FOR EACH CHUNK FROM WAVE AND DISCRETE FILES
        %
        for j=1:length(trial_names)
            
            batchdisplay(trial_names{j},'creating zoo file')
            
            data = struct;
            data.zoosystem.Video.Channels = {};
            
            for k = 1:length(ch)
                yd = wdata.(ch{k});
                yd = yd{j};
                
                [r,c] = size(yd);                               % check size of yd for problems
                if c > 3
                    yd = yd(:,1:3);
                end
                
                if isin(ch{k},'__')
                     rr = strrep(ch{k},'__','_');
                     data = addchannel_data(data,rr,yd,'Video');       % add physical channel
                else
                    data = addchannel_data(data,ch{k},yd,'Video');       % add physical channels
                end
                
            end
            
            data.zoosystem.Video.Indx = (1:1:r)';
            data.zoosystem.Video.Freq = fsamp{j};
            data.zoosystem.SourceFile = trial_names{j};
            
            data.zoosystem.Anthro = Anthro;
            data.zoosystem.Units.Height = 'm';
            data.zoosystem.Units.Mass = 'kg';
            data.zoosystem.Units.BMI = 'kg/m^2';
            data.zoosystem.Units.Markers = 'mm';

            
            data.zoosystem.Codes.Sex.Female = 0;
            data.zoosystem.Codes.Sex.Male = 1;
            
            data.zoosystem.Codes.Level.Rec = 0;
            data.zoosystem.Codes.Level.Elite = 1;
            
            data.zoosystem.Codes.Side.Left = 0;
            data.zoosystem.Codes.Side.Right = 1;
                        
            tname = trial_names{j};
            indxx = strfind(tname,'\');  % alwayws a PC slash
            tname = tname(indxx(end)+1:end-4);
             
            if isin(tname,'upreme')
                tname = 'SUPSTATIC01';
            elseif isin(tname,'apor')
                tname = 'VAPSTATIC01';
            else
                error('bad file name')
            end
            
            zsave([spth,s,tname,'.zoo'],data);
            
        end
        
        
    end
    
end

if isin(del,'yes') || isin(del,'on')
    recycle('on')
    for i =1:length(fl)
        batchdisplay(fl{i},'deleting source file')
        delete(fl{i})
    end
end

disp(['Conversion to zoo completed in ',num2str(toc),' sec'])










