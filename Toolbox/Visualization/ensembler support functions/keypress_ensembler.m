function keypress_ensembler(fld,settings)

%  keypress_ensembler is a stand-alone suppot function for ensembler

% Updated by Philippe C. Dixon October 2016
% - improved algorithm
%
% Updated by Philippe C. Dixon August 2017
% - Simplified cases using single algorithm (see sub function
%   remove_line_event
% - Fixed bug where event remained after deleting line
% - Added choice to clear a single event
% - Added output to ensembler msg box



switch get(gcf,'currentkey')
    

    case 'delete'
        
        %--------------choose what happens when you press delete----
       
        hnd = findensobj('prompt',gcf);
        obj = get(hnd,'string');
        
        if ~isempty(strfind(obj,'.zoo:')) % you've selected an event
            button = questdlg('Clear event?','Options','Yes','No','Yes');
            
            if strcmp(button,'Yes')
                etype = get(gco,'tag');
                delete(gco)
                ensembler_msgbox(fld,['event ',etype,' cleared'])
            end
            
            return
        else
            fl = get(gco,'UserData');
            
            button = questdlg('do you want to delete the entire file, a selected channel or just clear the selected line from display', ...
                'Deletion Options',...
                'Delete File', 'Delete Channel','Clear Single Channel','Clear Single Channel');
         
        end
        
        
        
        switch button
            
            case 'Delete File'
                ln = findobj(gcf,'type','line');
                remove_line_event(ln,fl,settings)
                delfile(fl);
                ensembler_msgbox(fld,['File deleted for: ',concatEnsPrompt(fl)])

                
            case 'Delete Channel'   %delete a single channel
                ln = findobj(gca,'type','line');
                remove_line_event(ln,fl,settings)
                outlier(fl,tag)
                ensembler_msgbox(fld,['Channel deleted for: ',concatEnsPrompt(fl)])

                
            case 'Clear All Channels'  % obsolete
                ln = findobj(gcf,'type','line');
                remove_line_event(ln,fl,settings)
                ensembler_msgbox(fld,['Cleared single channel for: ',concatEnsPrompt(fl)])

                
                
            case 'Clear Single Channel'  % works with line + event data
                ln = findobj(gca,'type','line');
                remove_line_event(ln,fl,settings)
                ensembler_msgbox(fld,['Cleared single channel for: ',concatEnsPrompt(fl)])

        end
        
end


function remove_line_event(ln,fl,settings)

check = true;
count = 1;
while check
    if ~isempty(strfind(get(ln(count),'UserData'),fl))
        fl = get(ln(count),'UserData');
        
        evt = findobj(gca,'string',settings.string);
        for i = 1:length(evt)
            evt_ud = get(get(evt(i),'UserData'),'UserData');
            if evt_ud == fl
                delete(evt(i));
            end
        end
        
        delete(ln(count));
        check = false;
        
    elseif count == length(ln)
        break
    else
        count = count+1;
    end
end