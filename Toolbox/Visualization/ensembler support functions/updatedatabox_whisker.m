function updatedatabox_whisker(fld,settings,chartType)
g
% UPDATADATABOX_WHISKER is a stand-alone support function for ensembler
delete(findobj('type','line'));
delete(findobj('type','patch'));
delete(findobj('type','rectangle'));
delete(findobj('type','legend'));
delete(findobj('type','bar'));
delete(findobj('string','\bullet'));
%--reload-----
loaddatabox_whisker(fld,findobj('type','figure'),settings,chartType);
clear999