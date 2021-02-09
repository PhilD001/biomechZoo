function nplates = get_nforceplates(data)

% find number of force plates used

if isfield(data.zoosystem.Analog.FPlates, 'CORNERS')
    [a, b, nplates] = size(data.zoosystem.Analog.FPlates.CORNERS);
elseif isfield(data.zoosystem.Analog.FPlates, 'NUMUSED')
    nplates = data.zoosystem.Analog.FPlates.NUMUSED;
else
    nplates = 0;
end

% lower number of force plates if mismatch between CORNERS and local coord
% 
[a, local_orig] = size(data.zoosystem.Analog.FPlates.LOCALORIGIN);
if local_orig < nplates
    nplates = local_orig;
end