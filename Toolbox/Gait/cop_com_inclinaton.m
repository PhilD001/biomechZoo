function [inc_angle_ap, inc_angle_ml] = cop_com_inclinaton(COM, COP, vertical_unit)

if vertical_unit == 'k'
    v = [0 0 1];
elseif vertical_unit == 'j'
    v = [0 1 0];
elseif vertical_unit == 'i'
    v = [1 0 0];
else
    eror(['unknown unit vector direction: ', vertical_unit])
end


% make v the size of incoming data
v = repmat(v, length(COM), 1);

% create COP_COM unit vector
COP_COM = makeunit(COM-COP);

% inclination in each plane
COP_COM_ap = [ zeros(length(v), 1),  COP_COM(:, 2:3)];
COP_COM_ml = [ COP_COM(:, 1:2), zeros(length(v), 1)];

% compute inclination angle in degrees
inc_angle_ap = angle(COP_COM_ap, v, 'deg');
inc_angle_ml = angle(COP_COM_ml, v, 'deg');




