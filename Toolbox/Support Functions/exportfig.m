function exportfig(fld,filename)

% EXPORTFIG(fld,filename) exports ensembler figures for use in publications / LateX
% see for more details: https://github.com/ojwoodford/export_fig

% NOTES
% - 'ghostscript' is required for pdf save
% - pdf save is chosen to obtain a vectorized (lossless) image;
% - If axes box does not appear 'vline' or 'hline' can be called


% Revision History
%
% Updated by Philippe C. Dixon Oct 21st 2014
% -automatically searches for figure name to use as file name
%
% Updated by Philippe C. Dixon Oct 30th 2014
% - choice to use or not use painters output. It is best to have paint 'on'
%   if dashed or dotted lines make up the curves in the figure to be exported
%
% Updated by Philippe C. Dixon July 2016
% - full support for ensembler plots on MAC and PC running r2016b and above


tic
disp('starting image save...')
disp(' ')


if nargin==0
    cd(pwd)
    fld = uigetfolder;
    fig = get(gcf,'name');
    filename=inputdlg('enter file name','file name:',1,{fig});
end

cd(fld)


if ~iscell(filename)
    filename = {filename};
end

% save backup matlab figure before changes are made
%
%saveas(gcf,[filename{1},'.fig'])

% make some common fixes to the figure
%
% remove emsembler prompt (if found)
prmt = findobj('type','uicontrol','Tag','prompt');
if ~isempty(prmt)
    delete(prmt)
end

% increase spacing between ylabels and axis
%
% if strfind(computer,'MACI')
%     ax = findensobj('axes');
%     for i = 1:length(ax)
%         ylab = get(ax(i),'YTickLabels');
%         for j = 1:length(ylab)
%             if isempty(strfind(ylab{j},' '))
%                 ylab{j} = [ylab{j},'  '];
%             end
%         end
%         set(ax(i),'YTickLabels',ylab)
%     end
% end


% set background to white
%set(gcf,'color',[1 1 1])


% figure out platform
%


% export to figure
%
if isempty( findobj('tag','colormap'))
    export_fig(filename{1}, '-pdf', '-transparent','-q101')  % painters used by default
else
    export_fig(filename{1}, '-png', '-transparent','-r150')     % cannot vectorize colorbars
end

% if verLessThan('matlab','8.4.0')    % execute code for R2014a or earlier
%
%     if isempty( findobj('tag','colormap'))
%         export_fig(filename{1}, '-pdf', '-transparent','-q101')  % painters used by default
%     else
%         export_fig(filename{1}, '-png', '-transparent','-r150')     % cannot vectorize colorbars
%     end
% else
%     export_fig(filename{1}, '-png', '-transparent','-r150')     % cannot vectorize colorbars
% end





disp(['image files saved to disk in ',num2str(toc),' sec'])


