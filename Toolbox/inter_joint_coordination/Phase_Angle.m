function [PA_data] = Phase_Angle(angle,event1,event2)

%This function determines the Phase Angle for a single kinematic waveform
%using the Hilbert transform method.  Event1 and Event2 correspond to
%segment of interest (to incorporate data padding if required)

if nargin == 3
    temp_length=(event1:event2);
    data=(angle(temp_length));
    L=length(data);
    
    %1) Centre data around 0
    cdata = data - min(data) - (max(data)-min(data))/2;

    % 2) Hilbert transform
    X=hilbert(cdata);

    % 3) Phase Angle
    % PA_data=zeros(1,L);
    PA_data = zeros(size(angle));
    for i=1:L
        PA_data(i+event1)=atan2(imag(X(i)),real(X(i)));
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

