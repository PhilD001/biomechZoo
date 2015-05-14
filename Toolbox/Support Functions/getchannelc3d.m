function r = getchannelc3d(c3ddata,label,varargin)
%r = getchannelc3d(c3ddata,label)
%Will get the data for an analog channel
%label = the channel label as a string eg 'FX1'
%The channel name is case sensitive and it includes any trailing blanks
%
%r = getchannelc3d(c3ddata,label,dim)
%will get the data for a Video channel
%dim = 'x','y','z',or 'all';
%
%Created by JJ Loh  2006/09/20
%Departement of Kinesiology
%McGill University, Montreal, Quebec Canada

if nargin == 2 %analog channel
    fld = fieldnames(c3ddata.AnalogData);
    for i = 1:length(fld);
        vl = getfield(c3ddata.AnalogData,fld{i});
        if strcmp(label,vl.label);
            r = vl.data;
            return
        end
    end
else  %video data
    dim = varargin{1};
    fld = fieldnames(c3ddata.VideoData);
    for i = 1:length(fld);
        vl = getfield(c3ddata.VideoData,fld{i});
        if strcmp(label,vl.label);
            switch dim
                case 'x'
                    r = vl.xdata;
                case 'y'
                    r = vl.ydata;
                case 'z'
                    r = vl.zdata;
                case 'all'
                    r = [vl.xdata,vl.ydata,vl.zdata];
            end
            return
        end
    end
end
r = [];