function r = extractevents(fld,cons,subjects,ch,evt)

% R = EXTRACTEVENTS(FLD,SUBJECTS,CONS,CH,EVT) extracts event data from zoo file
%
% ARGUMENTS
%  fld         ...    Folder to operate on as string
%  cons        ...    List of conditions (cell array of strings)
%  subjects    ...    List of subject names (cell array of strings)
%  ch          ...    Channel to analyse (string)
%  evt         ...    Event to analyse (string)
%
% RETURNS
%  r           ...    Event data by condition (structured array)


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon (D.Phil.), Harvard University. Cambridge, USA.
% Yannick Michaud-Paquette (M.Sc.), McGill University. Montreal, Canada.
% JJ Loh (M.Sc.), Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com or pdixon@hsph.harvard.edu
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the conference abstract below if the zoosystem was used in the
% preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement
% Analysis Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of
% Movement Analysis in Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.


r = struct;
s = filesep;                                                    % determines slash direction

for i = 1:length(cons)
    estk = NaN*ones(length(subjects),1);
    
    for j = 1:length(subjects)
        file =   engine('path',[fld,s,subjects{j},s,cons{i}],'extension','zoo');
        
        if ~isempty(file)
            data = zload(file{1});                              % load zoo file
            evtval = findfield(data.(ch),evt);                  % searches for local event
            
            if isempty(evtval)                                  % searches for global event
                evtval = findfield(data,evt);                   % if local event is not
                evtval(2) = data.(ch).line(evtval(1));          % found
            end
            
            if evtval(2)==999                                   % check for outlier
                evtval(2) = NaN;
            end
            
            estk(j) = evtval(2);                                % add to event stk
        end
        
    end
    r.(cons{i})= estk;                                          % save to struct
end





