function bmech_rename_subnames(fld,zone)

% changes subnames from random to regular subject listing
%
% ARGUMENTS
%  fld    ...  folder to operate on
%  zone   ...  number of subfolders in structure. Default 1
%
% Updated October 2011
% - compatible with mac platforms
%
% Updated June 2012
% - fixed problem when first folder was correct
%
% Updated November 2013
% -works with group/condition combinations


if nargin==0
    fld = uigetfolder;
    zone = 2;
end

if nargin==1
    zone = 2;
end

fl = engine('path',fld,'extension','zoo');


base = 'subject';                    % base name for subject names

sfld = subdir(fld);
l = length(strfind(fld,slash));

count = 0;


if zone==1  % structure: root folder - subject - conditions
    
    for i = 1:length(sfld)
        
        pth = sfld{i};
        pl = length(strfind(pth,slash));
        
        if pl==l+1
            
            count = count +1;
            
            if count<10
                pad = '0';
            else
                pad = '';
            end
            
            indx = strfind(pth,slash);
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
    
    
    
else   % structure: root folder - group - subject - conditions
    
    
    grp = cell(length(fl),1);
    
    
    for i = 1:length(fl)
        data = load(fl{i},'-mat');
        data = data.data;
        grp{i} = group(fl{i});
    end
    
    grp = unique(grp);
    
    
    for j = 1:length(grp)
        
        
        for i = 1:length(sfld)
            
            pth = sfld{i};
            pl = length(strfind(pth,slash));
            
            if pl==l+2 && isin(pth,grp{j})
                
                count = count +1;
                
                if count<10
                    pad = '0';
                else
                    pad = '';
                end
                
                indx = strfind(pth,slash);
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
        
    end
    
end