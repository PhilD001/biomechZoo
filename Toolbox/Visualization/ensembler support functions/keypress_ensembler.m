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
%
% Updated by Philippe C. Dixon Sept 2017
% - fixed delete file bug by removing while loop

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
                % [~,file] = fileparts(fl);
                % ext = extension(fl);
                % ensembler_msgbox(fld,['File deleted for: ',file,ext])

                
            case 'Delete Channel'   %delete a single channel
                ln = findobj(gca,'type','line');
                ch = remove_line_event(ln,fl,settings);
                outlier(fl,ch)
                [~,file] = fileparts(fl);
                ext = extension(fl);
                ensembler_msgbox(fld,['Channel ',ch,' deleted for: ',file,ext])

            case 'Clear All Channels'  % obsolete
                ln = findobj(gcf,'type','line');
                remove_line_event(ln,fl,settings)
                [~,file] = fileparts(fl);
                ext = extension(fl);
                ensembler_msgbox(fld,['Cleared single channel for: ',file,ext])

            case 'Clear Single Channel'  % works with line + event data
                ln = findobj(gca,'type','line');
                remove_line_event(ln,fl,settings)
                [~,file] = fileparts(fl);
                ext = extension(fl);
                ensembler_msgbox(fld,['Cleared single channel for: ',file,ext])

        end
        
end


function ch = remove_line_event(ln,fl,settings)

for j = 1:length(ln)
    
    if ~isempty(strfind(get(ln(j),'UserData'),fl))
        fl = get(ln(j),'UserData');
        ch = get(get(get(ln(j),'parent'),'title'),'string');
        ax = get(ln(j),'parent');
        evt = findobj(ax,'string',settings.string);
        for i = 1:length(evt)
            evt_ud = get(get(evt(i),'UserData'),'UserData');
            if evt_ud == fl
                delete(evt(i));
            end
        end
        
        delete(ln(j));
        
    end

end


% check = true;
% count = 1;
% ch = [];
% while check
%     if ~isempty(strfind(get(ln(count),'UserData'),fl))
%         fl = get(ln(count),'UserData');
%         ch = get(get(get(ln(count),'parent'),'title'),'string');
%         evt = findobj(gca,'string',settings.string);
%         for i = 1:length(evt)
%             evt_ud = get(get(evt(i),'UserData'),'UserData');
%             if evt_ud == fl
%                 delete(evt(i));
%             end
%         end
%         
%         delete(ln(count));
%         check = false;
%         
%     elseif count == length(ln)
%         break
%     else
%         count = count+1;
%     end
% end