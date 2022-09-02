function bmech_cop_com_inclination(fld, ch_com, ch_cop, vertical)
% BMECH_COP_COM_INCLINATION compute the angle between the COP and COM in the
% antero-posterior and medio-lateral diretion with respect to the global vertical
%
% ARGUMENTS
%   fld   ...  str, folder to operate one
%
% see Lee HJ, Chou LS. Detection of gait instability using the center of
% mass and center of pressure inclination angles. Arch Phys Med Rehabil
% 2006;87:569–75. https://doi.org/10.1016/j.apmr.2005.11.033
% 
% see also cop_com_inclination_data, cop_com_inclinaton


% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'computing cop-com angle');
    data = cop_com_inclination_data(data, ch_com, ch_cop, vertical);
    zsave(fl{i},data);
end



