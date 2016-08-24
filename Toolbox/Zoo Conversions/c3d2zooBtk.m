function data = c3d2zooBtk(fld,del)

% data = C3D2ZOOBTK(fld, del) converts .c3d files to .zoo format using the BTK c3d reader
%
% ARGUMENTS
%  fld  ...   path leading to folder to operate on
%  del  ...   option to delete original c3d file after creating zoo file. Default 'no'
%
% RETURNS
%  data  ...  zoo system data. This return is mostly used by 'director'
%
% See also c3d2zoo, readc3dBTK, readc3d
%
% NOTES: 
% - BTK toolkit must be installed to run this file. Downloaded BTK  <a href="http://code.google.com/p/b-tk/">here</a> 


% Revision History
%
% Created by Philippe C. Dixon June 2016
% - based on c3d2zoo, but with small changes to deal with differences in the output
%   format between readc3dBTK and readc3d  



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
    
    r = readc3dBtk(fl{i});
    
    zfl = extension(fl{i},'zoo');
    data = struct;
    vfld = fieldnames(r.VideoData);
    afld = fieldnames(r.AnalogData);
    
    vlbl = cell(size(vfld));
    albl = cell(size(afld));
    
    % Add video channels to data struct
    %
    
    for v = 1:length(vfld)
        
        lbl = makevalidfield(vfld{v});                 % fixes invalid fieldnames
        
        if isfield(data,lbl)
            disp(['WARNING: Repeated channel name ',lbl, ' to be renamed ',lbl,num2str(v)])
            lbl = [lbl,num2str(v)];  
        end
        
        data.(lbl).line = r.VideoData.(vfld{v});
        data.(lbl).event = struct;
        vlbl{v} = lbl;
        
    end
    
    % Add analog channels to data struct
    %
    if ~isempty(afld)                                                   % add analog channels (if present)
        
        for a = 1:length(afld)
            
            lbl = makevalidfield(afld{a});                                  % fixes all invalid fieldnames
            
            if isfield(data,lbl)
                disp(['WARNING: Repeated channel name ',lbl, ' to be renamed ',lbl,num2str(v)])
                lbl = [lbl,num2str(v)];
            end
            
            data.(lbl).line = r.AnalogData.(afld{a});
            data.(lbl).event = struct;
            albl{a} = lbl;
        end
        
    end
    
    % Add Video/Analog metainformation 
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
    
    data.zoosystem.Header.SubName =  makerow(deblank(r.Parameter.SUBJECTS.NAMES.data));
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
        data.zoosystem.Units.Moments =   makerow(r.Parameter.POINT.MOMENT_UNITS.data);
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
        
        b = zeros(3,4,ln/4);
        
        for j = 1:ln/4
           
            if j ==1
                b(:,:,1) = a(:,1:4);
            else
                b(:,:,j) = a(:,4*(j-1)+1:4*j);
            end
            
          
        end
             
        if ~isempty(b)
            
            data.zoosystem.Analog.FPlates.CORNERS = b;
            
            data.zoosystem.Analog.FPlates.LOCALORIGIN = r.Parameter.FORCE_PLATFORM.ORIGIN.data;
            
            data.zoosystem.Analog.FPlates.NUMUSED = r.Parameter.FORCE_PLATFORM.USED.data;
            
            a = r.Parameter.ANALOG.LABELS.data;
            
            temp = r.Parameter.FORCE_PLATFORM.USED.data*6;
            
            data.zoosystem.Analog.FPlates.LABELS = a(1:temp);

            
        else
            data.zoosystem.Analog.FPlates.CORNERS = [];
            data.zoosystem.Analog.FPlates.LOCALORIGIN = [];
            data.zoosystem.Analog.FPlates.NUMUSED = 0;
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
    if isfield(r.Parameter,'EVENT')
        
        if isfield(r.Parameter.EVENT,'TIMES')
            
            if ~isempty(r.Parameter.EVENT.TIMES.data)
                
                times = r.Parameter.EVENT.TIMES.data(2,:);
                sides = r.Parameter.EVENT.CONTEXTS.data;
                type =  r.Parameter.EVENT.LABELS.data;
                
                [rows,cols] = size(sides);
                
                stk = zeros(1,cols);
                events = struct;
                
                for s = 1:cols
                    ech = [sides{s},'_',type{s}];
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
        
    end
    
    
    % KEEP COPY OF ALL META INFO
    %
    mch = setdiff(fieldnames(r),{'VideoData','AnalogData'});
    
    for m = 1:length(mch)
        data.zoosystem.OriginalC3dMetaInfo.(mch{m}) = r.(mch{m});
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


