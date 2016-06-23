function r = readc3dBtk(fl)

% r = READC3DBTK(fl) reads c3d files using the BTK toolbox.
%
% ARGUMENTS
%  fl   ...   file path leading to c3d file
%
% RETURNS
%  r    ...   struct containing all c3d info
% 
% See also readc3d
%
% NOTES: 
% - BTK toolkit must be installed to run this file. Downloaded BTK  <a href="http://code.google.com/p/b-tk/">here</a> 


% Revision History
%
% Created by Philippe C. Dixon Jan 3rd 2013
% 
% Updated by Philippe C. Dixon June 23rd 2016
% - rewritten to match output of readc3d


if nargin==1
    soft = 'no';
end

H =  btkReadAcquisition(fl);

%--GET VIDEO CHANELS (INCLUDING MODEL OUTPUTS) AND ADD TO STRUCT-------
%
MarkerData = btkGetMarkers(H);
AngleData=  btkGetAngles(H);   
ForceData = btkGetForces(H);   
MomentData = btkGetMoments(H);
PowerData = btkGetPowers(H);
ScalarData = btkGetScalars(H);

MarkerCh = fieldnames(MarkerData);
AngleCh = fieldnames(AngleData);
ForceCh = fieldnames(ForceData);
MomentCh = fieldnames(MomentData);
PowerCh = fieldnames(PowerData);
ScalarCh = fieldnames(ScalarData);

for i = 1:length(MarkerCh)
    r.VideoData.(MarkerCh{i}) = MarkerData.(MarkerCh{i});
end

for i = 1:length(AngleCh)
     r.VideoData.(AngleCh{i}) = AngleData.(AngleCh{i});
end

for i = 1:length(ForceCh)
    r.VideoData.(ForceCh{i}) = ForceData.(ForceCh{i});
end

for i = 1:length(MomentCh)
     r.VideoData.(MomentCh{i}) = MomentData.(MomentCh{i});
end

for i = 1:length(PowerCh)
     r.VideoData.(PowerCh{i}) = PowerData.(PowerCh{i});
end

for i = 1:length(ScalarCh)
     r.VideoData.(ScalarCh{i}) = ScalarData.(ScalarCh{i});
end



%--GET ANALOG CHANELS (EMG AND FORCE PLATE) AND ADD TO STRUCT-------
%
r.AnalogData = btkGetAnalogs(H);



%--GET HEADER-----------------------------

r.Header.ParamterBlockNum = [];
r.Header.NumMarkers= [];
r.Header.SamplesPerFrame= [];
r.Header.FirstVideoFrame = btkGetFirstFrame(H);
r.Header.EndVideoFrame   = btkGetLastFrame(H);
r.Header.MaxIntGap= [];
r.Header.Scale= [];
r.Header.StartRecord= [];
r.Header.SamplesPerChannel = btkGetAnalogSampleNumberPerFrame(H);
r.Header.VideoHZ           = btkGetPointFrequency(H);
r.Header.LablePointer= [];


%--GET PARAMETER HEADER--------------------

r.ParameterHeader.NumberOfBlocks = 66;
r.ParameterHeader.MachineType = 84;

% GET PARAMETER------------------
%
temp = btkGetMetaData(H);
ch = fieldnames(temp.children);

for i = 1:length(ch)  
   r.Parameter.(ch{i}) = temp.children.(ch{i}).children; 
end

r.Parameter.ANALOG.RATE.data = btkGetAnalogFrequency(H);
r.Parameter.SUBJECTS.NAMES.data = r.Parameter.SUBJECTS.NAMES.info.values;

pch = {'POINT','FORCE_PLATFORM','PROCESSING','EVENT'};
for i = 1:length(pch)
    sch = fieldnames(r.Parameter.(pch{i}));
    for j = 1:length(sch)
        r.Parameter.(pch{i}).(sch{j}).data =  r.Parameter.(pch{i}).(sch{j}).info.values;
        r.Parameter.(pch{i}).(sch{j}) = rmfield( r.Parameter.(pch{i}).(sch{j}),'info');
    end
end


r.Parameter.ANALOG.LABELS.data = r.Parameter.ANALOG.LABELS.info.values;

%---CLEAR MEMORY------
btkDeleteAcquisition(H)





% fin = btkGetAnalogFrameNumber(H)+start-1;
%     MData = 

 

% 
% MarkerCh = fieldnames(MarkerData);
% AngleCh = fieldnames(AngleData);
% ForceCh = fieldnames(ForceData);
% MomentCh = fieldnames(MomentData);
% PowerCh = fieldnames(PowerData);
% ScalarCh = fieldnames(ScalarData);
% 
% for i = 1:length(MarkerCh)
%     data.(MarkerCh{i}).line = MarkerData.(MarkerCh{i});
%     data.(MarkerCh{i}).event = struct;
% end
% 
% for i = 1:length(AngleCh)
%     data.(AngleCh{i}).line = AngleData.(AngleCh{i});
%     data.(AngleCh{i}).event = struct;
% end
% 
% for i = 1:length(ForceCh)
%     data.(ForceCh{i}).line = ForceData.(ForceCh{i});
%     data.(ForceCh{i}).event = struct;
% end
% 
% for i = 1:length(MomentCh)
%     data.(MomentCh{i}).line = MomentData.(MomentCh{i});
%     data.(MomentCh{i}).event = struct;
% end
% 
% for i = 1:length(PowerCh)
%     data.(PowerCh{i}).line = PowerData.(PowerCh{i});
%     data.(PowerCh{i}).event = struct;
% end
% 
% for i = 1:length(ScalarCh)
%     data.(ScalarCh{i}).line = ScalarData.(ScalarCh{i});
%     data.(ScalarCh{i}).event = struct;
% end


% 
% AnalogCh = fieldnames(AnalogData);
% 
% for i = 1:length(AnalogCh)
%     data.(AnalogCh{i}).line = AnalogData.(AnalogCh{i});
%      data.(AnalogCh{i}).event = struct;
% end




    
%     
%     data.zoosystem.AVR = btkGetAnalogSampleNumberPerFrame(H);
% 
% % c) Header branches
% % MData = btkGetMetaData(H);
% 
% data.zoosystem.Header.TrialName = MData.children.SUBJECTS.children.NAMES.info.values{1};
% data.zoosystem.Header.Date = '';
% data.zoosystem.Header.Time = '';
% data.zoosystem.Header.Description = '';  % this remains empty
% 
% % d) Units
% data.zoosystem.Units.Markers = MData.children.POINT.children.UNITS.info.values{1};
% 
% if isfield(MData.children.POINT.children,'ANGLE_UNITS')   
%     data.zoosystem.Units.Angles = MData.children.POINT.children.ANGLE_UNITS.info.values{1};
% else
%     if isin(soft,'no')
%         error([' missing angle units for: ',fl])
%     end
% end
% 
% if isfield(MData.children.POINT.children,'FORCE_UNITS')
%     data.zoosystem.Units.Forces = MData.children.POINT.children.FORCE_UNITS.info.values{1};
% else
%  if isin(soft,'no')
%     error([' missing angle units for: ',fl])
%  end
% end
% 
% if isfield(MData.children.POINT.children,'MOMENT_UNITS')
%     data.zoosystem.Units.Moments =   MData.children.POINT.children.MOMENT_UNITS.info.values{1};
% else
%     if isin(soft,'no')
%     error([' missing angle units for: ',fl])
%     end
% end
% 
% data.zoosystem.Units.Power = 'W/kg'; % Vicon is lying MData.children.POINT.children.POWER_UNITS.info.values
% 
% if isfield(MData.children.POINT.children,'SCALAR_UNITS')
%     data.zoosystem.Units.Scalars =   MData.children.POINT.children.SCALAR_UNITS.info.values{1}; 
% else
%     
%     if isin(soft,'no')
%     error([' missing Scalar unit info for:',fl])  
%     end
% end
% 
% % e) Force plate info
% data.zoosystem.Analog.FPlates.CORNERS =  MData.children.FORCE_PLATFORM.children.CORNERS.info.values;
% data.zoosystem.Analog.FPlates.LOCALORIGIN = MData.children.FORCE_PLATFORM.children.ORIGIN.info.values;
% 
% % Anthro channels
% if isfield(MData.children,'PROCESSING')
%     
%     ach = fieldnames(MData.children.PROCESSING.children);
%     
%     for i = 1:length(ach)
%         data.zoosystem.Anthro.(ach{i}) =  MData.children.PROCESSING.children.(ach{i}).info.values;
%     end
%     
% else
%    error([' missing processing info for: ',fl])
% 
% %     error('trial missing processing info')
% %     data.zoosystem.Anthro = struct;
% end
% 
% % f) source file
% data.zoosystem.SourceFile = fl;
% 
% 
% % g) extract event data------
% % 
% events = btkGetEvents(H);
% ech = fieldnames(events);
% 
% for i= 1:length(ech)
%     
%    for j = 1:length(events.(ech{i}))
%        
%        frame = round(events.(ech{i})(j)*vidfreq) - data.zoosystem.Video.ORIGINAL_START_FRAME(1) +1;
%        data.SACR.event.([ech{i},num2str(j)]) = [frame 0 0];
%     
%    end
% end
% 
% 
% % h) version number
% data.zoosystem.Version = '1.2';




