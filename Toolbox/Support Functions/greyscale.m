function greyscale

%GREYSCALE turns a color graf into greyscale. 
%
% NOTE
% A single figure should be loaded before running this file


%---------colors used in the current graph----

disp('turning your figure into grey scale')

colors = {'blue','red'};

data = findobj('type','line');

 stk = [];

for i=1:length(data)

    color =  get(data(i),'Color');          %finds all colors being used for lines in graph

    if isequal(color, rgb(colors{1}))             %if blue change to
      
        set(data(i),'Color',[0 0 0])
            
    end
    
    
    if isequal(color, rgb(colors{2}))             %if red change toblue change to
      
        set(data(i),'Color',[0 0 0])
            
    end
        
        
   
    
end
    

    