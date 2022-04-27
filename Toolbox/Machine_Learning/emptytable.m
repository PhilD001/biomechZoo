function table_event=emptytable(fl,ch,event)
event_name={};
n=1;
for i=1:length(ch)
    for j=1:length(event)
        event_name{n}=[ch{i},'_',event{j}];
        n=n+1;
    end
end
event_name{n}='Subject';
event_name{n+1}='Conditions';
VariableTypes={};
for i=1:length(event_name)-2
    VariableTypes{i}='double';
end
VariableTypes{n}='cell';
VariableTypes{n+1}='cell';

table_event=table('Size',[length(fl),length(event_name)],'VariableName',event_name,'VariableTypes',VariableTypes);