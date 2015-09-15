function data = c3d2zoo(fld,del)

% C3D2ZOO  Converts .c3d files to .zoo format
%
% ARGUMENTS
%  fld  ...   path leading to folder to operate on
%  del  ...   option to delete original c3d file after creating zoo file. Default 'no'
%
% RETURNS
%  data  ...  zoo system data. This return is mostly used by 'director'


% NOTES:
%  - channels with names containing '*' or '#' are removed (these are usually
%    unlabled trajectories)
%  - attempts to fix invalid fielnames (see makevalidfield.m)


% Revision History
%
% Created by JJ Loh 2006
%
% Updated by Philippe C. Dixon Nov 2008
% - reorganised to mach zoo system
%
% Updated by Philippe C. Dixon May 2014
% - This function has been reintroduced as the main c3d converter after recent update
%   of the readc3d function by JJ Loh
% - reintroduction of the 'return' of the function for use with director
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Dr. Philippe C. Dixon, Harvard University. Boston, USA.
% Yannick Michaud-Paquette, McGill University. Montreal, Canada.
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
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 


% SET DEFAULTS ---------------------------------------------------------------------------
%
tic                                                                          % start timer

if nargin==0
    fld = uigetfolder;
    del = 'no';
end

if nargin==1
    del = 'no';
end

if isin(fld,'.c3d')      % for a single trial (e.g. loading c3d in director)
    pth = fileparts(fld);
    fl= {fld};
    fld = pth;
    sf = 0; % do not save output to zoo file
else
    fl = engine('path',fld,'extension','c3d');
    sf = 1;
end

cd(fld)

% FIND AND LOAD .C3D FILES-----------------------------------------------------------------
%
for i = 1:length(fl)
    
    % Extract info from c3d file
    %
    batchdisplay(fl{i},'converting to zoo');
    r = readc3d(fl{i});
    zfl = extension(fl{i},'zoo');
    data = struct;
    vfld = fieldnames(r.VideoData);
    afld = fieldnames(r.AnalogData);
    
    vlbl = cell(size(vfld));
    albl = cell(size(afld));
    
    % Add video channels to data struct
    %
    for v = 1:length(vfld)
        
        lbl = makevalidfield(r.VideoData.(vfld{v}).label);                                      % fixes invalid fieldnames
        
        if ~ismember(lbl,{'numbersign''star'})
            
            data.(lbl).line = [makecolumn(r.VideoData.(vfld{v}).xdata),...
                makecolumn(r.VideoData.(vfld{v}).ydata),...
                makecolumn(r.VideoData.(vfld{v}).zdata)];
            
            data.(lbl).event = struct;
            vlbl{v} = lbl;
        end
        
    end
    
    % Add analog channels to data struct
    %
    if ~isempty(afld)                                                   % add analog channels (if present)
        
        for a = 1:length(afld)
            
            lbl = makevalidfield(r.AnalogData.(afld{a}).label);                                  % fixes all invalid fieldnames
            
            if ~ismember(lbl,{'numbersign''star'})
                data.(lbl).line = makecolumn(r.AnalogData.(afld{a}).data);
                data.(lbl).event = struct;
                albl{a} = lbl;
            end
        end
        
    end
    
    % Add Video/Analog metainformation to zoosystem branch of data struct
    %
    vidFreq =  r.Header.VideoHZ;
    
    if isfield(r.Parameter,'ANALOG')
        analFreq = r.Parameter.ANALOG.RATE.data;
    else
        analFreq = 0;
    end
    
    AVR =   analFreq/vidFreq;
    
    startVid = r.Header.FirstVideoFrame;                                % write zoo system info
    finVid = r.Header.EndVideoFrame;
    
    startAnal = startVid*AVR;
    finAnal = finVid*AVR;
    
    data.zoosystem.Video.Indx = makecolumn(linspace(startVid,finVid,(finVid-startVid+1))) ;
    data.zoosystem.Video.ORIGINAL_START_FRAME = [startVid finVid];
    data.zoosystem.Video.ORIGINAL_END_FRAME = [finVid 0 0];
    data.zoosystem.Video.CURRENT_START_FRAME = [1 0 0];
    data.zoosystem.Video.CURRENT_END_FRAME = [finVid-startVid+1 0 0];
    data.zoosystem.Video.Freq= vidFreq;
    data.zoosystem.Video.Channels = vlbl;
    
    data.zoosystem.Analog.Indx  =  makecolumn(linspace(startAnal,finAnal,(finAnal-startAnal+1))) ;
    data.zoosystem.Analog.ORIGINAL_START_FRAME = [startAnal 0 0];
    data.zoosystem.Analog.ORIGINAL_END_FRAME = [finAnal 0 0];
    data.zoosystem.Analog.CURRENT_START_FRAME = [1 0 0];
    data.zoosystem.Analog.CURRENT_END_FRAME = [finAnal-startAnal+1 0 0];
    data.zoosystem.Analog.Freq= analFreq;
    data.zoosystem.Analog.Channels =  albl;
    
    data.zoosystem.AVR = AVR;
    
    data.zoosystem.Header.SubName =  makerow(r.Parameter.SUBJECTS.NAMES.data);
    data.zoosystem.Header.Date = '';
    data.zoosystem.Header.Time = '';
    data.zoosystem.Header.Description = '';  % this remains empty
    
    % Add unit metainformation (if available) to zoosystem branch of data struct
    %
    data.zoosystem.Units.Markers =  makerow(r.Parameter.POINT.UNITS.data);
    
    if isfield(r.Parameter.POINT,'ANGLE_UNITS')
        data.zoosystem.Units.Angles = makerow(r.Parameter.POINT.ANGLE_UNITS.data);
    else
        disp([' missing angle units for: ',fl{i}])
    end
    
    if isfield(r.Parameter.POINT,'FORCE_UNITS')
        data.zoosystem.Units.Forces = makerow(r.Parameter.POINT.FORCE_UNITS.data);
    else
        disp([' missing angle units for: ',fl{i}])
    end
    
    if isfield(r.Parameter.POINT,'MOMENT_UNITS')
        data.zoosystem.Units.moments =   makerow(r.Parameter.POINT.MOMENT_UNITS.data);
    else
        disp([' missing angle units for: ',fl{i}])
    end
    
    data.zoosystem.Units.Power = 'W/kg'; % Vicon is lying r.Parameter.POINT.POWER_UNITS
    
    if isfield(r.Parameter.POINT,'SCALAR_UNITS')
        data.zoosystem.Units.Scalars =  makerow(r.Parameter.POINT.SCALAR_UNITS.data);
    else
        disp([' missing Scalar unit info for:',fl{i}])
    end
    
    % Add force plate metainformation to zoosystem branch of data struct
    %
    if isfield(r.Parameter,'FORCE_PLATFORM')
        
        a =r.Parameter.FORCE_PLATFORM.CORNERS.data;
        a= reshape(a,3,[]);
        ln = length(a);
        
        if ln==4
            b(:,:,1) = a(:,:);
            
        elseif ln==8
            b(:,:,1) = a(:,1:ln/2);
            b(:,:,2) = a(:,ln/2+1:end);
            
        elseif ln==12;
            b(:,:,1) = a(:,1:ln/3);
            b(:,:,2) = a(:,ln/3+1:2*ln/3);
            b(:,:,3) = a(:,2*ln/3+1:end);
        else
            disp('unknown number of force plates')
            b = [];
        end
        
        if ~isempty(b)
            data.zoosystem.Analog.FPlates.CORNERS = b;
            data.zoosystem.Analog.FPlates.LOCALORIGIN = r.Parameter.FORCE_PLATFORM.ORIGIN.data;
        else
            data.zoosystem.Analog.FPlates.CORNERS = [];
            data.zoosystem.Analog.FPlates.LOCALORIGIN = [];
        end
    end
    
    % Add anthro metainformation (if available) to zoosystem branch of data struct
    %
    data.zoosystem.Anthro = struct;
    
    if isfield(r.Parameter,'PROCESSING')
        ach = setdiff(fieldnames(r.Parameter.PROCESSING),{'id','islock'});
        
        for j = 1:length(ach)
            rr = r.Parameter.PROCESSING.(ach{j});
            
            if isstruct(rr)
                rr = rr.data;
            end
            
            data.zoosystem.Anthro.(ach{j}) =  rr;
        end
        
    else
        disp([' missing processing info for: ',fl{i}])
    end
    
    % Add source file metainformation to zoosystem branch of data struct
    %
    data.zoosystem.SourceFile = fl{i};
    
    % Add zoosystem version number to zoosystem branch of data struct
    %
    data.zoosystem.Version = '1.2';
    
    % Add events metainformation (if available) to zoosystem branch of data struct
    %
    if isfield(r.Parameter.EVENT,'TIMES')
        
        if ~isempty(r.Parameter.EVENT.TIMES.data)
        
        times = r.Parameter.EVENT.TIMES.data(2,:);
        sides = r.Parameter.EVENT.CONTEXTS.data;
        type =  r.Parameter.EVENT.LABELS.data;
        
        [rows,cols] = size(sides);
        
        stk = zeros(1,cols);
        events = struct;
        
        for s = 1:cols
            ech = [sides(:,s)','_',type(:,s)'];
            ech = strrep(ech,' ','');
            events.(ech).lines(s) = times(s);
        end
        
        ech = fieldnames(events);
        
        for e = 1:length(ech)
            temp = sort(events.(ech{e}).lines);
            indx = find(temp==0);
            temp(indx) = [];
            events.(ech{e}) = temp;   % this output should match  btkGetEvents(H)
            
            for j = 1:length(events.(ech{e}))
                
                frame = round(events.(ech{e})(j)*vidFreq) - data.zoosystem.Video.ORIGINAL_START_FRAME(1) +1;
                if ~isfield(data,'SACR')
                    data.(vlbl{1}).event.([ech{e},num2str(j)]) = [frame 0 0];
                else
                    data.SACR.event.([ech{e},num2str(j)]) = [frame 0 0];
                end
                
            end
            
        end
        end
    end
    
    % Empty field for computed meta data in matlab
    %
    data.zoosystem.CompInfo = struct;
    
    
    % Save all finto to file
    %
    if sf==1
        % save(zfl,'data');  % original save
        zsave(zfl,data)
    end
    
    if isin(del,'yes') || isin(del,'on')
        delete(fl{i})
    end
    
    
end

%---SHOW END OF PROGRAM-------------------------------------------------------------------------
%
disp(' ')
disp('**********************************')
disp('Finished converting data in: ')
toc
disp('**********************************')


