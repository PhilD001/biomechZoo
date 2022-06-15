function inc_angle = cop_com_inclinaton(COM, COP, vertical_unit)

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

% create COP_COM vector
COP_COM = COM-COP;

% compute inclination angle
inc_angle = asin( cross(COP_COM, v) / magnitude(COP_COM));





