function data = cop_com_inclination_data(data, ch_COM, ch_COP, vertical)

% BMECH_COP_COM_INCLINATION compute the angle between the COP and COM in the
% antero-posterior and medio-lateral diretion with respect to the global vertical
%
% ARGUMENTS
%   data     ...  struct, loaded zoo file
%   ch_COM   ...  str, name of center of mass channel. Default CentreOfMass
%   ch_COP   ...  str, name of center of pressure channel. default COP.
%
% RETURNS
%  data     ...  struct, with cop-com inclination angle appended.
%
% see Lee HJ, Chou LS. Detection of gait instability using the center of
% mass and center of pressure inclination angles. Arch Phys Med Rehabil
% 2006;87:569–75. https://doi.org/10.1016/j.apmr.2005.11.033
%
% see also cbmech_op_com_inclination, cop_com_inclinaton

COM = data.(ch_COM).line;
COP = data.(ch_COP).line;

% compute inclination angle
inc_angle = cop_com_inclinaton(COM, COP, vertical);

% add to zoo
data = addchannel_data(inc_angle, [ch_COM, '_', ch_COP, '_inclination']);