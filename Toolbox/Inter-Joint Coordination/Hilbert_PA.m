function [PA_dataH] = Hilbert_PA(data)
%Hilbert_PA 
% Function to get the Phase Angle using the Hilbert Transform
%   Input
%       data = angle data in the time domain
%   Output
%       PA_dataH = phase angle of data

L=length(data);
n=10; %10% of sampling F (1000/10)

% 1) centre the data around zero
%cdata = data - min(data) - (max(data)-min(data))/2;

cdata = data - min(data(n+1:end-n)) - (max(data(n+1:end-n))-min(data(n+1:end-n)))/2;

% Hilbert transform
X=hilbert(cdata);

% 3) Phase Angle
PA_dataH=zeros(1,L);
for i=1:L
    PA_dataH(i)=atan2(imag(X(i)),real(X(i)));
end
PA_dataH=rad2deg(PA_dataH);

end

