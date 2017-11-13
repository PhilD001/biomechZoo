function settings = ensembler_settings(user_settings)

% settings = ENSEMBLER_SETTINGS(user_settings) sets all the default style settings for ensembler
%
% ARGUMENTS
%   user_settings  ...  new set of settings based on user preference. This
%                       option is not currently operational. Eventually,
%                       users could set and save their own style preferences
%
% RETURNS
%   settings       ...  structured array of settings to be used in
%                       ensembler

if nargin==0
    settings.string = '\bullet';                 % style for event
    settings.ensstring = '\diamondsuit';         % style for ensembled event
    settings.verticalalignment = 'middle';
    settings.horizontalalignment = 'center';
    settings.FontSize = 14;
    settings.color = [1 0 0];
    
    settings.regularLineStyle  = '-';
    settings.regularLineWidth = 0.5;
    settings.regularLineColor = [0 0 0];
    
    settings.selectedLineWidth = 2;              % selected line width
    settings.selectedLineColor = [0 0 .98];      % selected line color
    settings.selectedLineStyle = '--';           % selected line style
    
    settings.selectedPatchColor = [0 0 .98];
    
    settings.ensembledPatchColor = [0.8 0.8 0.8];
    settings.ensembledLineStyle = '-';
    settings.ensembledLineColor = [0 0 .98];
    settings.ensembledLineWidth = 1.5;
    settings.ensembledEventWidth = 1.12;
    
    
    
end