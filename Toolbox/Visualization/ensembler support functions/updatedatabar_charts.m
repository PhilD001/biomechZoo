function updatedatabar_charts(fld,settings,isCombine,chartType,color)

% UPDATADATEBAR_CHARTS(fld,settings,isCombine,chartType,color) is a stand-alone support function 
% to acess/create bar charts in ensembler

% remove existing objects
delete(findobj('type','line'));
delete(findobj('type','patch'));
delete(findobj('type','rectangle'));
delete(findobj('type','legend'));
delete(findobj('type','bar'));
delete(findobj('type','ErrorBar'));
delete(findobj('string','\bullet'));

% load charts 
loaddatabar_charts(fld,findobj('type','figure'), settings, isCombine, chartType, color);
clear999