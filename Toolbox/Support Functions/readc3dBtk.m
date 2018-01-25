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
%
% Updated by Philippe C. Dixon Nov 2016
% - more clean up to match output of readc3cd
%
% Updated by Philippe C. Dixon Dec 2017
% - bug fix for marker data with gaps. BtkGetMarker will return 0 for gaps,
%   these are transformed to NaNs 


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
    temp = MarkerData.(MarkerCh{i});
    indx = find(temp(:,1)==0);
    if ~isempty(indx)
        temp(indx,:)=NaN;
    end
    r.VideoData.(MarkerCh{i}) =temp;
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



%--GET GRF DATA AND ADD TO STRUCT-------
%
fplates = btkGetForcePlatforms(H);
nplates = length(fplates);
AnalogData = btkGetGroundReactionWrenches(H);
dims = {'x','y','z'};

for j = 1:nplates
    F = -AnalogData(j).F;
    M = -AnalogData(j).M;
    P = AnalogData(j).P;
    
    for k = 1:length(dims)
        r.AnalogData.(['F',dims{k},num2str(j)]) = F(:,k);
        r.AnalogData.(['M',dims{k},num2str(j)]) = M(:,k);
    end
    
    r.AnalogData.(['P',num2str(j)]) = P;
    
end


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

if isfield(r.Parameter,'SUBJECTS')
    r.Parameter.SUBJECTS.NAMES.data = r.Parameter.SUBJECTS.NAMES.info.values{1};
else
    r.Parameter.SUBJECTS.NAMES.data =[];
end

pch = {'POINT','FORCE_PLATFORM','PROCESSING','EVENT'};
for i = 1:length(pch)
    if isfield(r.Parameter,pch{i})
        sch = fieldnames(r.Parameter.(pch{i}));
        for j = 1:length(sch)
            r.Parameter.(pch{i}).(sch{j}).data =  r.Parameter.(pch{i}).(sch{j}).info.values;
            r.Parameter.(pch{i}).(sch{j}) = rmfield( r.Parameter.(pch{i}).(sch{j}),'info');
        end
    else
        r.Parameter.(pch{i}).(sch{j}).data = [];
    end
end


r.Parameter.ANALOG.LABELS.data = r.Parameter.ANALOG.LABELS.info.values;

%---CLEAR MEMORY------
btkDeleteAcquisition(H)





