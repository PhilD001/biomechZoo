function Euler=eulercom(LKIN,COM,fsamp)


%   EULER creates euler transformations. 
%   
%   ARGUMENTS
%   
%   LKIN    ...   segment embedded coordinate systems
%
%   RETURNS
%
%   Euler  ...   structured array containing phi, theta, psi angles for
%                each segment
%
%   NOTES
%   1) Steps in Euler   a) move COM of segment to origin of global (XYZ)
%                       b) define line of nodes L
%                       c) perform the three rotations: phi, theta, psi
%
% Updated Jan 4th 2007
% - Euler angle output is in radians

%------------GLOBAL COORDINATES---------



d = size(LKIN.Segment.RightThigh.Axes.k);
empty = zeros(d(1),1);          %column of zeros the length of sampling points

unity = ones(d(1),1);           %column of ones the length of sampling points

I = [unity empty empty];      % n x 3 matrix
K = [empty empty unity];




%-------displace LCS from COM to GCS origin-----

% 
% 
% segment = fieldnames(COM.Segment); 
% 
% 
% 
% for a = 1:length(segment)
% 
% LKIN.Segment.(segment{a}).Axes.i = displace(LKIN.Segment.(segment{a}).Axes.i ,-COM.Segment.(segment{a}).Pos);
% LKIN.Segment.(segment{a}).Axes.j = displace(LKIN.Segment.(segment{a}).Axes.j ,-COM.Segment.(segment{a}).Pos);
% LKIN.Segment.(segment{a}).Axes.k = displace(LKIN.Segment.(segment{a}).Axes.k ,-COM.Segment.(segment{a}).Pos);
% 
% 
% end


%----------------Creation of line of nodes (L)------

% k_pelvis = LKIN.Segment.Pelvis.kpelvis;
% Lpelvis = cross(L,kpelvis,2);

% create line of nodes    (K x k) / |K x k|

i1 = makeunit(LKIN.Segment.RightThigh.Axes.i);
k1 = makeunit(LKIN.Segment.RightThigh.Axes.k);            %Right Thigh
L1 = makeunit(cross(K,k1,2));                         %   L is n x 3 matrix

i2 = makeunit(LKIN.Segment.LeftThigh.Axes.i);
k2 = makeunit(LKIN.Segment.LeftThigh.Axes.k);             %Left Thigh
L2 = makeunit(cross(K,k2,2));

i3 = makeunit(LKIN.Segment.RightShank.Axes.i);
k3 = makeunit(LKIN.Segment.RightShank.Axes.k);            %Righ shank
L3 = makeunit(cross(K,k3,2));

i4 = makeunit(LKIN.Segment.LeftShank.Axes.i);
k4 = makeunit(LKIN.Segment.LeftShank.Axes.i);             %Left shank
L4 = makeunit(cross(K,k4,2));

i5 = makeunit(LKIN.Segment.RightFoot.Axes.i);
k5 = makeunit(LKIN.Segment.RightFoot.Axes.k);            %Right foot
L5 = makeunit(cross(K,k5,2));

i6 = makeunit(LKIN.Segment.LeftFoot.Axes.i);
k6 = makeunit(LKIN.Segment.LeftFoot.Axes.k);             %left foot
L6 = makeunit(cross(K,k6,2));

%---------------EULER ROTATIONS----------

phi_rthigh = ( asin( dot(cross(I,L1,2),K,2)));       %   ( (I x L) * k )
theta_rthigh = (asin ( dot(cross(K,k1,2),L1,2)));
psi_rthigh = (asin ( dot(cross(L1,i1,2),k1,2)));

phi_lthigh = (asin( dot(cross(I,L2,2),K,2)));      
theta_lthigh = (asin ( dot(cross(K,k2,2),L2,2)));
psi_lthigh = (asin ( dot(cross(L2,i2,2),k2,2)));

phi_rshank = (asin( dot(cross(I,L3,2),K,2)));      
theta_rshank = (asin ( dot(cross(K,k3,2),L3,2)));
psi_rshank = (asin ( dot(cross(L3,i3,2),k3,2)));

phi_lshank = (asin( dot(cross(I,L4,2),K,2)));      
theta_lshank =( asin ( dot(cross(K,k4,2),L4,2)));
psi_lshank = (asin ( dot(cross(L4,i4,2),k4,2)));

phi_rfoot = (asin( dot(cross(I,L5,2),K,2)));      
theta_rfoot = (asin ( dot(cross(K,k5,2),L5,2)));
psi_rfoot = (asin ( dot(cross(L5,i5,2),k5,2)));

phi_lfoot = (asin( dot(cross(I,L6,2),K,2)));      
theta_lfoot = (asin ( dot(cross(K,k6,2),L6,2)));
psi_lfoot = (asin ( dot(cross(L6,i6,2),k6,2)));


%---------------SMOOTH EULER ANGLES--------------
% 
% 
% phi_rthigh = my_filter(phi_rthigh,fsamp);
% theta_rthigh =my_filter(theta_rthigh,fsamp);
% psi_rthigh = my_filter(psi_rthigh,fsamp);
% 
% phi_lthigh =    my_filter(phi_lthigh,fsamp);   
% theta_lthigh =  my_filter(theta_lthigh,fsamp);  
% psi_lthigh =  my_filter(psi_lthigh,fsamp);  
% 
% phi_rshank =    my_filter(phi_rshank,fsamp);     
% theta_rshank = my_filter(theta_rshank,fsamp);   
% psi_rshank = my_filter(psi_rshank,fsamp);   
% 
% phi_lshank =  my_filter(phi_lshank,fsamp);    
% theta_lshank = my_filter(theta_lshank,fsamp);
% psi_lshank = my_filter(psi_lshank,fsamp);
% 
% phi_rfoot =    my_filter(phi_rfoot,fsamp);   
% theta_rfoot = my_filter(theta_rfoot,fsamp); 
% psi_rfoot =  my_filter(psi_rfoot,fsamp); 
% 
% phi_lfoot =       my_filter(phi_lfoot,fsamp); 
% theta_lfoot =    my_filter(theta_lfoot,fsamp);
% psi_lfoot =      my_filter(psi_lfoot,fsamp);


%------------------EXPORT AS STRUCT ARRAY-------

Euler = struct;

Euler.RightThigh = [phi_rthigh theta_rthigh psi_rthigh];
Euler.LeftThigh = [phi_lthigh theta_lthigh psi_lthigh];
Euler.RightShank = [phi_rshank theta_rshank psi_rshank];
Euler.LeftShank = [phi_lshank theta_lshank psi_lshank];
Euler.RightFoot = [phi_rfoot theta_rfoot psi_rfoot];
Euler.LeftFoot = [phi_lfoot theta_lfoot psi_lfoot];





function r = displace(m,vec)

if isempty(m) || isempty(vec)
    r = m;
    return
end
r(:,1) = m(:,1)+vec(1);
r(:,2) = m(:,2)+vec(2);
r(:,3) = m(:,3)+vec(3);


function fdata = my_filter(data,fsamp,cutoff)

%   Function MY_FILTER runs a number of possible filters
%
%   Notes
%   1)This is really JJs filter in standalone form


%-----------settings for current filter----------

myfilt.type = 'butterworth';
myfilt.order = 4;
myfilt.pass = 'lowpass';
myfilt.smprate = fsamp;

if nargin <3
    cutoff = 10; %default setting
end
myfilt.cut1 = cutoff;






fdata = filterline(data,myfilt);

%

function fdata = filterline(data,myfilt)

%structure of myfilt is
%myfilt.type
%myfilt.pass
%myfilt.order
%myfilt.smprate
%myfilt.cut1
%myfilt.cut2
%myfilt.srip
%myfilt.prip

% myfilt.type chooses filter type
% 'butterworth'
% 'chebychev I'
% 'chebychev II'
% 'eliptic'
% 'bessel'

% myfilt.pass chooses filter pass
% 'lowpass'
% 'highpass'
% 'bandpass'
% 'notch'


if strcmp(myfilt.pass,'bandpass')| strcmp(myfilt.pass,'notch')
    coff = [min([myfilt.cut1;myfilt.cut2]),max([myfilt.cut1;myfilt.cut2])];
else
    coff = myfilt.cut1;
end

coff = coff/(myfilt.smprate/2);
st = 'stop';
hi = 'high';

switch myfilt.type 
case 'butterworth'
    switch myfilt.pass
    case 'lowpass'
        [b,a] = butter(myfilt.order,coff);
    case 'bandpass'
        [b,a] = butter(myfilt.order,coff);
    case 'notch'
        [b,a] = butter(myfilt.order,coff,st);
    case 'highpass'
        [b,a] = butter(myfilt.order,coff,hi);
    end
case 'chebychev I'
    switch myfilt.pass
    case 'lowpass'
        [b,a] = cheby1(myfilt.order,myfilt.srip,coff);
    case 'bandpass'
        [b,a] = cheby1(myfilt.order,myfilt.srip,coff);
    case 'notch'
        [b,a] = cheby1(myfilt.order,myfilt.srip,coff,st);
    case 'highpass'
        [b,a] = cheby1(myfilt.order,myfilt.srip,coff,hi);
    end
case 'chebychev II'
    switch myfilt.pass
    case 'lowpass'
        [b,a] = cheby2(myfilt.order,myfilt.srip,coff);
    case 'bandpass'
        [b,a] = cheby2(myfilt.order,myfilt.srip,coff);
    case 'notch'
        [b,a] = cheby2(myfilt.order,myfilt.srip,coff,st);
    case 'highpass'
        [b,a] = cheby2(myfilt.order,myfilt.srip,coff,hi);
    end
case 'eliptic'
    switch myfilt.pass
    case 'lowpass'
        [b,a] = ellip(myfilt.order,myfilt.prip,myfilt.sripple,coff);
    case 'bandpass'
        [b,a] = ellip(myfilt.order,myfilt.prip,myfilt.sripple,coff);
    case 'notch'
        [b,a] = ellip(myfilt.order,myfilt.prip,myfilt.sripple,coff,st);
    case 'highpass'
        [b,a] = ellip(myfilt.order,myfilt.prip,myfilt.sripple,coff,hi);
    end
case 'bessel'
    switch myfilt.pass
    case 'lowpass'
        [b,a] = besself(myfilt.order,coff);
    case 'bandpass'
        [b,a] = besself(myfilt.order,coff);
    case 'notch'
        [b,a] = besself(myfilt.order,coff,st);
    case 'highpass'
        [b,a] = besself(myfilt.order,coff,hi);
    end
end
rindx = find(~isnan(data));
lim = [min(rindx),max(rindx)];
if isempty(lim)
    fdata = data;
    return
end
if lim(1)+myfilt.order*3 >= lim(2)
    fdata = data;
else
    chunk = data(lim(1):lim(2));
    nindx = find(isnan(chunk));
    if ~isempty(nindx);
        xd = (1:length(chunk));
        rindx = find(~isnan(chunk));
        ixd = xd(nindx);
        xd = xd(rindx);
        yd = chunk(rindx);
        nyd = interp1(xd,yd,ixd,'spline');
        chunk(nindx) = nyd;
    end
    fdata = zeros(size(data))*NaN;
    fdata(lim(1):lim(2)) = filtfilt(b,a,chunk);
end




