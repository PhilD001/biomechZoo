function addotherchannelevent(fld,settings)

% ADDOTHERCHANNELEVENT(fld) loads events from another channel into the
% active channels in ensembler. 
%
% ARGUMENTS
%  fld      ... root folder to operate on
%  settings ... settings for display properties
%
% For example, an event called 'foot strike' in the RTOE
% channel can be found and loaded into the current channels in ensembler.
% Index will be the same


% Updated August 2017 by Philippe Dixon
% - Added use of settings file to avoid future errors
% - Events are tagged with suffix '_global' 

sfld = get(gcf,'name');

if strfind(sfld,'+')
    C = strsplit(sfld,'+');
    fl = engine('path',fld,'extension','zoo','search path',C{1});  % Any file is OK
else
    fl = engine('path',fld,'extension','zoo','search path',sfld);
end
    
data = zload(fl{1});
ch = setdiff(fieldnames(data),'zoosystem');


evts = {};
for i = 1:length(ch)
    evt = fieldnames(data.(ch{i}).event);
    evts = [evts; evt];
end

evts = unique(evts);

if isempty(evts)
    ensembler_msgbox(fld,'No other channel events exist')
    return
end

indx = listdlg('promptstring','choose your event','liststring',evts);
evts =evts(indx);

figs = findobj('type','figure');

for i =1:length(figs)
    
    ax = findobj(figs(i),'type','axes');
    
    for j =1:length(ax)
        
        lines = findobj(ax(j),'type','line');
        
        for k = 1:length(lines)
            
            file = get(lines(k),'UserData');
            ln = get(lines(k),'YData');
            
            for m = 1:length(evts)
                data = zload(file);
                batchdisp(file,['loading evt ',evts{m}])
                
                if isfield(data.zoosystem,'VideoSampleNum')
                    offset = abs(data.zoosystem.VideoSampleNum.Indx(1));
                else
                    offset = 0;
                end
                
                indx = findfield(data,evts{m});
                xpos = indx(1);
                
                if xpos > length(ln)
                    ensembler_msgbox(fld,'event outside line range')
                    error('event outside line range')
                else
                ypos = ln(xpos);
                
%                 text('parent',ax(j),'position',[xpos-offset ypos ],...
%                     'tag',evts{m},'string',settings.string,'verticalalignment',...
%                     settings.verticalalignment,'horizontalalignment',settings.horizontalalignment,...
%                     'color',settings.color,'FontSize',settings.FontSize,...
%                     'buttondownfcn',get(ax(j),'buttondownfcn'),'userdata',evts{m});
                 text('parent',ax(j),'position',[xpos-offset ypos ],...
                    'tag',[evts{m},'_global'],'string',settings.string,'verticalalignment',...
                    settings.verticalalignment,'horizontalalignment',settings.horizontalalignment,...
                    'color',settings.color,'FontSize',settings.FontSize,...
                    'buttondownfcn',get(ax(j),'buttondownfcn'),'userdata',lines(k));
                end
          
            end
            
        end
        
    end
    
end