function ensembler_prompt(fld,action)

% SHOW_ENSEMBLER_PROMPT(fld,action)

fig = findobj('type','fig');

if action
    
    temp = concatEnsPrompt(fld);
    for i = 1:length(fig)
        pmt = findobj(fig(i),'tag','prompt');     % get the figure prompt
        set(pmt,'string',temp)
    end
    
else
    
    for i = 1:length(fig)
        pmt = findobj(fig(i),'tag','prompt');     % get the figure prompt
        set(pmt,'string','')
    end
    
end
