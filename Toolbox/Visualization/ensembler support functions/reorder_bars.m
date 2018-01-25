function reorder_bars(order)

if nargin==0
    order = [];
end

ax = gca; %  findobj('type','axes');

% get error bars
%
if verLessThan('matlab','8.4.0')
    ehnd = sort(findobj(ax,'type','hggroup','tag','ebar'));
else
    ehnd = sort(findobj(ax,'tag','ebar'));
end


evals = zeros(size(ehnd));

for i = 1:length(ehnd)
    evals(i) = get(ehnd(i),'UData');
end


% get bar handles
%
if verLessThan('matlab','8.4.0')
    bhnd = sort(findobj(ax,'type','hggroup'));
else
    bhnd = sort(findobj(ax,'type','bar'));
end


for i = 1:length(bhnd)
    tag = get(bhnd(i),'tag');
    
    if isempty(tag) || isin(tag,'ebar')
        bhnd(i) = 0;
    end
    
end

indx = find(bhnd==0);
bhnd(indx) = [];


% find bar tags and values
%
btags = cell(size(bhnd));
bvals = zeros(length(bhnd),2);
bcols = zeros(length(bhnd),3);

cmap = colormap; % retrieve current color map

for i = 1:length(bhnd)
    btags{i} = get(bhnd(i),'Tag');
    bvals(i,:) = get(bhnd(i),'YData');
    bcols(i,:) = get(bhnd(i),'FaceColor');
end
bvals = bvals(:,1);


% get user choice
%
if isempty(order)
    nums = 1:1:length(btags);
    a = associatedlg(btags,{nums});
    indx = str2num(char(a(:,2)));
    
    if isequal(indx,nums')     % user modified left column
       ensembler_msgbox('','please modify number order in right column')
    end
    
    if ~isequal(sort(indx),nums')
        error('numbers reused twice, please select unique order')
    end
else
    indx = makecolumn(order);
end


% reoder bargraph elements
%
bvals(indx) = bvals;
evals(indx) = evals;
btags(indx) = btags;
bcols(indx,:) = bcols;

% bwidth = get(bhnd(1),'BarWidth');

% delete existing bar graph
%
delete(bhnd)
delete(ehnd)

mybar(bvals,evals,btags,bcols,ax,0)


