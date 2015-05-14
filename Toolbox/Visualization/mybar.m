function lg=mybar(barval,evalue,conditions,colors,ax,lg)

% lg=mybar(barval,evalue,conditions,colors,ax,lg,enames,type)
%
% ARGUMENTS
%  barval     ...  1 x c vector of barvalues
%  eval       ...  1 x c vector of errorvalues
%  conditions ...  1 x c cell aray of names for each bar
%  colors     ...  1 x c cell array of colors for each bar
%  ax         ...  handle of axis
%  lg         ...  create legend 0: no, 1: yes
%  type       ... 'standard' or 'special'. If special, first two bars are
%                 separated from the rest
%
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
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 



%---CHECK FOR APPROPRIATE SIZE OF DATA------------------------------
%
barval = makecolumn(barval)';
[r,c] = size(barval);



if r~=1
    error('data must have one row')
end



%--CREATE BAR GRAPH-------------------------------------------------
%
z = zeros(r,c);
barvals = [barval; z];

h = bar(barvals,0.9,'grouped');


%---SET COLORS-------------------------------------------------------
%    
if ~isequal(colors(1,:),colors(2,:))
    
    for i = 1:c
        set(h(i),'facecolor',colors(i,:))           % use color codes
    end
    
else
    disp('using default colors')
    
end
    



%---GET POSITION OF MIDDLE OF BAR GRAPHS------------------------------
%
bhnd = findobj(ax,'type','patch');
bars = findobj('type','hggroup');
x = zeros(length(bhnd),1);

for i = 1:length(bhnd)
    xdata =  get(bhnd(i),'XData');
    x(i) = mean(xdata([1,4],1));
end

x = sort(x);



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



% OLD BAD CODE
% if c==2
%     x = [0.86 1.14];
%     line('xdata',x,'ydata',barval,'LineStyle','none')
%     hold on
%
%     for i=1:length(x)
%         errorbar(x(i),barval(i),evalue(i),'k')
%     end
%
% elseif c==3
%
%     x = [0.77 1 1.23];
%     line('xdata',x,'ydata',barval,'LineStyle','none')
%     hold on
%
%     for i=1:length(x)
%         errorbar(x(i),barval(i),evalue(i),'k')
%     end
%
% elseif c==4
%
%     x = [0.73 0.91  1.09 1.28];
%     line('xdata',x,'ydata',barval,'LineStyle','none')
%     hold on
%
%     for i=1:length(x)
%         errorbar(x(i),barval(i),evalue(i),'k')
%     end
%
%
% elseif c==5
%     x = [0.7 0.85 1 1.15 1.3 ];
%     line('xdata',x,'ydata',barval,'LineStyle','none')
%     hold on
%
%     for i=1:length(x)
%         errorbar(x(i),barval(i),evalue(i),'k')
%     end
%
% elseif c==6
%     x = [0.682 0.8 0.94 1.07 1.2 1.33 ];
%     line('xdata',x,'ydata',barval,'LineStyle','none')
%     hold on
%
%     for i=1:length(x)
%         errorbar(x(i),barval(i),evalue(i),'k')
%     end
%
% elseif c==9
%     x = [0.65  0.74  0.82  0.92  1.0  1.09 1.18 1.27 1.36 ];
%     line('xdata',x,'ydata',barval,'LineStyle','none')
%     hold on
%
%     for i=1:length(x)
%         errorbar(x(i),barval(i),evalue(i),'k')
%     end
%
%
%
% else
%
%     error('only bargraphs with 1,2,3, 5, and 6 bars supported')
%
% end



