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
%   for general use


% Revision History
%
% Created by Philippe C. Dixon Jan 2015 based on 'Import_data_visual3d'
% from Shawn Robbins


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



% Set defaults
%
tic
del = 'off';

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
if ~isin(fld(end),slash)
    fld = [fld,slash];
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
                     data = addchannel(data,rr,yd,'Video');       % add physical channel
                else
                    data = addchannel(data,ch{k},yd,'Video');       % add physical channels
                end
                
            end
            
            for k = 1:length(ech)
                evt = ddata.(ech{k});
                evt = round(evt{j}*fsamp{j}+1);                  % convert event time to frame
                
                if isempty(evt)
                    disp(['empty event field for ',ech{k}])
                    evt = 999;
                else
                    
                    if length(evt)~=1 
                        disp(['event problem for ',ech{k}])
                        evt = 999;
                    end
                    
                end
                
                data.(ch{indx}).event.(ech{k}) = [evt 0 0 ];
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
             
            save([spth,slash,tname,'.zoo'],'data');
            
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










