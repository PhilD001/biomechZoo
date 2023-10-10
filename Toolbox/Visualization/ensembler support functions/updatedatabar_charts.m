function updatedatabar_charts(fld,settings,isCombine,chartType,color)
% UPDATADATABOX_WHISKER is a stand-alone support function for ensembler
delete(findobj('type','line'));
delete(findobj('type','patch'));
delete(findobj('type','rectangle'));
delete(findobj('type','legend'));
delete(findobj('type','bar'));
delete(findobj('type','ErrorBar'));
delete(findobj('string','\bullet'));
%--reload-----
loaddatabar_charts(fld,findobj('type','figure'),settings,isCombine,chartType,color);
clear999