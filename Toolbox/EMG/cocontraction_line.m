function varargout= cocontraction_line(muscle1,muscle2,method, plotGraph)

% varargout = MUSCLE_COCONTRACTION(muscle1,muscle2) computes co-contraction indices for
%      muscle pairs (muscle 1 and muscle2)
%
% ARGUMENTS
%  muscle1      ...   n x 1 or 1 x n  vector of processed EMG data
%  muscle2      ...   n x 1 or 1 x n  vector of processed EMG data
%  method       ...   Choice of algorithm to use. Choices: 'Rudolph',
%                     'Falconer', 'Lo2017'. See notes for more details.
%  plotGraph    ...   Choice to plot graph (boolean). Default false
%
% RETURNS
%  cc (co-contraction indices)          ...   n x 1  vector of co-contraction indices 
%                                             in case of Rudolph and Falconer
% (or)
%  cc (common area curve) and cc_value  ...   (1) n x 1  vector of minima form two curves 
%                                             used to estimate co-contraction incase
%                                             of Lo2017 (2)  co-contraction value
%
% NOTES
% - Algorithm choices:
%   (a) Rudolph et al. 2000. Dynamic stability after ACL injury: who can hop?
%       Knee Surg Sports Traumatol Arthrosc 8, 262-269 (commented)
%   (b) Falconer, K., Winter, D., 1985. Quantitative assessment of co-contraction at the
%       ankle joint in walking. Electromyogr. Clin. Neurophysiol. 25, 135–149.
%       (This option is commented out in the code below)
%	(c) Justine Lo, On-Yee Lo, Erin A. Olson, Daniel Habtemariam, Ikechukwu Iloputaife, Margaret M. Gagnon, Brad Manor, Lewis A. Lipsitz,
%       Functional implications of muscle co-contraction during gait in advanced age. Gait & Posture,Volume 53,2017,Pages 110-114,
%       ISSN 0966-6362,
%       https://doi.org/10.1016/j.gaitpost.2017.01.010.
%
% Created by Philippe C. Dixon Nov 21 2017
%
% See also knee_OA_cocontraction


if nargin==2
    plotGraph = false;
    method = 'Rudolph';
elseif nargin==3
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
        
        if strcmpi(method, 'rudolph')
            cc(i) = (low/high) * (low+high);             % Rudolph 2000
            
        elseif strcmpi(method, 'falconer')
            cc(i) = 100 * ( 2 * low ) / (low + high);   % Falconer and Winter 1985
            
        elseif strcmpi(method, 'Lo2017')
            cc(i) = low;                                           % Lo  2017 cc is not a index, instead its a common area curve 
            
        else
            error(['method ', method, ' not implemented'])
        end
    end
end


if strcmpi(method, 'rudolph')||strcmpi(method, 'falconer')
    varargout{1} =cc;
    varargout{2} = 0;

elseif strcmpi(method, 'Lo2017')
    m1_area = trapz(muscle1);
    m2_area = trapz(muscle2);
    common_area = trapz(cc);
    cc_val =  2*(common_area/(m1_area+m2_area))*100;          % Lo 2017
    varargout{1} = cc;
    varargout{2} = cc_val;
    
else
    error(['method ', method, ' not implemented'])
end

% Plot graph
%
if plotGraph
    plot(muscle1,'b')
    hold on
    plot(muscle2,'k');
    hold on
    plot(cc,'-r','LineWidth',1.5)
end

