function [CIlo, CIhi, SE,CIw,stat] =  bmech_CI(data,type,alpha,normal)

% [CIlow, CIhigh, SE, CIw, stat] =  bmech_CI(data,type,alpha,normal) computes confidence interval for
% unidimension data 
%
% ARGUMENTS
%  data   ...   r x c matrix where CI are computed columnwise
%  type   ...   computes CI about mean (arithmetic) or median. Default mean.
%  alpha  ...   significance level. Default 0.05
%  normal ...   normality of data. 'Yes' or 'no'. In case of 'no' non parametric CI built 
%
% RETURNS
%  CIlow  ...  lower limit of confidence interval
%  CIhigh ...  upper limit of confidence interval
%  SE     ...  standard error
%  CIw    ...  half width of CI
%  stat   ...  mean or median of data
%
%
% NOTES
% - for parametric data, CI built using standard formula :  xbar +/- t*(SD)/n
% - For non-parametric data. Approximate CI given using median and rank 
%  (see Gibbons 1993 "Nonparametric statistics" table B)
%  


% Revision History
%
% Created by Philippe C. Dixon January 31st 2012
%
% Updated by Philippe C. Dixon May 25th 2014 
% - Computes confidence interval according to t-statistic (instead of
%   standard gaussian 1.96) for better agreement with statistical tests
%   performed in SPSS.
% - Also outputs standard error (SE)


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
% 
% Contact: 
% philippe.dixon@gmail.com
%
% Web: 
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis 
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in 
% Aduts and Children. Rome, Italy.Sept 29-Oct 4th 2014. 


% Set defaults
%
if nargin==1
    type = 'mean';
    alpha = 0.05;
    normal = 'yes';
end

if nargin==2
    alpha = 0.05;
    normal= 'yes';
end

if nargin==3
    normal = 'yes';
end


% Compute type of average
%
[r,~] = size(data);

switch type
    
    case 'median'
        stat = nanmedian(data);
        
    case 'mean'
        stat= nanmean(data);
end


% Compute standard deviation
%
SD = nanstd(data);


% Compute Confidence Interval
%
df = r-1;
t = tinv(1-alpha/2,df);
SE = SD/sqrt(r);


if isin(normal,'yes')
    
    CIw = t*SE;
    
    CIlo  = stat - CIw;
    CIhi = stat + CIw;
    
else
    n = length(data);
    
    rank = findrank(n,t);
    
    data_sort = sort(data);
    
    CIlo = data_sort(rank);
    
    if rank ~=1
        CIhi = data_sort(n-rank);
    else
        CIhi = data_sort(n);
    end
    
    
    CIw = NaN;
    
end


function rank = findrank(n,t)

n = num2str(n);

switch n
    
    case {'1','2','3','4'}
        error('not coded, too few datapoints')
        
    case {'5','6','7'}
        rank = 1;
        
    case '8'
        rank = 2;
        
    case '9'
        rank = 2;
        
    case '10'
        rank = 2;
        
    case '11'
        rank = 3;
        
    case '12'
        rank = 3;
        
    case '13'
        rank = 3;
        
    case '14'
        rank = 4;
        
    case '15'
        rank = 4; 
        
    case '16'
        rank = 5;
        
    case '17' 
        rank = 5;
        
    case '18'  
        rank = 5;
        
    case '19'  
        rank = 6;
        
    case '20'
        rank = 6;
        
    otherwise
        n = str2double(n);
        rank = 0.5* ( n+1 -  t*   sqrt(n)     );
        rank= floor(rank);        
end




