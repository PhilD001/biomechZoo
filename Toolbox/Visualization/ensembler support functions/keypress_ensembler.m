function keypress_ensembler

%  keypress_ensembler is a stand-alone suppot function for ensembler

s = slash;

switch get(gcf,'currentkey')
    
    
    
    case 'delete'
        
        %--------------choose what happens when you press delete----
        
        button = questdlg('do you want to delete the entire file, a selected channel or just clear the selected line from display', ...
            'Deletion Options',...
            'Delete File', 'Delete Channel','Clear Single Channel','Clear Single Channel');
        
        
        Tag = get(gca,'Tag');
        hnd = findensobj('prompt',gcf);
        fl = get(hnd,'string');
        indx = strfind(fl,s);
        indx = indx(end-2);
        
        
        switch button
            
            case 'Delete File'
                
                ln = findobj('type','line');
                
                for i=1:length(ln)
                    if strcmp(get(ln(i),'UserData'),fl)==1
                        delete(ln(i));
                    end
                end
                
                delfile(fl);    %deletes entire file
                
                evt = findobj('string','\diamondsuit');
                
                if ~isempty(evt)
                    for i = 1:length(evt)
                        if get(evt(i),'UserData')==gco
                            delete(evt(i))
                        end
                    end
                end
                
                
            case 'Delete Channel'   %delete a single channel
                
                ln = findobj(gcf,'type','line');
                
                for i=1:length(ln)
                    if isin(get(get(ln(i),'Parent'),'Tag'),Tag) && strcmp(get(ln(i),'UserData'),fl)==1
                        delete(ln(i));
                    end
                end
                
                ch = get(gca,'Tag');
                disp(['deleting ch: ',ch,'from ',fl(indx+1:end)])
                
                data = zload(fl);
                data.(ch).line = 999*ones(length(data.(ch).line),1);
                
                evts = fieldnames(data.(ch).event);
                
                for j = 1:length(evts)
                    data.(ch).event.(evts{j})=[1 999 0];
                end
                
                save(fl,'data');
                
%                 updatedata(fld)
                
            case 'Clear All Channels'
                
                ln = findobj(gcf,'type','line');
                
                for i=1:length(ln)
                    if strcmp(get(ln(i),'UserData'),fl)==1
                        delete(ln(i));
                    end
                end
                
                disp(['line cleared from display only for ',fl])
                
            case 'Clear Single Channel'
                
                ln = findobj(gcf,'type','line');
                
                for i=1:length(ln)
                    if isin(get(get(ln(i),'Parent'),'Tag'),Tag) && strcmp(get(ln(i),'UserData'),fl)==1
                        delete(ln(i));
                    end
                end
                
        end
        
end