% These code snippets are answers to the additional exercies listed in the
% 'additional_exercises.docx' file. Other solutions are possible. The code
% snippets could be included in the zoo_process_example process script to 
% conduct additional analyses
%
% Created by Philippe C. Dixon June 2015

%% Exercise 1
%
% The following code could be inserted anywhere after 'STEP 4' in  the end
% of our processing script
%
fld = uigetfolder;    % select appropriate channel 
och = {'RGroundReactionForce_x','RGroundReactionForce_y','RGroundReactionForce_z','RHipAngles_x',...
       'RHipAngles_y','RHipAngles_z','RKneeAngles_x','RKneeAngles_y','RKneeAngles_z'};
nch = strrep(och,'R','Right');

bmech_renamechannel(och,nch,fld);

%% Exercise 2
%
% This process is best implemented in the addevent section of our processing script
%
fld = uigetfolder;                                  % select addevent folder
ename = 'ROM';                                      % name of the event in your zoo file
etype = 'rom';                                      % 'case' in addevents.m
bmech_addevent(fld,'RHipAngles_x',ename,etype)      

%% Exercise 3
%
% This process could be implemented anywhere after the addevent section of our processing script
%
fld = uigetfolder;
oevt = 'ROM';                                      % old event name
nevt = 'rom';                                      % new event name
bmech_renameevent(fld,oevt,nevt)

%% Exercise 4
%
% This process could be implemented at the end of our processing script.
% For example, this is useful to avoid having to clear events in ensembler
%
fld = uigetfolder;
evt = 'all';
ch = 'all';                         
bmech_removeevent(fld,evt,ch)                           


