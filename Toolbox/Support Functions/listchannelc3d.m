function varargout = listchannelc3d(data)
% 
% [video,analog] = listchannelc3d(c3ddata)
%
% This function will output the video and analog channels as a cell array of strings
%
% Created by JJ Loh  2006/09/20
% Departement of Kinesiology
% McGill University, Montreal, Quebec Canada
%
% Updated by Philippe C. Dixon
% - can be used with zoosystem v1.2 files

if isfield(data,'AnalogData')   % backwards comp
    
    Afld = fieldnames(data.AnalogData);
    Vfld = fieldnames(data.VideoData);
    
    vch = [];
    ach = [];
    
    for i = 1:length(Afld);
        vl = getfield(data.AnalogData,Afld{i});
        ach = [ach;{vl.label}];
    end
    
    for i = 1:length(Vfld);
        vl = getfield(data.VideoData,Vfld{i});
        vch = [vch;{vl.label}];
    end
    
    varargout{1} = vch;
    varargout{2} = ach;
    
else   % v1.2
    
    varargout{1} =  data.zoosystem.Video.Channels;
    varargout{2} = data.zoosystem.Analog.Channels;
end