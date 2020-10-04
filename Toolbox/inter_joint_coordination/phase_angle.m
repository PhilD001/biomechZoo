function PA_data = Phase_Angle(r)

% PA_data = PHASE_ANGLE(angle) determines the Phase Angle for a single kinematic waveform
% using the Hilbert transform method.
%
% ARGUMENTS
%   r : n x 1 array. Kinematic data represent angle (joint or segment)
%
% RETURNS
%   PA_data : n x 1 array. Phase angle computed on input angle using the Hilbert transform
%
% NOTES
% See Lamb and Stöckl "On the use of continuous relative phase: Review of current 
% approaches and outline for a new standard". Clin Biomech 2014 
% https://doi.org/10.1016/j.clinbiomech.2014.03.008

%1) transform the signal such that it winds around the origin of the
%complex plane (see eq 11 from Lamb and Stöckl
cdata = r - min(r) - (max(r)-min(r))/2;

% 2) Hilbert transform
X=hilbert(cdata);

% 3) Phase Angle
PA_data=zeros(1,length(r));
for i=1:length(r)
    PA_data(i)=atan2(imag(X(i)),real(X(i)));
end
PA_data=rad2deg(PA_data)';

end

