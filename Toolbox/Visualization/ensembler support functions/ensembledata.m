function ensembledata(vartype,settings)

% ENSEMBLEDATA (vartype,settings) summarizes line and event data from ensembler
% figres by axis and figure
%
% ARGUMENTS
%  vartype    ...   Type of ensemble statistic. ('SD','CI','CB',...)
%  settings   ...   Settings style for events

% Revision History
%
% Created by JJ Loh 2006?
%
% Updated by Philippe C. Dixon Jan 2017
% - Bug fix to search for 'average_line' field instead of exact line width
%   (see ensembledata)
%
% Updated by Philippe C. Dixon May 2017
% - updated to work with improved GUI settings
%
% Updated by Philippe C. Dixon August 2017
% - Added settings option for event tagging
%
% Updated by Philippe C. Dixon Dec 2017
% - bug fix for events with nan data (use of nanmean)


% find figure objects
%
prmt = findobj('Tag','prompt');
if ~isempty(prmt)
    set(prmt,'string','')
end

ax = findensobj('axes');

ln = findobj('type','line');                            % return all lines to common state
set(ln,'linewidth',0.5)

for i = 1:length(ax)
    lstk = [];
    ln = findobj(ax(i),'type','line','linewidth',.5);
    pt = get(ax(i),'parent');                           % parent of axis is figure
    nm = get(pt,'name');
    ch = get(ax(i),'Tag');
    
    if ~isempty(ln)
        xdata = get(ln(1),'XData');
        
        if length(ln)~=1
            
            for j = 1:length(ln)
                yd = get(ln(j),'ydata');
                lstk = stack_ensembler(lstk,yd);
                delete(ln(j))
            end
            
        end
        
        if isempty(lstk)
            continue
        end
        
        ehnd = findobj(ax(i),'string',settings.string);
        
        % check if there are mulitple events
%         evt_names = cell(length(ehnd),1);
%         for j = 1:length(ehnd)
%             evt_names{j} = get(ehnd(j), 'tag');
%         end
%         n_evts = unique(evt_names);
%         if n_evts > 1
%             error(['attempt to 
        
        meanehnd = findobj(ax(i),'string',settings.ensstring);
        
        mn = nanmean(lstk);
        [r,~] = size(lstk);
        
        if isin(nm,'+')                                 % for grouping cons to correct CI
            r = r/2;
        end
        
        
        
        switch vartype
            
            case 'SD'
                userdata = [];
                Var = nanstd(lstk);
                
            case 'CI'
                userdata = [];
                Var = 1.96*nanstd(lstk)./sqrt(r);
                
            case 'CB'
                userdata = [];
                [Cc, ~,~,~,~,~,~,~,sehat_b] = bootstrap_t(lstk,1000,0.05);
                Var = Cc*sehat_b;
                %Var = Cc*sehat;
                %                 Var = Cc*nanstd(lstk)./sqrt(r);  % original
                
            case 'CB (w stats)'
                userdata = [];
                [Cc, ~,~,~,~,~,~,~,sehat_b] = bootstrap_t(lstk,1000,0.05,[nm,' ',ch]);
                Var = Cc*sehat_b; 
        end
        
        bd = get(ax(i),'buttondownfcn');
        [vr,fc] = stdpatch_ensembler(xdata,mn,Var);
        
        if ~isempty(findobj(ax(i),'type','patch','facecolor',[.81 .81,.81]))    %for data that has been ensembled by subject previously
            delete(findobj(ax(i),'type','patch'))
        end
        
        mnhnd = line('parent',ax(i),'xdata',xdata,'ydata',mn,'color',[0 0 0],'linewidth',settings.ensembledLineWidth,...
                     'buttondownfcn',bd,'tag',nm,'userdata',['average_line ',get(ax(i),'tag')]);
        
        if isin(computer,'MAC')
            patch('parent',ax(i),'vertices',vr,'faces',fc,'facecolor',[.8 .8 .8],...
                  'facealpha',1,'edgecolor','none','buttondownfcn',bd,'tag',nm,...
                  'userdata',['average_',vartype,' ',get(ax(i),'tag')]); %,'userdata',evt,'tag',nm);
            
        else
            patch('parent',ax(i),'vertices',vr,'faces',fc,'facecolor',[.8 .8 .8],...
                  'facealpha',.5,'edgecolor','none','buttondownfcn',bd,'tag',nm,...
                  'userdata',['average_',vartype,' ',get(ax(i),'tag')]); %,'userdata',evt,'tag',nm);
        end
        
        
        if ~isempty(ehnd)    % averages events from each trial and displays a single mean event
            tg = get(ehnd,'tag');
            if isempty(tg)
                return
            end
            
            if ~iscell(tg)
                tg = {tg};
            end
            
            tg = unique(tg);
            
            for k = 1:length(tg)
                evt = findobj(ax(i),'string',settings.string,'tag',tg{k});
                estk = [];
                for e = 1:length(evt)
                    plate = get(evt(e),'position');
                    
                    if plate(2)~=999
                        estk = [estk;plate];
                    end
                    
                end
                
                mpos=  nanmean(estk,1);
                
                switch vartype
                    
                    case 'SD'
                        spos = nanstd(estk);
                        
                    case {'CI','CB'} % can't make bands out of discrete points
                        spos = 1.96*nanstd(estk)./sqrt(r);
                        
                end
                
                hold(ax(i),'on')
                
                ebar = errorbar(mpos(1),mpos(2),spos(2),'parent',ax(i),'LineWidth',settings.ensembledEventWidth); % mean event has special width
                set(ebar,'tag',[tg{k},'_av_',nm])
                
                %--horizontal error bar---
                starthor = mpos(1) - spos(1);
                endhor = mpos(1) + spos(1);
                x = (starthor:1:endhor);
                y = mpos(2)*ones(size(x));
                line(x,y,'parent',ax(i),'LineWidth',1.1,'tag',[tg{k},'_av_',nm])
                
                text('parent',ax(i),'position',[round(mpos(1)) mpos(2)],...
                     'tag',[tg{k},'_av_',nm],'string',settings.ensstring,'FontSize',10,...
                     'verticalalignment','middle','horizontalalignment','center',...
                     'color',[1 0 0],'buttondownfcn',get(ax(i),'buttondownfcn'),'userdata',mnhnd);
            
            end
            
            delete(ehnd);
        end
        
        
        if ~isempty(meanehnd)   % averages each subject average event and displays a single mean event
            
            delete(findobj(ax(i),'type','line','linewidth',1.1));
            tg = unique(get(meanehnd,'tag'));
            
            for k = 1:length(tg)
                evt = findobj(ax(i),'string',settings.string,'tag',tg{k});
                estk = [];
                for e = 1:length(evt)
                    plate = get(evt(e),'position');
                    estk = [estk;plate];
                end
                
                mpos=  mean(estk);
                spos = std(estk);
                
                text('parent',ax(i),'position',mpos,'tag',tg{k},'string',settings.ensstring,...
                    'FontSize',10,'verticalalignment','middle','horizontalalignment','center',...
                    'color',[1 0 0],'buttondownfcn',get(ax(i),'buttondownfcn'),'userdata',mnhnd); %[0.2 0.6 0.2]
                hold(ax(i),'on')
                errorbar(mpos(1),mpos(2),spos(2),'parent',ax(i),'LineWidth',1.1)
                
                
                %--horizontal error bar---
                starthor = mpos(1) - spos(1);
                endhor = mpos(1) + spos(1);
                x = (starthor:1:endhor);
                y = mpos(2)*ones(size(x));
                line(x,y,'parent',ax(i),'LineWidth',1.1)
                
            end
            
            delete(meanehnd);
            
        end
        
    end
    
end









