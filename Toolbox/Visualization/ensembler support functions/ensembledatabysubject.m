function ensembledatabysubject(vartype)

s = filesep;    % determine slash direction based on computer type
ax = findensobj('axes');


% try to find subject name prefix
%
ln = findobj(ax(1),'type','line','linewidth',.5);

t = get(ln(1),'UserData');
if isin(t,'subject')
    str = 'subject';
    add = 7;
elseif isin(t,'P')
    str = 'P';
    add = 1;
else
    prompt={'Enter the subject prefix:'};
    name='subject prefix';
    numlines=1;
    defaultanswer={'subject'};
    
    str=inputdlg(prompt,name,numlines,defaultanswer);
    str = str{1};
    add = length(str);
end


for i = 1:length(ax)
   
    ln = findobj(ax(i),'type','line','linewidth',.5);

    
    % Extract all subject names
    %
    stk = zeros(length(ln),1);
    ecell = cell(1,length(ln));
    
    for a = 1:length(ln)  % figure out number of subjects
        fl = get(ln(a),'UserData');
        
        [pth,file] = fileparts(fl);
        subindx = strfind(pth,str);
        
        if length(subindx) > 1  % probably the last one is best
            subindx = subindx(end);
        end
        
        slashindx = strfind(fl(subindx:end),s);
        stk(a) = str2double(fl(subindx+add:subindx+slashindx(1)-2));
        ecell{a} = fl(subindx+add:subindx+slashindx(1)-2);
    end
    
    subjectnums = unique(ecell) ;
    
    pt = get(ax(i),'parent');       %parent of axis is figure
    nm = get(pt,'name');
    
    ehnd = findobj(ax(i),'string','\diamondsuit');   % find all events
    ln = findobj(ax(i),'type','line','linewidth',.5); % find all lines
    
    mnstk =[];
    ststk = [];
    
    for k = 1:length(subjectnums)    %-------------ensemble lines----------------
        
        dstk = [];
        
        for j = 1:length(ln)
            if ~isempty(strfind(get(ln(j),'UserData'),[str,subjectnums{k}]))
                indx =strfind(get(ln(j),'UserData'),[str,subjectnums{k}]);
                flnm = get(ln(j),'UserData');
                disp(['stacking ', flnm(indx:end)])
                %                 disp(['stacking ', get(ln(j),'UserData')])
                yd = get(ln(j),'ydata');
                dstk = stack_ensembler(dstk,yd);
            end
        end
        disp('--------')
        
        if isempty(dstk)
            continue
        end
        
        [r,c] = size(dstk);
        
        if r ~=1
            mn = nanmean(dstk);
            
            switch vartype
                
                case 'SD'
                    st = nanstd(dstk);
                    
                case 'CI'
                    st = nanstd(dstk)./sqrt(r);
                    
                case 'CB'
                    [~, ~, Cc] = bootstrap_lenhoff(dstk,1000,0.05);
                    st = Cc*nanstd(lstk)./sqrt(r);
                    
                case 'SCI'
                    st = nanstd(dstk)./sqrt(r);
            end
            
        else
            mn = dstk;
            st = zeros(r,c);
        end
        
        mnstk = stack_ensembler(mnstk, mn);              %mean data for each subject
        ststk = stack_ensembler(ststk, st);
        
    end
    
    ehnd = findobj(ax(i),'string','\diamondsuit');
    ehndcopy = ehnd;
    
    if ~isempty(ehnd)
        tg = unique(get(ehnd,'tag'));
        
        all_msub_xstk = [];
        all_stdsub_xstk = [];
        all_msub_ystk = [];
        all_stdsub_ystk = [];
        
        for k = 1:length(subjectnums)   % ensemble events vents
            
            subxstk=[];
            subystk=[];
            
            for m = 1:length(tg)
                xstk = [];
                ystk =[];
                
                for c=1:length(ehnd)
                    if  strcmp(get(ehnd(c),'tag'),tg{m})==1 % is event of the right type
                        
                        if ~isempty(strfind(get(get(ehnd(c),'UserData'),'UserData'),[str,subjectnums{k}])); % if correct subject
                            disp(['for file:', get(get(ehnd(c),'UserData'),'UserData')])
                            disp('event')
                            pos = get(ehnd(c),'position');
                            xstk = [xstk ; pos(1)];
                            ystk = [ystk ; pos(2)];
                        end
                    end
                end
                subxstk = [subxstk xstk]; % stacks all events of a single subject: columns events, rows trials
                subystk = [subystk ystk]; % stacks all events of a single subject: columns events, rows trials
            end
            
            msubxstk = mean(subxstk,1);
            stdsubxstk = std(subxstk,1);
            
            msubystk = mean(subystk,1);
            stdsubystk = std(subystk,1);
            
            all_msub_xstk = [all_msub_xstk; msubxstk];          %stack of all means of xdata for each subject
            all_stdsub_xstk = [all_stdsub_xstk; stdsubxstk];
            all_msub_ystk = [all_msub_ystk; msubystk];
            all_stdsub_ystk = [all_stdsub_ystk; stdsubystk];
        end
        
    end
    
    delete(ln)      %delete once all lines have been collected
    delete(ehnd)
    
    %----------plot average lines and standard deviation-------------------
    
    for b = 1:length(subjectnums)
        bd = get(ax(i),'buttondownfcn');
        [vr,fc] = stdpatch_ensembler(mnstk(b,:),ststk(b,:));
        pch = patch('parent',ax(i),'vertices',vr,'faces',fc,'facecolor',[.81 .81,.81],'facealpha',.5,'edgecolor','none','buttondownfcn',bd,'userdata',[],'tag',['subject',subjectnums{b},'/',nm,'std']);
    end
    
    for c = 1:length(subjectnums)
        mnhnd=line('parent',ax(i),'xdata',(0:length(mnstk(c,:))-1),'ydata',mnstk(c,:),'color',[0 0 0],'linewidth',0.5,'buttondownfcn',bd,'tag',['subject',subjectnums{c},'/',nm],'userdata',[]);
        
        if ~isempty(ehndcopy)
            for e=1:length(tg)
                text('parent',ax(i),'position',[all_msub_xstk(c,e) all_msub_ystk(c,e)] ,...
                    'tag',[tg{e},'_average'],'string','\bullet','FontSize',10,'verticalalignment','middle',...
                    'horizontalalignment','center','color',[1 0 0],'buttondownfcn',get(ax(i),'buttondownfcn'),...
                    'userdata',mnhnd);
                hold(ax(i),'on')
                errorbar(all_msub_xstk(c,e), all_msub_ystk(c,e), all_stdsub_ystk(c,e),'parent',ax(i),'LineWidth',1.1,...
                    'Tag',tg{e})
                
                
                %--horizontal error bar---
                starthor = all_msub_xstk(c,e) - all_stdsub_ystk(c,e);
                endhor = all_msub_xstk(c,e) + all_stdsub_ystk(c,e);
                x = (starthor:1:endhor);
                y = all_msub_ystk(c,e)*ones(size(x));
                line(x,y,'parent',ax(i),'LineWidth',1.1,'Tag',tg{e})
                
                
            end
        end
        
    end
    
end
