function [PA_data] = phase_angle(angle,event1,event2)

% PHASE_ANGLE determines the phase angle for a single kinematic waveform using the Hilbert transform method. 
% 
% ARGUMENTS
% angle   ...   1 x n angle data for a given joint
% event1  ...   start of section of interest for angle data
% event2  ...   end of section of interest for angle data
%
% RETURN
% PA_data ...   phase anle data

% Created by Patrick Ippersiel March 2020

if nargin == 3
    data = angle;
    L=length(data);
    
    %1) Centre data around 0
    cdata = data - min(data) - (max(data)-min(data))/2;

    % 2) Hilbert transform on the area of interest
    X = zeros(1,L);
    X(event1: event2) = hilbert(cdata(event1:event2));

    % 3) Phase Angle
    PA_data=zeros(1,L);
    for i=event1:event2
        PA_data(i)=atan2(imag(X(i)),real(X(i)));
    end
    PA_data=rad2deg(PA_data);
else
    data=angle;
    L=length(data);
    
    %1) Centre data around 0
    cdata = data - min(data) - (max(data)-min(data))/2;

    % 2) Hilbert transform
    X=hilbert(cdata);

    % 3) Phase Angle
    PA_data=zeros(1,L);
    for i=1:L
        PA_data(i)=atan2(imag(X(i)),real(X(i)));
    end
    PA_data=rad2deg(PA_data);
end

PA_data = makecolumn(PA_data);


