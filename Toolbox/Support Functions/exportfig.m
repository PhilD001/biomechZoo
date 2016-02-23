function exportfig(fld,filename)

% EXPORTFIG(fld,filename)exports figures for use in publications / LateX
% see for more details: https://github.com/ojwoodford/export_fig

% NOTES
% - 'ghostscript' is required for pdf save 
% - pdf save is a great choice to obtained a vectorized (lossless) image;
%   however, some images using non-standard patches do not render correctly
%   in pdf. This is a known Matlab issue 


% Revision History
%
% Updated by Philippe C. Dixon Oct 21st 2014
% -automatically searches for figure name to use as file name

% Updated Oct 30th 2014
% - choice to use or not use painters output. It is best to have paint 'on'
%   if dashed or dotted lines make up the curves in the figure to be exported
%
% Updateed January 18th 2015
% - set to pdf for beautiful figures!


tic
disp('starting image save...')
disp(' ')
% if isin(computer,'MACI')
%     error('problems on mac platform')
% end


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


% check for ensembler prompt
%
prmt = findobj('type','uicontrol','Tag','prompt');

if ~isempty(prmt)
    delete(prmt)
end


% export to figure
%
if isempty( findobj('tag','colormap'))
     export_fig(filename{1}, '-pdf', '-transparent','-q101')  % painters used by default
else
    export_fig(filename{1}, '-png', '-transparent','-r150')     % cannot vectorize colorbars
end



% save backup matlab figure
%
saveas(gcf,[filename{1},'.fig'])

disp(['image files saved to disk in ',num2str(toc),' sec'])


