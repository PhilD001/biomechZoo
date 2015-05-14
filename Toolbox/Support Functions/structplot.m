function structplot(data)

% STRUCTPLOT plots any number of given channels in a structed array. If no
% arguments are entered, this m-file will help you select your zoo file
%
% ARGUMENTS
% 
% data        ...    struct containing data to be plotted
%
% Created April 2008 Phil Dixon
%
% Updated March 2009 Phil Dixon
% colors have been added


if nargin ==0
    
[f,p]=uigetfile('*.zoo');
data=load([p,f],'-mat');
data=data.data;
end


chnames = setdiff(fieldnames(data),'zoosystem');
indx = listdlg('liststring',chnames);


for i = 1:length(indx)
    color = {'b','r','g','c','m','y','k'};
    plot(data.(chnames{indx(i)}).line,color{i});
    hold on

end


