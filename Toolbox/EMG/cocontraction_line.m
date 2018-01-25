function cc= cocontraction_line(muscle1,muscle2,plotGraph)

% cc = MUSCLE_COCONTRACTION(muscle1,muscle2) computes co-contraction indices for 
%      muscle pairs (muscle 1 and muscle2)
%
% ARGUMENTS
%  muscle1      ...   n x 1 or 1 x n  vector of processed EMG data
%  muscle2      ...   n x 1 or 1 x n  vector of processed EMG data
%  plotGraph    ...   Choice to plot graph (boolean). Default false
%
% RETURNS
%  cc           ...   n x 1  vector of co-contraction indices
%
% NOTES
% - Algorithm choices: 
%   (a) Rudolph et al. 2000. Dynamic stability after ACL injury: who can hop?
%       Knee Surg Sports Traumatol Arthrosc 8, 262-269 (commented)
%    (b)Falconer, K., Winter, D., 1985. Quantitative assessment of co-contraction at the
%       ankle joint in walking. Electromyogr. Clin. Neurophysiol. 25, 135–149.
%       (This option is commented out in the code below)
% 
% Created by Philippe C. Dixon Nov 21 2017
%
% See also knee_OA_cocontraction


if nargin==2
    plotGraph = false;
end

if length(muscle1) ~=length(muscle2)
    error('vectors should be of same size')
end

[r,c] = size(muscle1);
if  c>1
    muscle1 = makecolumn(muscle1);
    muscle2 = makecolumn(muscle2);
end

cc = zeros(r,c);
for i =1:length(muscle1)
    
    m1 = muscle1(i);
    m2 = muscle2(i);
     
    if m1 < m2    % muscle 1 is lower EMG, muscle 2 is higher EMG
        low = m1;
        high = m2;
    else
        low = m2;
        high = m1;
    end
    
    if isnan(m1) || isnan(m2)
        cc(i) = NaN;
    else
        cc(i) = (low/high) * (low+high);              % Rudolph 2000
        % cc(i) = 100 * ( 2 * low ) / (low + high);   % Falconer and Winter 1985
    end
    
    
end


% Plot graph
%
if plotGraph
    plot(muscle1,'b')
    hold on
    plot(muscle2,'k');
    hold on
    plot(cc,'r','LineWidth',1.5)
end
    
    
