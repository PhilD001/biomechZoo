function bmech_change_subnames(fld)

% changes subnames from random to regular subject listing. eg. subject01,
% subject02, ...
%
% ARGUMENTS
%  fld  ...  folder to operate on
%
%
% Updated October 2011
% - compatible with mac platforms
%
% Updated June 2012
% - fixed problem when first folder was correct
% 
%
%
% Part of the Zoosystem Biomechanics Toolbox 
% Philippe C. Dixon

if nargin==0
    fld = uigetfolder;
end

s = slash;

base = 'subject';

sfld = subdir(fld);

l = length(strfind(fld,s));

count = 0;

for i = 1:length(sfld)
    
    pth = sfld{i};
    pl = length(strfind(pth,s));
    
    if pl==l+1
        
        count = count +1;
        
        if count<10
            pad = '0';
        else
            pad = '';
        end
        
        indx = strfind(pth,s);
        eindx = indx(end);
        root = pth(1:eindx);
        
        npth = [root,base,pad,num2str(count)];

        enpth = npth(eindx+1:end);
        epth = pth(eindx+1:end);
        if strcmp(enpth,epth)==0
            disp(['moving folder: ',pth])
            disp(['to:' npth])
            movefile(pth,npth,'f')
        end
    end
end