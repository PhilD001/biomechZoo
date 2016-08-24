function naxes = tposeaxesadj(axes,segname,filename)

naxes = struct;
dim = fieldnames(axes);

I = [1 0 0 ];
J = [0 1 0 ];
K = [0 0 1 ];

fld = 'E:\Users\phildixon\Documents\Grad School\Thesis\Data\zoo processed\T-POSE\zoo filest tpose (step 03 for kinetics';
%fld = uigetfolder('select T-pose zoo2idaT');
fl = engine('path',fld,'extension','zoo');



indx= findstr(filename,'subject');
subject = filename(indx+7:indx+8);

switch subject
    
    case '01'
        
     data = load(fl{1},'-mat');
     
     Ti = data.([segname,'axes']).line(:,1);
     
     
     for a = 1:length(Ti)
         
     ang = rad2deg(acos(dot(Ti,I,2))); %angle btw two vectors
     
     if cross(Ti,I,2)
         angout = vecrotate(tri,-ang,I
     
     for a = 1:length(dim)   
    
         
        
         axes.(dim{a}) = axes.(dim{a}) - data.
     
     end
    
    case '02'
        
    case '03'
        
    case '04'
    case '05'
    case '06'
    case '07'
    case '08'
    case '09'
    case '10'
        
end