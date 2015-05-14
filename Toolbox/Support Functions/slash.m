function [s,type] = slash

% returns appropriate slash direction for use on mac and PC platforms
%
% [s,type] = slash
% RETURNS
%  s     ... appropriate slash direction
%  type  ... operating system
%
% created by Phil Dixon October 2011
%
% updated Oct 2011
% - also works with 64 bit windows
%
% updated March 2013
% - also outputs computer type


type = computer;

switch type
    
        
    case {'PCWIN64','PCWIN'}
        s= '\';
        
    case {'MAC','MACI','MACI64'}
        s= '/';
        
    otherwise
        s = '\';
end