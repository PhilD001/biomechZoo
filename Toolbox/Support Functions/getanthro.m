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

% Updated by Philippe C. Dixon Feb 2018
% - Missing fields return 'NaN' and warning message

if ~isfield(data.zoosystem,'Anthro')
    error('Please set anthro fields to zoo file')
end


r = findfield(data.zoosystem.Anthro,field);

if isempty(r)
    
    switch lower(field)
        
        case 'markerdiameter'
            r = 14;
            
        case 'rleglength'
            if isfield(data,'RLegLength')
                r =  data.zoosystem.Anthro.RLegLength;
            elseif isfield(data,'RASI')
                r = nanmean(magnitude(data.RASI.line-data.RHEE.line));
            else
                r = NaN;
            end
            
        case 'lleglength'
            if isfield(data,'LLegLength')
                r =  data.zoosystem.Anthro.LLegLength;
            elseif isfield(data,'LASI')
                r = nanmean(magnitude(data.LASI.line-data.LHEE.line));
            else
                r = NaN;
            end
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
            r = NaN;
            disp(['missing field: ',field])
             
    end
    
    data.zoosystem.Anthro.(field) = r;
  
    
end

