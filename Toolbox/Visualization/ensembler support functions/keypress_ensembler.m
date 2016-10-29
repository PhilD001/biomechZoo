function keypress_ensembler

%  keypress_ensembler is a stand-alone suppot function for ensembler

% Updated by Philippe C. Dixon October 2016
% - improved algorithm

switch get(gcf,'currentkey')
    
    case 'delete'
        
        %--------------choose what happens when you press delete----
        
        button = questdlg('do you want to delete the entire file, a selected channel or just clear the selected line from display', ...
            'Deletion Options',...
            'Delete File', 'Delete Channel','Clear Single Channel','Clear Single Channel');
        
        tag = get(gca,'Tag');
        hnd = findensobj('prompt',gcf);
        fl = get(hnd,'string');
         
        switch button
            
            case 'Delete File'
                
                % clear lines from figure
                ln = findobj(gcf,'type','line');
                for i=1:length(ln)
                    if ~isempty(strfind(get(ln(i),'UserData'),fl))
                        delete(ln(i));    
                    end
                end
                
                % clear events from figure
                evt = findobj(gcf,'string','\diamondsuit');
                if ~isempty(evt)
                    for i = 1:length(evt)
                        if get(evt(i),'UserData')==gco
                            delete(evt(i))
                        end
                    end
                end
                
                % delete entire file
                delfile(fl);    
                
             
            case 'Delete Channel'   %delete a single channel
                
                % clear lines from figure
                ln = findobj(gca,'type','line');                
                for i=1:length(ln)
                    if ~isempty(strfind(get(ln(i),'UserData'),fl))
                        fl = get(ln(i),'UserData');
                        delete(ln(i));
                    end
                end
                
                 % clear events from figure
                evt = findobj(gca,'string','\diamondsuit');
                if ~isempty(evt)
                    for i = 1:length(evt)
                        if get(evt(i),'UserData')==gco
                            delete(evt(i))
                        end
                    end
                end
                
                % Make line and events 999 outliers
                outlier(fl,tag)
                
     
            case 'Clear All Channels'  % obsolete
                
                ln = findobj(gcf,'type','line');
                
                for i=1:length(ln)
                    if strcmp(get(ln(i),'UserData'),fl)==1
                        delete(ln(i));
                    end
                end
                
                disp(['line cleared from display only for ',fl])
                
            case 'Clear Single Channel'
                
                % clear lines from figure
                ln = findobj(gca,'type','line');                
                for i=1:length(ln)
                    if ~isempty(strfind(get(ln(i),'UserData'),fl))
                        fl = get(ln(i),'UserData');
                        delete(ln(i));
                    end
                end
                
                 % clear events from figure
                evt = findobj(gca,'string','\diamondsuit');
                if ~isempty(evt)
                    for i = 1:length(evt)
                        if get(evt(i),'UserData')==gco
                            delete(evt(i))
                        end
                    end
                end
                
        end
        
end