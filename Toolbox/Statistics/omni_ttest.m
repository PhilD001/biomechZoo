function [P,t,df,e,md,CIdiff] = omni_ttest(data1,data2,type,alpha,thresh,tail,mode,bonf)

% [P,t,df,e] = OMNI_TTEST(data1,data2,type,alpha,thresh,tail,mode,bonf) performs statistical
% comparison of two groups taking into account parametric assumptions.
%
% ARGUMENTS
%  data1    ...  first data set.
%  data2    ...  second data set
%  type     ...  'paired' or 'unpaired' analysis
%  alpha    ...  significance level. Default '0.05'
%  thresh   ...  threshold for failure of parametric assumptions and use of
%                nonparametric tests. Default '0.05'
%  mode     ...  display information 'full'
%  bonf     ...  apply bonferroni correction based on n tests. default n = 1

% RETURNS
%  P        ...  pvalue associated with test (parametric or non-parametric)
%  t        ...  t-statistic associated with test
%  df       ...  degrees of freedom
%  e        ...  Effect size: cohen's d or Glass's delta if data have equal
%                variance or not, respectively
%  md       ...  mean difference between the groups
%  CIdiff   ...  CI for difference
%
% NOTES
%  - only two-sided test is possible
%  - if parametric assumptions fail, nonparametric tests are run
%  - in 'unpaired' design, group 1 is treatment group and group 2 is control
%  - see 'Medical Statistics' by  Kirkwood and Sterne section 7.6 for comp
%    details
%
% NOTES
% - for zoo files, data1 and data2 argments can be obtained using
%   'extractevents.m'. Some editing may be necessary for your project
% - only two-tailed tests can be performed
%
% Revision History
%
% Created by Philippe C Dixon Feb 2012
%
% Updated by Philippe C Dixon June 2015
% - removed reliace on 'decimals2' function
% - improved interface
% - removed option to run 'right' or 'left' sided
%
%
% Part of the biomechZoo toolbox v1.3 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt or visit
% http://www.biomechzoo.com

% Set Defaults
%
switch nargin
    
    case 0
        disp('entering test mode')
        data1 = [45.3 41.2 35.5 43.5  39.4 32.1 50.6];
        data2 = [44.6 37.8 31.9 29.7  50.3];
        type = 'unpaired';
        alpha = 0.05;
        thresh = 0.01;
        tail = 'both';
        mode = 'full';
        bonf = 1;
        
    case {1,2}
        error('not enough inputs')
        
    case 3
        alpha = 0.05;
        thresh = 0.01;
        tail = 'both';
        mode = 'full';
        bonf = 1;
        
    case 4
        thresh = 0.01;
        tail = 'both';
        mode = 'full';
        bonf = 1;
        
    case 5
        tail = 'both';
        mode = 'full';
        bonf = 1;
        
    case 6
        mode = 'full';
        bonf = 1;
        
    case 7
         bonf = 1;
end


if nargin==3 && isstruct(type)
    alpha = type.alpha;
    thresh = type.thresh;
    tail = type.tail;
    mode = type.mode;
    bonf = type.bonf;
    type = type.type;
end

if isstruct(data1)
    data1 = data1.line;
    data2 = data2.line;
end


%---SET UP DATA-------------------------------------------------
%
data1 = makecolumn(data1);
data2 = makecolumn(data2);
data_all = [data1; data2];

indx1 = find(~isnan(data1));
indx2 = find(~isnan(data2));

data1_nonans =data1(indx1);
data2_nonans =data2(indx2);

xbar1 = nanmean(data1);
xbar2 = nanmean(data2);
xbar_all = nanmean(data_all);

n1 = length(data1)-length(find(isnan(data1)));
n2 = length(data2)-length(find(isnan(data2)));

%---TEST FOR NORMALITY -------------------------------------------
%
[~,p_lil1] = lillietest(data1,alpha);   % NaNs treated as missing values and ignored
[~,p_lil2] = lillietest(data2,alpha);   % NaNs treated as missing values and ignored
[~,p_lil_all] = lillietest(data_all,alpha);
if strcmp(type,'paired')
    [~,p_lil3] = lillietest(data1-data2,alpha);   % NaNs treated as missing values and ignored
else
    p_lil3 = 1;
end


if p_lil1 <=thresh  || p_lil2 <=thresh || p_lil3 <= thresh
    disp('deviation from normality suspected')
    normal = 'no';
else
    normal = 'yes';
end

% overall group
if p_lil_all <=thresh
    disp('deviation from normality suspected for all data')
end


%---TEST EQUALITY OF VARIANCE-------------------------------
%
one = ones(length(data1_nonans),1);
two = 2*ones(length(data2_nonans),1);
data = [data1_nonans; data2_nonans];
con = [one; two];
p_lev = Levenetest([data con],alpha);

if p_lev < alpha
    disp('data has unequal variance')
    vartype ='unequal';
else
    vartype = 'equal';
end


%--RUN CORRECT ANALYSED BASED ON TEST RESULTS AND INPUTS

switch type
    
    case 'paired'
        
        indx = intersect(indx1,indx2);
        data1 = data1(indx);
        data2 = data2(indx);
        
        n1 = length(data1);
        n2 = n1;
        
        if n1 < 5   % http://pareonline.net/pdf/v18n10.pdf
            disp(['warning: only ',num2str(n1), ' subjects being analysed, posssbily try unpaired'])
        end
        
        if isin(normal,'yes') && ~isin(vartype,'unequal')
            type = 'paired t-test';
            m = 'mean';
            es = 'Cohens d';
            
            [~,P,CIdiff,STATS] = ttest(data1,data2,alpha,tail);
            t = STATS.tstat;
            df = n1-1;
            md = mean(data1-data2);
            sd =  sqrt( ( (std(data1).^2) + (std(data2).^2) )/2 );      % SD pooled
            e = abs(md)/sd;                                             % Cohen's d
            
        else
            type = 'Signed-Rank';
            m = 'median';
            es = 'Glasss delta';
            
            P  = signrank(data1,data2);
            t  = NaN;
            df = n2-1;
            md = median(data1-data2);
            sd_c = nanstd(data1);                                       % std of control
            e = abs(mean(data1-data2))/sd_c;                            % Glass's delta
            
            [lo,hi] = bmech_CI(data1-data2,'median',alpha,'no');
            CIdiff = [lo hi];
        end
        
        
        
    case 'unpaired'
        
        if isin(normal,'yes') && ~isin(vartype,'unequal')
            type = 'unpaired t-test';
            m = 'mean';
            es = 'Cohens d';
            
            [~,P,CIdiff,STATS] = ttest2(data1,data2,alpha,tail,vartype) ;
            t = STATS.tstat;
            df = STATS.df;
            md = xbar1-xbar2;
            sd =  sqrt( ( (nanstd(data1).^2) + (nanstd(data2).^2) )/2 ); % SD pooled
            e = abs(md)/sd;                                              % Cohen's d
            
            
        else
            type = 'Signed-Rank';
            m = 'median';
            es = 'Glasss delta';
            
            P = ranksum(data1_nonans,data2_nonans);
            t = NaN;
            df = NaN;
            
            sd_c = nanstd(data1);                                        % std of control
            e = abs(  nanmean(data1)- nanmean(data2) )/sd_c;                          % Glass's delta
            
            
            indx = find(~isnan(data1));
            data1_nonans = data1(indx);
            
            indx = find(~isnan(data2));
            data2_nonans = data2(indx);
            
            if n1 > n2
                data1_nonans = data1_nonans(1:n2);
            elseif n2 > n1
                data2_nonans = data2_nonans(1:n1);
            else
            end
            
            [lo,hi,~,~,md] = bmech_CI(data1_nonans-data2_nonans,'median',alpha,'no');
            CIdiff = [lo hi];
            
            
        end
end


[CIlo1,CIhi1] = bmech_CI(data1,'mean',alpha);
[CIlo2,CIhi2] = bmech_CI(data2,'mean',alpha);
[CIlo_all,CIhi_all] = bmech_CI(data_all,'mean',alpha);

if strcmp(mode,'full')
    close all
    %--PLOT SUMMARY FIGURES
    
    H = figure;
    p = get(H,'Position');
    set(H,'Position',[p(1)+100 p(2) 850 420])
    
    subplot(2,4,1)
    qqplot(data1)
    title(['QQ Plot Data1 (p = ',num2str(p_lil1),')'])
    
    subplot(2,4,2)
    qqplot(data2)
    title(['QQ Plot Data2 (p = ',num2str(p_lil2),')'])
    
    subplot(2,4,3)
    histogram(data1)
    title('Histogram Data1')
    
    subplot(2,4,4)
    histogram(data2)
    title('Histogram Data2')
    
    subplot(2,4,5)
    bar([xbar1 xbar2],'grouped');
    hold on
    errorbar(1,xbar1,xbar1-CIlo1,CIhi1-xbar1)
    errorbar(2,xbar2,xbar2-CIlo2,CIhi2-xbar2)
    title(['Group summary (p = ',num2str(P),')'])
    
    if strcmp(type,'paired')
        subplot(2,4,6)
        qqplot(data1-data2)
        title(['QQ Plot Diff data1 (p = ',num2str(p_lil3),')'])
    end
end

% DISPLAY REPORT---
disp('**************** ANALYSIS RESULTS ******************** ')
disp(' ')
disp(['test performed: ',type])
disp(' ')
disp(['sample size (n) group 1 = ',num2str(n1)])
disp(['sample size (n) group 2 = ',num2str(n2)])
disp(' ')
disp('Parametric assumptions:')
disp(['Liliefors test dataset 1 p = ',num2str(p_lil1)])
disp(['Liliefors test dataset 2 p = ',num2str(p_lil2)])
disp(['Levene test  p = ',num2str(p_lev)])
disp(' ')
disp('significance results:')
disp(['t(',num2str(df),') = ',num2str( sprintf('%.3f',t)),' p = ',num2str(sprintf('%.3f',P*bonf))])
disp(['effect size  ',es,' = ',num2str(sprintf('%.3f',e))])
disp(' ')
disp('Summary info')
disp(' ')


if p_lil_all <=thresh %|| p_lev < alpha
    disp(['Combined groups: median CI = ',num2str(sprintf('%.3f',xbar_all)),' (',num2str(sprintf('%.3f',CIlo_all)),',',num2str(sprintf('%.3f',CIhi_all)),')'])
else
    disp(['Combined groups: mean CI = ',num2str(sprintf('%.3f',xbar_all)),' [',num2str(sprintf('%.3f',CIlo_all)),',',num2str(sprintf('%.3f',CIhi_all)),']'])
end


if strcmp(type,'paired t-test')
    disp(['Group1: mean CI = ',num2str(xbar1),' [',num2str(sprintf('%.3f',CIlo1)),',',num2str(sprintf('%.3f',CIhi1)),']'])
    disp(['Group2: mean CI = ',num2str(xbar2),' [',num2str(CIlo2),',',num2str(CIhi2),']'])
    disp([m,' difference CI = ',num2str(md),' [',num2str(CIdiff(1)),',',num2str(CIdiff(2)),']'])
    
else
    
    
    if p_lil1 <=thresh %|| p_lev < alpha
        disp(['Group1: median CI = ',num2str(sprintf('%.3f',xbar1)),' (',num2str(sprintf('%.3f',CIlo1)),',',num2str(sprintf('%.3f',CIhi1)),')'])
    else
        disp(['Group1: mean CI = ',num2str(sprintf('%.3f',xbar1)),' [',num2str(sprintf('%.3f',CIlo1)),',',num2str(sprintf('%.3f',CIhi1)),']'])
    end
    
    if p_lil2 <=thresh %|| p_lev < alpha
        disp(['Group2: median CI = ',num2str(sprintf('%.3f',xbar2)),' (',num2str(sprintf('%.3f',CIlo2)),',',num2str(sprintf('%.3f',CIhi2)),')'])
    else
        disp(['Group2: mean CI = ',num2str(sprintf('%.3f',xbar2)),' [',num2str(sprintf('%.3f',CIlo2)),',',num2str(sprintf('%.3f',CIhi2)),']'])
    end
    
    disp([m,' difference CI = ',num2str(sprintf('%.3f',md)),' (',num2str(sprintf('%.3f',CIdiff(1))),...
        ', ',num2str(sprintf('%.3f',CIdiff(2))),')'])
    
end




%     disp(' ')
%     disp(['test run: ',type,'---------*'])
%     disp([' p = ',num2str(sprintf('%.3f',P))])
%
%
%     if isin(type,'paired')
%         disp([m,' difference CI = ',num2str(sprintf('%.3f',md)),' [',num2str(sprintf('%.3f',CIdiff(1))),', ',...
%               num2str(sprintf('%.3f',CIdiff(2))),']'])
%     else
%         disp([m,' difference CI = ',num2str(sprintf('%.3f',(md,2)),' (',num2str(sprintf('%.3f',CIdiff(1))),', ',...
%              num2str(sprintf('%.3f',CIdiff(2))),')'])
%     end
%






