function updatedata(fld,settings)
g
% UPDATADATA is a stand-alone support function for ensembler


delete(findobj('type','line'));
delete(findobj('type','patch'));
delete(findobj('type','box'));
delete(findobj('type','bar'));
delete(findobj('string','\bullet'));
%--reload-----
loaddata(fld,findobj('type','figure'),settings);
clear999