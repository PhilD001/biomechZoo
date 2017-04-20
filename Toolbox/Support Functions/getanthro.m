function [r,data] = getanthro(data,field)

% ANTHRO = GETANTHRO(DATA) extracts anthropometric data from zoo file. If
% data are not available an attempt to compute information is made. This 
% function is useful to query without error unusual anthro field names.
%
% ARGUMENTS
%  data     ...   zoo data structure
%  
% RETURNS
%  anthro   ...   structured array containing all available zoo fields


if ~isfield(data.zoosystem,'Anthro')
    error('Please set anthro fields to zoo file')
end


r = findfield(data.zoosystem.Anthro,field);

if isempty(r)
    
    
    switch lower(field)
        
        case 'markerdiameter'
            r = 14;
            
        case 'rleglength'
            r = nanmean(magnitude(data.RASI.line-data.RHEE.line));
            
        case 'lleglength'
             r = nanmean(magnitude(data.LASI.line-data.LHEE.line));
             
        case 'rkneewidth'
            markerDiam = getanthro(data,'MarkerDiameter');
            [~,r] = jointwidthPiG_data(data,markerDiam);

        case 'lkneewidth'
            markerDiam = getanthro(data,'MarkerDiameter');
            [~,~,r] = jointwidthPiG_data(data,markerDiam);
            
        case 'ranklewidth'
            markerDiam = getanthro(data,'MarkerDiameter');
            [~,~,~,r] = jointwidthPiG_data(data,markerDiam);
              
        case 'lanklewidth'
             markerDiam = getanthro(data,'MarkerDiameter');
            [~,~,~,~,r] = jointwidthPiG_data(data,markerDiam);
          
        case 'mass'
            r = getanthro(data,'bodymass');
        
       
           
        otherwise
            error(['missing field: ',field]) 
       
           
    end
    
    data.zoosystem.Anthro.(field) = r;
    
end

