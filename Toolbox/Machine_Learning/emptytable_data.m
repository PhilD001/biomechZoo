function table_event=emptytable_data(fl,ch)
% emptytable_data creates emptytable
%
% ARGUMENTS
% fl          ...   string cell, all .zoo file in cell.
% ch          ...   string, all channel name. 
% RETURNS
% table_event ...  empty table of channel line data with subjects second last row and conditions last row.
%
event_name={};
n=1;
for i=1:length(ch)
        event_name{n}=[ch{i}];
        n=n+1;
end
event_name{n}='Subject';
event_name{n+1}='Conditions';
VariableTypes={};
for i=1:length(event_name)-2
    VariableTypes{i}='cell';
end
VariableTypes{n}='string';
VariableTypes{n+1}='string';
table_event=table('Size',[length(fl),length(event_name)],'VariableName',event_name,'VariableTypes',VariableTypes);