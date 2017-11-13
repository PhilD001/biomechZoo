function lg=mybar(barval,evalue,conditions,colors,ax,lg)

% lg = MYBAR(barval,evalue,conditions,colors,ax,lg,enames,type)
%
% ARGUMENTS
%  barval     ...  1 x c vector of barvalues
%  eval       ...  1 x c vector of errorvalues
%  conditions ...  1 x c cell aray of names for each bar
%  colors     ...  1 x c cell array of colors for each bar
%  ax         ...  handle of axis
%  lg         ...  create legend 0: no, 1: yes
%
% RETURNS
%  lg         ...  Legend handle
%
% NOTES:
% - this is an ensembler standalone function. It may not work well outside of the
%   ensembler needs



% Revision History
%
% Created by Philippe C. Dixon April 2008
%
%
% Updated by Philippe C. Dixon Dec 2014
% - hardcoding removed
% - function can handle any number of bars
%
% Updated by Philippe C. Dixon August 2014
% - use the last argument 'type' to make special or custom groupings.
% Futhre updates should adress the hard coding used in this version
%
% Updated by Philippe C. Dixon May 2015
% - improved ability to deal with colors
%
% Updated by Philippe C. Dixon June 2015
% - uses the function 'distinguishable_colors' to choose
%   maximally distinct colors using the default mode
%
% Updated by Philippe C. Dixon March 2016
% - compatible with r2014b +
%
% Updated by Philippe C. Dixon April 2017
% - compatible with Linux platform

barWidth = 0.9; % default

%---CHECK FOR APPROPRIATE SIZE OF DATA------------------------------
%
barval = makecolumn(barval)';
[r,c] = size(barval);

[r_col,~] = size(colors);


if r~=1
    error('data must have one row')
end



% y = [4.2; 4.6; 5];                  %The data.
% fHand = figure;
% aHand = axes('parent', fHand);
% hold(aHand, 'on')
% colors = hsv(numel(y));
% for i = 1:numel(y)
%     bar(i, y(i), 'parent', aHand, 'facecolor', colors(i,:));
% end


%--CREATE BAR GRAPH-------------------------------------------------
%
z = zeros(r,c);
barvals = [barval; z];

if verLessThan('matlab','8.4.0') %|| strfind(computer,'GLNXA64')
    h = bar(barvals,barWidth,'grouped');
    
else
    barvals = barvals(1,:);
    x = 1:1:length(barvals);       % creates even spacing
    
    % if length(barvals)==4
    %    x = [1,2,3.4,4.4];           % an example for uneven spacing
    % end
    
    h = zeros(length(barvals),1);
    for i = 1:length(barvals)
        h(i) = bar(x(i),barvals(i),barWidth);
        hold on
    end
    
    
end

for i = 1:length(h)
    set(h(i),'tag',conditions{i})
    set(h(i),'UserData',conditions{i})                      % for display in ensembler
    set(h(i),'ButtonDownFcn','ensembler(''buttondown'')');  % for display in ensembler
end



%---SET COLORS-------------------------------------------------------
%
if isequal(colors(1,:),colors(2,:)) && r_col==c
    disp('using default colors')
    n_colors = length(barvals);
    
    colors = [1 0 0; 0 0 1; 1 1 0; 1 0 1;0 1 1;0 1 0;0 0 0];  % put more if needed
    
    if ~verLessThan('matlab','8.4.0') 
        if n_colors > length(colors)
            error('add more colors to matrix')
        end
        
        colors = colors(1:n_colors,:);
    end
    
end

for i = 1:c
    set(h(i),'facecolor',colors(i,:))           % use color codes
end


%---GET POSITION OF MIDDLE OF BAR GRAPHS------------------------------
%
if verLessThan('matlab','8.4.0') 
    bhnd = findobj(ax,'type','patch');
    x = zeros(length(bhnd),1);
    
    for i = 1:length(bhnd)
        xdata =  get(bhnd(i),'XData');
        x(i) = mean(xdata([1,4],1));
    end
    
    x = sort(x);
end




%---ADD ERROR BARS------------------------------------------------------
%
line('xdata',x,'ydata',barval,'LineStyle','none')
hold on

for i=1:length(x)
    ehnd = errorbar(x(i),barval(i),evalue(i),'k');
    set(ehnd,'tag','ebar')
end




%---ADD LEGEND-------------------------------------------------------------
%
if lg==1                                      % then draw in a legend
    
    constk = cell(20,1);
    
    for i = 1:length(conditions)
        constk{i} = conditions{i};
    end
    
    constk(cellfun(@isempty,constk)) = [];      % That's some hot programming
    
    legend(constk)
    
    lg = 0;                                     % set legend to 0 (no)
    
end

%--REMOVE EVIDENCE---------------------------------------------------------
%
set(gca,'xtick',[])


