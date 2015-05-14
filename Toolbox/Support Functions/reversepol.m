
function data = reversepol(data,ch)

for i = 1:length(ch)  
    
    data.(ch{i}).line = -1.*data.(ch{i}).line;
    data.(ch{i}).event.rev = [1 0 0];
end