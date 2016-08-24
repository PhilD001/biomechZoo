function pubfonts(FontSize,FontWeight,FontName)

% PUBFONTS(FontSize,FontWeight,FontName)changes fonts and sizes to 'good' parameters for 
% publication or latex documents
%
% ARGUMENTS
%  FontSize    ...  Size of font. Default 14
%  FontWeight  ...  Weight of font ('normal' or 'bold'). Default 'normal'
%  FontName    ...  Name of font. Default 'arial'

% NOTES
% - The default weight and name are probably best. For consistency all parts of a figure
%   should have similar font style and size


% Revision History
%
% Created by Philippe C. Dixon November 2013 
%
% Updated by Philippe C. Dixon June 2015
% - simplified options
% - optimized for use in ensembler


% Part of the Zoosystem Biomechanics Toolbox 
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
% 
% Contact: 
% philippe.dixon@gmail.com
%
% Web: 
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis 
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in 
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 




% Prompt for settings
%
if nargin==0
    prompt={'FontSize','FontWeight','FontName'};
    defaultanswer = {'14','normal','Arial'};
    a = inputdlg(prompt,'axis title',1,defaultanswer);
    
    FontSize = str2double(a{1});
    FontWeight = a{2};
    FontName = a{3};
end




% Find figure elements
%
txt = findobj('type','text');
ebar = findobj('type','hggroup','tag','ebar');
lg = findobj('type','axes','tag','legend');
ax = findobj('type','axes');
ax = setdiff(ax,lg);
pmt = findobj('tag','prompt');


% Set new styles
%
set(ebar(1:length(ebar)),'LineWidth',2)
set(ax(1:length(ax)),'FontSize',FontSize,'FontWeight',FontWeight,'FontName',FontName)
set(txt(1:length(txt)),'FontSize',FontSize,'FontWeight',FontWeight,'FontName',FontName)


% remove figure elements
%
delete(pmt)


