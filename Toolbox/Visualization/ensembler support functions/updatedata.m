function updatedata(fld,settings)

% UPDATADATA is a stand-alone support function for ensembler


delete(findobj('type','line'));
delete(findobj('type','patch'));
delete(findobj('string','\bullet'));
%--reload-----
loaddata(fld,findobj('type','figure'),settings);
clear999