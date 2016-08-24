function sample_prop(r,h,c)

% SAMPLE_PROP(r,h,c) demonstrates how to create a simple cylinder for use
% in director as a 'prop' object. 
%
% ARGUMENTS
% r  ... radius of cylinder
% h  ... height of cylinder
% c  ... color of cyclinder e.g. [1 0 0]
%
% NOTES
% - run function with or without arguments
% - after director object (prop) is created, prop will be loaded into ensembler

% Set defaults
%
if nargin==0
    r = 10;
    h = 10;
    c = [1 0 0];
end

if nargin==2
    c = [0.8 0.8 0.8];
end


% Get path
%
d = which('director'); % returns path to ensemlber
path = pathname(d) ;   % local folder where director resides
s = filesep;


% Create cylinder
%
[X,Y,Z] = cylinder(r,36);


% Create vertices and faces
%
vert_X = [X(1,1:end-1)'; X(2,1:end-1)'; 0 ; 0];
vert_Y = [Y(1,1:end-1)'; Y(2,1:end-1)'; 0 ; 0];
vert_Z = [Z(1,1:end-1)'; Z(2,1:end-1)'*h; 0; h];

vertices = [vert_X vert_Y vert_Z];

faces = getfaces;

cdata = [];
cdata(1,1:length(faces(:,1)),1) = c(1);
cdata(1,1:length(faces(:,1)),2) = c(2);
cdata(1,1:length(faces(:,1)),3) = c(3);

object.id = 'cylinder';
object.vertices = vertices;
object.faces = faces;             % #ok<*STRNU>
object.cdata = cdata;             % define a color

% save new prop
%
p2 = [path,'cinema objects',s,'sample',s];

if r==1 && h==1
    f2 = 'cylinder.prop';
else
    f2 = ['cylinderR_',num2str(r),'H_',num2str(h),'.prop'];
end
save([p2,f2],'object')


% Load prop into director

director                    % uncomment to load
props('load',[p2,f2])       % uncomment to load


function faces = getfaces

faces = [1     2    38
    2     3    39
    3     4    40
    4     5    41
    5     6    42
    6     7    43
    7     8    44
    8     9    45
    9    10    46
    10    11    47
    11    12    48
    12    13    49
    13    14    50
    14    15    51
    15    16    52
    16    17    53
    17    18    54
    18    19    55
    19    20    56
    20    21    57
    21    22    58
    22    23    59
    23    24    60
    24    25    61
    25    26    62
    26    27    63
    27    28    64
    28    29    65
    29    30    66
    30    31    67
    31    32    68
    32    33    69
    33    34    70
    34    35    71
    35    36    72
    1    38    37
    2    39    38
    3    40    39
    4    41    40
    5    42    41
    6    43    42
    7    44    43
    8    45    44
    9    46    45
    10    47    46
    11    48    47
    12    49    48
    13    50    49
    14    51    50
    15    52    51
    16    53    52
    17    54    53
    18    55    54
    19    56    55
    20    57    56
    21    58    57
    22    59    58
    23    60    59
    24    61    60
    25    62    61
    26    63    62
    27    64    63
    28    65    64
    29    66    65
    30    67    66
    31    68    67
    32    69    68
    33    70    69
    34    71    70
    35    72    71
    36     1    37
    36    37    72
    1     2    73
    2     3    73
    3     4    73
    4     5    73
    5     6    73
    6     7    73
    7     8    73
    8     9    73
    9    10    73
    10    11    73
    11    12    73
    12    13    73
    13    14    73
    14    15    73
    15    16    73
    16    17    73
    17    18    73
    18    19    73
    19    20    73
    20    21    73
    21    22    73
    22    23    73
    23    24    73
    24    25    73
    25    26    73
    26    27    73
    27    28    73
    28    29    73
    29    30    73
    30    31    73
    31    32    73
    32    33    73
    33    34    73
    34    35    73
    35    36    73
    38    37    74
    39    38    74
    40    39    74
    41    40    74
    42    41    74
    43    42    74
    44    43    74
    45    44    74
    46    45    74
    47    46    74
    48    47    74
    49    48    74
    50    49    74
    51    50    74
    52    51    74
    53    52    74
    54    53    74
    55    54    74
    56    55    74
    57    56    74
    58    57    74
    59    58    74
    60    59    74
    61    60    74
    62    61    74
    63    62    74
    64    63    74
    65    64    74
    66    65    74
    67    66    74
    68    67    74
    69    68    74
    70    69    74
    71    70    74
    72    71    74
    36     1    73
    37    72    74];

