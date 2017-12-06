function [cc,cc_indx] = cocontraction_line(muscle1,muscle2,plotGraph)

% cc_indx = MUSCLE_COCONTRACTION(muscle1,muscle2) computes co-contraction indices for muscle 1 and muscle2
%
% ARGUMENTS
%  muscle1   ...   n x 1 or 1 x n  vector of processed EMG data
%  muscle2   ...   n x 1 or 1 x n  vector of processed EMG data
%  plotGraph ...   Choice to plot graph (boolean). Default false
%
% RETURNS
%  cc        ...   n x 1  vector of co-contraction indices
%  cc_indx   ...   sum of co contraction indices across all frames
%
% NOTES
% - Algorith based on Rudolph et al. 2000. Dynamic stability after ACL injury: who can hop?
%   Knee Surg Sports Traumatol Arthrosc 8, 262-269.
%
% Created by Philippe C. Dixon Nov 21 2017
%
% See also knee_OA_cocontraction


if nargin==2
    plotGraph = false;
end

if size(muscle1) ~=size(muscle2)
    error('vectors should be of same size')
end

[r,c] = size(muscle1);
if r==1 && c>1
    muscle1 = muscle1';
    muscle2 = muscle2';
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
    
    cc(i) = (low/high) * (high+low);
    
end

cc_indx = (1/length(cc)) * sum(cc); % NEEDS TO BE CHECKED



% Plot graph
%
if plotGraph
    plot(muscle1,'b')
    hold on
    plot(muscle2,'k');
    hold on
    plot(cc,'r','LineWidth',1.5)
end
    
    
