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
%
% updated May 2022 by Phil Dixon
% - rely on magnitude function

r = [];
if iscell(unt)
    for i = 1:length(unt)
        plate = unt{i};
        mg = magnitude(plate);
        plate = plate./mg;
        r{i} = plate;
    end
else
    mg = magnitude(unt);
    plate = unt./mg;
    r = plate;
end

