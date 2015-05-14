function data = addevents(data,chs,ename,type)

% This function is called by bmech_addevent to add data to event branches.
%
% NOTES
% - User is encouraged to modify event functions for specific needs
% - Not all events have been tested
%
%
%----------Part of the Zoosystem Biomechanics Toolbox 2006-2014------------------------------%
%                                                                                            %
% MAIN CONTRIBUTORS                                                                          %
%                                                                                            %
% Philippe C. Dixon         Dept. of Engineering Science. University of Oxford, Oxford, UK   %
% JJ Loh                    Medicus Corda, Montreal, Canada                                  %
% Yannick Michaud-Paquette  Dept. of Kinesiology. McGill University, Montreal, Canada        %
%                                                                                            %
% - This toolbox is provided in open-source format with latest version available on          %
%   GitHub: https://github.com/phild001                                                      %
%                                                                                            %
% - Users are encouraged to edit and contribute to functions                                 %
% - Please reference if used during preparation of manuscripts                               %                                                                                           %
%                                                                                            %
%  main contact: philippe.dixon@gmail.com                                                    %
%                                                                                            %
%--------------------------------------------------------------------------------------------%

if strcmp(chs{1},'all')
    
    chs = fieldnames(data);
    chs = setdiff(chs,{'zoosystem'});
    chs = setdiff(chs,{'contacttime'});
    
end

chs = setdiff(chs,{'zoosystem'});

for i = 1:length(chs)
    ch = chs{i};
    
    if ~isfield(data,ch)
        error(['channel : ',ch, ' does not exist'])
    end
    
    if isempty(ename)
        data.(ch).event = struct;
        continue
    end
    yd = data.(ch).line;
    
    switch type
        
        case 'first'
            exd = 1;
            eyd = yd(exd);
            
        case 'last'
            exd = length(yd);
            eyd = yd(exd);
            
        case 'max'
            eyd = max(yd);
            exd = find(yd==eyd);
            
        case 'min'
            eyd = min(yd);
            exd = find(yd==eyd);
            
        case 'rom'
            eyd = max(yd)-min(yd);
            exd = 1;
            
        case {'RFS','RFO','LFS','LFO'}
            exd = ZeniEventDetect(data,type(1),type(2:end));
            
            
            if isnan(exd)
                eyd = NaN;
                ename = [ename,'1'];
            elseif length(exd)==1
                eyd = yd(exd);               
                ename = [ename,'1'];
            end
            
    end
    
    if isempty(exd)
        error('no event found')
    end
    
    
    if length(exd) > 1 % many events
        
        for j = 1:length(exd)
            eyd = yd(exd(j));        
            data.(ch).event.([ename,num2str(j)]) = [exd(j),eyd,0];
        end
        
    else
        data.(ch).event.(ename) = [exd,eyd,0];
    end
    
    
end











