function r = makeunit(unt)

%   MAKEUNIT  makes all vectors unit vectors
%   unt ... N by 3 matrix of vectors.
%           rows are the number of vectors
%           columns are XYZ
%
% Created by JJ Loh ??
%
% updated November 2011 by Phil Dixon 
% - can normalize nx2 vectors

[~,c] = size(unt);


if c==3
    r = [];
    if iscell(unt)
        for i = 1:length(unt)
            plate = unt{i};
            mg = diag(sqrt(plate*plate'));
            plate = plate./[mg,mg,mg];
            r{i} = plate;
        end
    else
        mg = diag(sqrt(unt*unt'));
        plate = unt./[mg,mg,mg];
        r = plate;
    end
    
elseif c==2
    
    r = [];
    if iscell(unt)
        for i = 1:length(unt)
            plate = unt{i};
            mg = diag(sqrt(plate*plate'));
            plate = plate./[mg,mg];
            r{i} = plate;
        end
    else
        mg = diag(sqrt(unt*unt'));
        plate = unt./[mg,mg];
        r = plate;
    end
    
else
    
    if iscell(unt)
        for i = 1:length(unt)
            plate = unt{i};
            mg = diag(sqrt(plate*plate'));
            plate = plate./[mg,mg,mg];
            r{i} = plate;
        end
    else
        mg = diag(sqrt(unt*unt'));
        plate = unt./[mg,mg,mg];
        r = plate;
    end
    
    
    
    
    
    
end