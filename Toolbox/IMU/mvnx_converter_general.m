
clear
clc

%%% 
%transforme les fichiers .mvnx en fichier .mat, avec meilleur organisation/labels
%utilise le script load_mvnx_piano.m pour loader les fichiers 
% Jenn Dowling-Medley, 11 June 2020


addpath '/home/laboratoire/mnt/E/Librairies/mvnx' 


%load mvnx files in directory



file_dir = uigetdir(); %use gui to select directory

mvnxList = dir(fullfile(file_dir, '*.mvnx')); %search recursively in directory for mvnx files


Name={'Eve'};



for i=1:length(mvnxList)
    
    
    
   %% load various data files for trial
   
        %Name = ['S1' sprintf('%02d', i)]; %determine name of session/subject
     
        try
            
        mvnx=load_mvnx_piano([mvnxList(i).folder, '/' mvnxList(i).name]);
        
        %continue
        
        catch 
            fprintf([' ERROR LOADING:' mvnxList(i).folder, '/' mvnxList(i).name]);
            continue
        end
        
       
        
         
        
    %% MVNX data
        
        %trim unwanted information
         
        temp=mvnx.subject.frames.frame;
        
        temp=temp(4:end); %get rid of unwanted fields
        
        fields = { 'tc' , 'ms', 'type', 'index', 'footContacts', 'jointAngleXZY', 'jointAngleErgoXZY', 'jointAngleErgo', 'centerOfMass'}; %fields you would like to remove
        
        temp=rmfield(temp, fields); 
        
        %reorganize fields and label them according to joint name/segment
        %name
        
        %create labels (order xyz?)
        
        for j=1:length(mvnx.subject.segments.segment)
            
            segmentQLabels{1 + 4*(j-1)} = {[mvnx.subject.segments.segment(j).label, '_w']} ; %23 segmentsx4 =92
            segmentQLabels{1 + 4*(j-1) +1} = {[ mvnx.subject.segments.segment(j).label, '_i']};
            segmentQLabels{1 + 4*(j-1) +2} ={[ mvnx.subject.segments.segment(j).label, '_j']};
            segmentQLabels{1 + 4*(j-1) +3} ={[ mvnx.subject.segments.segment(j).label, '_k']};
            
            
        end
        
        segmentQLabels=[segmentQLabels{:}];
        
        for j=1:length(mvnx.subject.segments.segment)
           
            segmentLabels{1 + 3*(j-1)} = {[mvnx.subject.segments.segment(j).label, '_x']} ; %23 segmentsx3 =69
            segmentLabels{1 + 3*(j-1) + 1} = {[ mvnx.subject.segments.segment(j).label, '_y']};
            segmentLabels{1 + 3*(j-1) +2} ={[ mvnx.subject.segments.segment(j).label, '_z']};

        end
        
        segmentLabels=[segmentLabels{:}];
        
        for j=1:length(mvnx.subject.sensors.sensor)
        
            sensorLabels{1 + 3*(j-1)} = {[ mvnx.subject.sensors.sensor(j).label, '_x']}; %17 sensors x 3=51
            sensorLabels{1 + 3*(j-1)+1} = {[ mvnx.subject.sensors.sensor(j).label, '_y']};
            sensorLabels{1 + 3*(j-1)+2} = {[ mvnx.subject.sensors.sensor(j).label, '_z']};
        end
        
        sensorLabels=[sensorLabels{:}];
        
        for j=1:length(mvnx.subject.joints.joint) 
            
            jointLabels{1 + 3*(j-1)} = {[ mvnx.subject.joints.joint(j).label, '_x']};  %22 jointsx3=66
            jointLabels{1 + 3*(j-1)+1} = {[ mvnx.subject.joints.joint(j).label, '_y']};
            jointLabels{1 + 3*(j-1)+2} = {[ mvnx.subject.joints.joint(j).label, '_z']};
        
        end
       
        jointLabels=[jointLabels{:}];
        
        
       for j=1:length(mvnx.subject.sensors.sensor)
            
            sensorQLabels{1 + 4*(j-1)} = {[ mvnx.subject.sensors.sensor(j).label, '_w']}; %17 segmentsx4 =68
            sensorQLabels{1 + 4*(j-1) + 1} = {[ mvnx.subject.sensors.sensor(j).label, '_i']};
            sensorQLabels{1 + 4*(j-1) +2} ={[ mvnx.subject.sensors.sensor(j).label, '_j']};
            sensorQLabels{1 + 4*(j-1) +3} ={[ mvnx.subject.sensors.sensor(j).label, '_k']};
            
            
       end
        
       sensorQLabels=[sensorQLabels{:}];
        
        
        data(1).orientation=array2table(temp(1).orientation, 'VariableNames', segmentQLabels); %92 columns
      
        
        
        data(1).position=array2table(temp(1).position, 'VariableNames', segmentLabels); %69 columns     
        data(1).velocity=array2table(temp(1).velocity, 'VariableNames', segmentLabels);
        data(1).acceleration=array2table(temp(1).acceleration, 'VariableNames', segmentLabels);
        data(1).angularVelocity=array2table(temp(1).angularVelocity, 'VariableNames', segmentLabels);
        data(1).angularAcceleration=array2table(temp(1).angularAcceleration, 'VariableNames', segmentLabels);
        
        data(1).sensorOrientation=array2table(temp(1).sensorOrientation, 'VariableNames', sensorQLabels); %68?
        
        data(1).sensorFreeAcceleration=array2table(temp(1).sensorFreeAcceleration,  'VariableNames', sensorLabels);
        data(1).sensorMagneticField=array2table(temp(1).sensorMagneticField,  'VariableNames', sensorLabels); %51
        
        data(1).jointAngle=array2table(temp(1).jointAngle,  'VariableNames', jointLabels); %66
        
        for j=2:length(temp)
          
            data.orientation=[data.orientation; array2table(temp(j).orientation, 'VariableNames', segmentQLabels)];
            
            data.position=[data.position; array2table(temp(j).position, 'VariableNames', segmentLabels)];
            data.velocity=[data.velocity; array2table(temp(j).velocity, 'VariableNames', segmentLabels)];
            data.acceleration=[data.acceleration; array2table(temp(j).acceleration, 'VariableNames', segmentLabels)];
            data.angularVelocity=[data.angularVelocity; array2table(temp(j).angularVelocity, 'VariableNames', segmentLabels)];
            data.angularAcceleration=[data.angularAcceleration; array2table(temp(j).angularAcceleration, 'VariableNames', segmentLabels)];
            
            data.sensorFreeAcceleration=[data.sensorFreeAcceleration; array2table(temp(j).sensorFreeAcceleration, 'VariableNames', sensorLabels)];
            data.sensorMagneticField=[data.sensorMagneticField; array2table(temp(j).sensorMagneticField, 'VariableNames', sensorLabels)];
            
            data.sensorOrientation=[data.sensorOrientation; array2table(temp(j).sensorOrientation, 'VariableNames', sensorQLabels)];
            
            data.jointAngle=[data.jointAngle; array2table(temp(j).jointAngle, 'VariableNames', jointLabels)];
            
        end
        
        %add labels to data
        
        


         
    
     
     
     %% Add metadata 
     
        data.metaData.subject = Name;
        data.metaData.fs_xsens= mvnx.subject.frameRate ; %from xsens file metadata

        
        data.metaData.mvnxPath=[mvnxList(i).folder '/' mvnxList(i).name];
  
     
     
     fileOut = ([file_dir '/' mvnxList(i).name(1:end-5)]) 
     
     save( fileOut , 'data')
        
     clear data mvnx temp 
     

end
