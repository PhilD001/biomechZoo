function [chat_b, cilohat_b, cihihat_b,chat,cilohat,cihihat,muhat_b,muhat,sehat_b,sehat,meanmuhat_b,bias] = bootstrap_t(data,nboots,alpha,display)

% bootstap_t computes symmetric confidence intervals based on the bootstrap-t procedure
% 
% ARGUMENTS
%  data          ...  vector or matrix data. If data is a struct, we have an unbalanced samples
%  nboots        ...  numbe of bootstrap samplies
%  alpha         ...  significance level
%  display       ...  display results. Default no.
%
% RETURNS
%  chat_b        ...  bootstrapped estimate of critical value of test statistic
%  cilo          ...  lower range of confidence interval
%  cihi          ...  upper range of confidence interval
%  chat          ...  sample estimate of critical value of test statistic
%  muhat         ...  sample estimate of population mean mu
%  muhat_b       ...  bootstrap estimates of muhat
%  meanmuhat_b   ...  mean bootstrap estimate of muhat
%  bias          ...  bias between muhat and mean_b
%  sehat         ...  sample estimate of standard error
%  sehat_b       ...  bootstrap estimate of standard error (standard deviation of the B Bootstrap mean estimates
%
%
% NOTES
% - a demo version can be run by running the function without arguments.
%   Choice of demo can be modified to either 'points' or curves'
% - For time-series data, the function operates as described by Lenhoff,
%   1999 and Duhamel 2004


% Revision History
%
% Created by Philippe C. Dixon June 2012 
%
% Updated by Philippe C. Dixon july 26th 2013
% - code is easier to understand by using the function datasample instead of bootstrp
% - added calculations of bias
% - code can be used to get bootstrap estimates for uneven unpaired data



% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon (D.Phil.), Harvard University. Cambridge, USA.
% Yannick Michaud-Paquette (M.Sc.), McGill University. Montreal, Canada.
% JJ Loh (M.Sc.), Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com or pdixon@hsph.harvard.edu
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the conference abstract below if the zoosystem was used in the 
% preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement 
% Analysis Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of 
% Movement Analysis in Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.



%--SET DEFAULTS--------------------------------------------------------------------------
%
if nargin==0
    display = 'curves';
%     display = 'points';
    nboots = 1000;
    alpha = 0.05;
end


if nargin==3
    display= [];
end

if isin(display,'point')
    
    disp('running demo mode for point data')
    data = [-8.5 -4.6 -1.8 -0.8 1.9 3.9 4.7 7.1 7.5 8.5 14.8 16.7 17.6 19.7 20.6 21.9 ...
        23.8 24.7 24.7 25.0 40.7 46.9 48.3 52.8 54.0]';
    
elseif isin(display,'curves')
    disp('running demo mode for curve data')
    [path,~] = getfuncdir('bootstrap_test.m');
    data = load([path,'boot_test_data.mat'],'-mat');
    data = data.mstk;
else
    
end





if ~isstruct(data)  % for single condition or paired differences
    
    
    %--extract data and compute sample estimates
 
    [n,col] = size(data);
    
    muhat = mean(data);                            % sample estimate of the mean
    shat = std(data);                              % Sample estimate of the standard deviation
    sehat = shat./sqrt(n);                         % sample estimate of the standard error
    
    df = n-1;                                      % degrees of freedom of sample
    chat = tinv(1-alpha/2,df);                     % sample estimate of the critical t-value
    
    cilohat = muhat-chat*sehat;                    % sample estimate of lower CI 
    cihihat = muhat+chat*sehat;                    % sample estimate of upper CI
    
   
    %--Compute bootstrap estimates
    
    muhat_b = zeros(nboots,col);
    t = zeros(nboots,1);
    
    for b = 1:nboots
        [~,indx] = datasample(data(:,1),n);        % return indx of chosen curves
        xb1 = data(indx',:);                       % bth bootstrap sample of data
        muhat_b(b,:) = mean(xb1);                  % bth bootstrap estimate of the mean
    end
    
    sehat_b = std(muhat_b);                        % bootstrap standard error of the mean
    
    for b = 1:nboots
        t(b) = max( abs ( muhat_b(b,:) - muhat )  ./ sehat_b );  % t-statistic
    end
    
    
    
else % for unpaired differences
    
    %--extract data and compute sample estimates
 
    ch = fieldnames(data);
    
    data1 = data.(ch{1}).line;                                % 1st condiiton
    data2 = data.(ch{2}).line;                                     % 2nd condiiton
    
    [n1,col1] = size(data1);                          
    [n2,col2] = size(data2);
    
    if col1 ~=col2
        error('lines of different lengths')
    end
    col = col1;
    
    muhat = mean(data1)-mean(data2);                            % mean difference
    sehat = sqrt((std(data1).^2)/n1 + (std(data2).^2)/n2 );     % Satterthwaite approximation
    
    df = (n1-1) + (n2-1); 
    chat = tinv(1-alpha/2,df);                      % sample estimate of the critical t-value

    cilohat = muhat-chat*sehat;                     % sample estimate of lower CI
    cihihat = muhat+chat*sehat;                     % sample estimate of upper CI
    
    
    % bootstrap the diff
    
    muhat_b = zeros(nboots,col);
    t = zeros(nboots,1);
    
    for b = 1:nboots
        
        [~,indx1] = datasample(data1(:,1),n1);        % return indx of chosen curves
        xb1 = data1(indx1',:);                        % bth bootstrap sample of data
        
        [~,indx2] = datasample(data2(:,1),n2);        % return indx of chosen curves
        xb2 = data2(indx2',:);                        % bth bootstrap sample of data
        
        muhat_b(b,:) = mean(xb1) - mean(xb2);         % mean bootstrap diff
    end
    
    sehat_b = std(muhat_b);                           % bootstrap standard error of the mean
    
    for b = 1:nboots
        t(b) = max( abs ( muhat_b(b,:) - muhat )  ./ sehat_b );  % t-statistic
    end
    
end


%--COMPUTE TEST STATISTIC AT ALPHA LEVEL-----------------------------------------------------
%
chat_b = prctile(t,100*(1-alpha/2));



%--COMPUTE CONFIDENCE INTERVALS--------------------------------------------------------------
%
cilohat_b = muhat - chat_b*sehat_b;                       % lower confidence interval
cihihat_b = muhat + chat_b*sehat_b;


%--COMPUTE OTHER QUANTITIES------------------------------------------------------------------
meanmuhat_b = mean(muhat_b);
bias = muhat-meanmuhat_b;



%--DISPLAY RESULTS----------------------------------------------------------------------------
%

if nargin==4
    
    if col>1
        ch = display;       % for ensembler
        display = 'curves';
    else
        display = 'points';
    end
    
end

if isin(display,'point')
    figure
    hist(muhat_b,20)
    vline(muhat,'r:')
    vline(meanmuhat_b,'b')
    vline(cilohat_b,'b:')
    vline(cihihat_b,'b:')
    title('Distribution of data')
    text(28,125,['Bias = ',num2str(bias)])
    text(28,120,['SE sample = ',num2str(sehat)])
    text(28,115,['SE boot = ',num2str(sehat_b)])
    text(28,110,['t-crit sample = ',num2str(chat)])
    text(28,105,['t-crit boot = ',num2str(chat_b)])
    
elseif isin(display,'curves')
    x = 1:1:col;
    figure
    suptitle(['Summary stats for: ',ch])
   
    subplot(2,2,1)
    
    plot(x,muhat,'r','linewidth',1.5);
    hold on  
    plot(x,meanmuhat_b,'b','linewidth',1.5);

    plot(x,cilohat_b,'b--','linewidth',1.5)
    plot(x,cihihat_b,'b--','linewidth',1.5)
    plot(x,cilohat,'r.-','linewidth',1.5)
    plot(x,cihihat,'r.-','linewidth',1.5)
    text(x(2),cilohat(2),['tcrit sample = ' num2str(chat)])
    text(x(2),cihihat(2),['tcrit boot = ' num2str(chat_b)])
    xlim([0,101])
    title('mean and CI')

    
    subplot(2,2,2)
    plot(x,bias,'k','linewidth',1.5)
    title('bias ( sample - bootstrap mu )')
    xlim([0,101])
    
    
    subplot(2,2,3)
    plot(x,sehat,'r','linewidth',1.5)
    hold on
    plot(x,sehat_b,'linewidth',1.5)
    title('Standard error estimates')
    legend('sample','boot')
    xlim([0,101])
    
    
%     subplot(2,2,4)
%     for i = 1:col
%         hold off
%         hist(muhat_b(:,i),20)
%         title('histogram')
%         hold on
%         vline(muhat(i),'r:')
%         vline(meanmuhat_b(i),'b')
%         vline(cilohat_b(i),'b:')
%         vline(cihihat_b(i),'b:')
%         pause(0.2)
%     
%     end
    
    
    
else
end
