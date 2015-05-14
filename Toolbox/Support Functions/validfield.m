function r = validfield(fld)

% updated October 2011
% - oxford gait lab c3d files can now be converted to zoo

fld = strrep(fld,' ','_');
fld = strrep(fld,'-','');
fld = strrep(fld,'(','');
fld = strrep(fld,')','');
fld = strrep(fld,'+','');
fld = strrep(fld,'.','');
fld = strrep(fld,'\','');
fld = strrep(fld,'*','');
fld = strrep(fld,':','');
fld = strrep(fld,'#','');
fld = strrep(fld,'$','');
fld = strrep(fld,'%','');
fld = strrep(fld,'!','');



if isempty(fld)
    r = fld;
    return
end
if strcmp(fld(1),'_')
    fld(1) = '';
end
if ~isempty(str2double(fld(1))) % str2num
     fld = ['z',fld];
end
r = fld;