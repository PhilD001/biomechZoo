% function forLegend = bplot(X,varargin)
% This function will create a nice boxplot from a set of data. You don't
% need any toolboxes.
% 
%     bplot(D) will create a boxplot of data D, no fuss.
% 
% T = bplot(D)  If X is a matrix, there is one box per column; if X is a
%               vector, there is just one box. On each box, the central
%               mark is the median, the edges of the box are the 25th and
%               75th percentiles
%               array 'T' for a legend. You can add the legend as legend(T)
% 
% T = bplot(D,x) will plot the boxplot of data D above the 'x' value x
% 
% T = bplot(D,y,'horiz') will plot a horizontal boxplot at the 'y' value of y
% 
% T = bplot(...,'Property', . . . )
% T = bplot(...,'PropertyName',PropertyValue, . . . )
% 
%   SINGLE PARAMETERS:
% 
%          'horizontal': Display the boxplot along the horizontal axis. The
%                        default is to display the boxplot vertically.
%                        'horiz'
%            'outliers': Displays the outliers as dots. The default
%                        settings are to display the dots only if you do
%                        not pass it a position and only if the number of
%                        points are less than 400.
%                        'points','dots'%
%          'nooutliers': Does NOT display the outliers as dots. The default
%                        settings are to display the dots only if you do
%                        not pass it a position and only if the number of
%                        points are less than 400.
%                        'nopoints','nodots'
%                 'std': Set the whiskers to be the mean±standard deviation
%                        The legend information will be updated
%                        'standard'
%              'nomean': Don't plot the mean 'plus' symbol '+'
%            'nolegend': Force the elements to display without any legend
%                        annotation.
% PARAMETER PAIRS
%                 'box': Set the percentage of points that the boxes span.
%                        Default is the first and third quartile. Choose
%                        only the lower number in %, for example: 25.
%                        'boxes','boxedge'
%             'whisker': Set the percentage of points that the whiskers
%                        span. Default is the 9% and 91%. Choose only the
%                        lower number in %, for example: 9. 
%                        'whiskers','whiskeredge'
%           'linewidth': Set the width of all the lines.
%               'color': Change the color of all the lines. If you use this
%                        feature then the legend returns an empty matrix.
%                        'colors'
%               'width': Set the width of the boxplot rectangle. For a
%                        horizontal plot this parameter sets the height.
%                        Default width is .8 for vertical plots and for
%                        horizontal plots the height is 1.5/20 of the y axis
%                        the  bars.
%                        'barwidth'
% 
%% Jitter feature 
% The boxplot has a cool jitter feature which will help you view each
% outlier separately even if two have identical values. It jitters the
% points around the other axis so that you can see exactly how many are
% there.
% 
% % Examples: 
% bplot(randn(30,3),'outliers')
% bplot(randn(30,3),'color','black');
% ----
% X = round(randn(30,4)*5)/5; % random, with some duplicates
% T = bplot(X,'points');
% legend(T,'location','eastoutside');
% 
%% development notes:
% This function was developed to be part of a larger histogram function
% which can be found at this location:
% http://www.mathworks.com/matlabcentral/fileexchange/27388-plot-and-compare-histograms-pretty-by-default
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jonathan Lansey 2013,                                                   %
%                   questions to Lansey at gmail.com                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%
function [forLegend, boxEdge, wisEdge] = bplot(x,varargin)
%% save the initial hold state of the figure.
hold_state = ishold;
if ~hold_state
    cla;
end
%%
if size(x,1)>1 && size(x,2)>1 % great, you want to plot a bunch.
    if isempty(varargin)
        forLegend = bplot(x(:,1),1);
        for ii=2:size(x,2)
            hold on;
            bplot(x(:,ii),ii,'nolegend');
        end
    else
        if ~ischar(varargin{1})
            warning('You can''t specify a location for multiple guys, this will probably crash');
        end
        forLegend = bplot(x(:,1),1,varargin{:});
        for ii=2:size(x,2)
            hold on;
            bplot(x(:,ii),ii,'nolegend',varargin{:});

        end
    end
    if ~hold_state
        hold off;
    end
    return;
end

%%
if ~isempty(varargin)
    if ischar(varargin{1})
        justOneInputFlag=1;
        y=1;
    else
        justOneInputFlag=0;
        y=varargin{1};
    end
else % not text arguments, not even separate 'x' argument
    y=1;
    justOneInputFlag=1;
end

%% check that there is at least some data
if isempty(x)
    warning('you asked for no data, so no data is what you plot.');
    forLegend = '';
    return;
end
%%
if length(y)>1
    warning('The location can only be a scalar, it has been set to ''1''');
    y=1;
end

%% serialize and remove NaNs
x=x(:);
x = x(~isnan(x));

%% Initialize some things before accepting user parameters
horizontalFlag=0;
barFactor=1; % 
linewidth=2;
forceNoLegend=0; % will any legend items be allowed in.
stdFlag = 0;
meanFlag = 1;
specialWidthFlag = 0; % this flag will determine whether the bar width is 
%                       automatically set as a proportion of the axis width

toScale = 0; % this flag is to scale the jitter function in case the 
%              histogram function is calling it

if justOneInputFlag
    if length(x)<400
        outlierFlag = 1;
    else
        outlierFlag = 0;
    end
    
else
    outlierFlag = 0;
end
widthFlag =0;

boxColor = [0.0005    0.3593    0.7380];
wisColor = [0 0 0]+.3;
meanColor = [0.9684    0.2799    0.0723];

percentileNum = 25; % for the main quantiles
percentileNum2 = 9; % for the whisker ends

%% interpret user paramters
k = 1 + 1 - justOneInputFlag;
while k <= length(varargin)
    if ischar(varargin{k})
    switch (lower(varargin{k}))
        case 'nolegend'
            forceNoLegend=1;
        case {'box','boxes','boxedge'}
            percentileNum = varargin{k + 1};
            k = k + 1;
        case {'wisker','wiskers','whisker','whiskers','whiskeredge'}
            percentileNum2 = varargin{k + 1};
            k = k + 1;
        case {'std','standard'}
            stdFlag = 1;
        case 'linewidth'
            linewidth = varargin{k + 1};
            k = k + 1;
        case {'color','colors'}
            boxColor = varargin{k+1};
            wisColor = varargin{k+1};
            meanColor = varargin{k+1};
            forceNoLegend=1;
            k = k + 1;
        case {'points','dots','outliers'} % display those outliers
            outlierFlag = 1;
        case {'nopoints','nodots','nooutliers'} % display those outliers
            outlierFlag = 0;
        case {'horizontal','horiz'}
            horizontalFlag = 1;
%         case {'serror','serrors','stderror','stderrors','sem'}
%             serrorFlag = 1;
        case {'width','barwidth'}
            barWidth = varargin{k+1};
            widthFlag = 1;
            k = k+1;
        case {'specialwidth','proportionalwidth','width2'}
            specialWidthFlag = 1;
            widthFlag = 1;
        case {'nomean'}
            meanFlag=0;
        case {'toscale','histmode','hist'}
            toScale = 1; % scale away folks!
            
%         case {'mode','modes'}
%             modeFlag = 1;
%         case {'text','alltext','t'} % ?????
%             textFlag=1;
        otherwise
            warning('user entered parameter is not recognized')
            disp('unrecognized term is:'); disp(varargin{k});
    end
    end
    k = k + 1;
end

%%
meanX = mean(x);
medianX = median(x);
defaultBarFactor=1.5/20;
p=axis;
if ~widthFlag % if the user didn't specify a specific width of the bar.
    if specialWidthFlag
        barWidth=barFactor*(p(4)-p(3))*defaultBarFactor;
    else
        barWidth = .8;
    %     barWidth = barFactor*(p(2)-p(1))*defaultBarFactor/5;
    end
end
%% calculate the necessary values for the sizes of the box and whiskers
boxEdge = prctile(x,[percentileNum 100-percentileNum]);
IQR=max(diff(boxEdge),eps); % in case IQR is zero, make it eps
if stdFlag
    stdX = std(x);
    wisEdge = [meanX-stdX meanX+stdX];
else
    wisEdge = prctile(x,[percentileNum2  100-percentileNum2]);
end

%% display all the elements for the box plot

hReg=[];
hReg2 = [];

if horizontalFlag
    hReg2(end+1) = rectangle('Position',[boxEdge(1),y-barWidth/2,IQR,barWidth],'linewidth',linewidth,'EdgeColor',boxColor,'facecolor',[1 1 1]);

    hold on;
    hReg2(end+1) = plot([medianX medianX],[y-barWidth/2 y+barWidth/2],'color',meanColor,'linewidth',linewidth);
    if meanFlag
        hReg2(end+1) = plot(meanX,y,'+','color',meanColor,'linewidth',linewidth,'markersize',10);
    end
    hReg2(end+1) = plot([boxEdge(1) boxEdge(2)],[y-barWidth/2 y-barWidth/2],'linewidth',linewidth,'color',boxColor);

    hReg(end+1) = plot([wisEdge(1) boxEdge(1)],[y y],'--','linewidth',linewidth,'color',wisColor);
    hReg(end+1) = plot([boxEdge(2) wisEdge(2)],[y y],'--','linewidth',linewidth,'color',wisColor);
    hReg2(end+1) = plot([wisEdge(1) wisEdge(1)],[y-barWidth/3 y+barWidth/3],'-','linewidth',linewidth,'color',wisColor);
    hReg(end+1) = plot([wisEdge(2) wisEdge(2)],[y-barWidth/3 y+barWidth/3],'-','linewidth',linewidth,'color',wisColor);
else %
    hReg2(end+1) = rectangle('Position',[y-barWidth/2,boxEdge(1),barWidth,IQR],'linewidth',linewidth,'EdgeColor',boxColor,'facecolor',[1 1 1]);
    hold on;
    
    hReg2(end+1) = plot([y-barWidth/2 y+barWidth/2],[medianX medianX],'color',meanColor,'linewidth',linewidth);
    if meanFlag
        hReg2(end+1) = plot(y,meanX,'+','linewidth',linewidth,'color',meanColor,'markersize',10);
    end
    hReg2(end+1) = plot([y-barWidth/2 y-barWidth/2],[boxEdge(1) boxEdge(2)],'linewidth',linewidth,'color',boxColor);

    hReg(end+1) = plot([y y],[wisEdge(1) boxEdge(1)],'--','linewidth',linewidth,'color',wisColor);
    hReg(end+1) = plot([y y],[boxEdge(2) wisEdge(2)],'--','linewidth',linewidth,'color',wisColor);
    hReg2(end+1) = plot([y-barWidth/3 y+barWidth/3],[wisEdge(1) wisEdge(1)],'-','linewidth',linewidth,'color',wisColor);
    hReg(end+1) = plot([y-barWidth/3 y+barWidth/3],[wisEdge(2) wisEdge(2)],'-','linewidth',linewidth,'color',wisColor);

end

%% add the points to the graph
% Note that the spread of points should depend on the width of the bars and
% the total number of points that need to be spread.
if outlierFlag % but only if you want to
    I = (x<wisEdge(1))+(x>wisEdge(2));
    I=logical(I);
    xx=x(I);
    yy=I*0+y;
    yy=yy(I);
    yy = jitter(xx,yy,toScale);

    if ~isempty(yy)
        yy = jitter(xx,yy,toScale);

        maxPointHeight = 2.5;
        yy = (yy-y)*4+y;
        yy = (yy-y)*(barWidth/maxPointHeight)/max([yy-y; barWidth/maxPointHeight])+y;

        if ~isempty(xx)
            if horizontalFlag
                hReg2(6) = plot(xx,yy,'o','linewidth',linewidth,'color',wisColor);
            else
                 hReg2(6) = plot(yy,xx,'o','linewidth',linewidth,'color',wisColor);
            end
        end
    end
end
%% Remove the legend entries 
% remove extras for all the items.
for ii=1:length(hReg)
    set(get(get(hReg(ii),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
end

% remove all remenants of legends
if forceNoLegend
    for ii=1:length(hReg2)
        set(get(get(hReg2(ii),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
    end
end
%% set the axis
% The axis is only messed with if you didn't pass a position value (because
% I figured you just wanted to make a quick plot without worry about much

if justOneInputFlag
    if horizontalFlag
        padxfac = .1;
        padyfac = 2;
    else
        padxfac = 2;
        padyfac = .1;
    end
    
    axis tight;
    p = axis;
    padx = (p(2)-p(1))*padxfac; pady = (p(4)-p(3))*padyfac;
    axis(p+[-padx padx -pady pady]);
end
%% Set the legend
if stdFlag
    whiskerText = '\mu ± \sigma';
else
    whiskerText = [num2str(percentileNum2) '%-' num2str(100-percentileNum2) '%'];
end
if meanFlag
    forLegend={'Median','\mu',[num2str(percentileNum) '%-' num2str(100-percentileNum) '%'],whiskerText,'outliers'};
else
    forLegend={'Median',[num2str(percentileNum) '%-' num2str(100-percentileNum) '%'],whiskerText,'outliers'};
end

%% return the hold state
% just being polite and putting the hold state back to the way it was.
if ~hold_state
    hold off;
end
% end main bplot function over

%% jitter function
% in case two point appear at the same value, the jitter function will make
% them appear slightly separated from each other so you can see the real
% number of points at a given location.
function yy =jitter(xx,yy,toScale)
if toScale
    tempY=yy(1);
else
    tempY=1;
end

for ii=unique(xx)';
    I = xx==(ii);
    fI = find(I)';
    push = -(length(fI)-1)/2; % so it will be centered if there is only one.
    for jj=fI
        yy(jj)=yy(jj)+tempY/50*(push);
        push = push+1;
    end
end

%% This is the function for calculating the quantiles for the bplot.
function yi = prctile(X,p)
x=X(:);
if length(x)~=length(X)
    error('please pass a vector only');
end
n = length(x);
x = sort(x);
Y = 100*(.5 :1:n-.5)/n;
x=[min(x); x; max(x)];
Y = [0 Y 100];
yi = interp1(Y,x,p);