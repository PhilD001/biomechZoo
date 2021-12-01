function bmech_muscle_cocontraction(fld,ch)
% This function computes co-contraction index for chanels
% ARGUMENTS
%  fld         ...   folder to operate on
%  chanels     ...   Default = {'Rect_Hams','Gast_Tib'}
% NOTES
% See cocontraction_line for co-contraction computational approach


% Batch process
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'muscle_cocontraction')
    data = muscle_cocontraction_data(data,ch);
    zsave(fl{i},data);
end


function data = muscle_cocontraction_data(data,ch,sides)
    % This function computes co-contraction indices
    % ARGUMENTS
    %  data     ...   zoo struct
    %  ch    ...      Names of chanels
    %  sides    ...   Prefix for limb side. Default = {'R','L'}

    % RETURNS
    %  data     ...  updated zoo struct

    % NOTES
    % See cocontraction_line for co-contraction computational approach
    % See also bmech_cocontraction, cocontraction_line

    if nargin==2
        sides = {'R','L'};
    end

    for i = 1:length(ch)
        muscles = strsplit(ch{i},'_');

        for j = 1:length(sides)
            muscle1 = data.([sides{j},muscles{1}]).line;
            muscle2 = data.([sides{j},muscles{2}]).line;

            disp(['computing co-contraction for muscles ',sides{j},muscles{1},' and ',sides{j},muscles{2}])
            r = cocontraction_line(muscle1,muscle2);
            data = addchannel_data(data,[sides{j},muscles{1},'_',muscles{2}],r,'Analog');
        end
    end


% vishnu_function= cocontraction_line
function cc= cocontraction_line(muscle1,muscle2,method,plotGraph)
        
% This function computes co-contraction indices for
%      muscle pairs (muscle 1 and muscle2)

% ARGUMENTS
%  muscle1      ...   n x 1 or 1 x n  vector of processed EMG data
%  muscle2      ...   n x 1 or 1 x n  vector of processed EMG data
%  method       ...   Choice of algorithm to use. Choices: 'Vishnu' function
%  plotGraph    ...   Choice to plot graph (boolean). Default false

% RETURNS
%  cc           ...   n x 1  vector of co-contraction indices

% NOTES
% Algorithm choice:
% Vishnu code which is based on "Winter, Biomechanics and Motor Control of
% Human Movement, 4th ed"

if nargin==2
    plotGraph = false;
    method = 'Vishnu';
end

if nargin==3
    method = 'Vishnu';
end

if length(muscle1) ~=length(muscle2)
    error('vectors should be of same size')
end

[r,c] = size(muscle1);
if  c>1
    muscle1 = makecolumn(muscle1);
    muscle2 = makecolumn(muscle2);
end

cc = zeros(r,c);
for i =1:length(muscle1)

    m1 = muscle1(i);
    m2 = muscle2(i);
    %     area_under_GasTib_stride = [];
    %     area_under_RectHam_stride = [];
    area_under_m1m2_stride = [];

    tstrt = 'FOminus3';
    tend  = 'FSplus2';

    k=1;
    for j = FOminus3:FSplus2
        %         area_under_GasTib_stride(end+1,1)= min(L_Gast_rect_RMS_normalized(j,1),L_Tib_Ant_rect_RMS_normalized(j,1));
        %         area_under_RectHam_stride(end+1,1)= min(L_Rect_rect_RMS_normalized(j,1),L_Hams_rect_RMS_normalized(j,1));
        area_under_m1m2_stride(end+1,1)= min(m1_rect_RMS_normalized(j,1),m2_rect_RMS_normalized(j,1));
        k=k+1;
    end

    %     area_GAS{i,1}= trapz(L_Gast_rect_RMS_normalized(FOminus3:FSplus2,:));
    %     area_TIB{i,1}= trapz(L_Tib_Ant_rect_RMS_normalized(FOminus3:FSplus2,:));
    %     area_RECT{i,1}= trapz(L_Rect_rect_RMS_normalized(FOminus3:FSplus2,:));
    %     area_HAM{i,1}= trapz(L_Hams_rect_RMS_normalized(FOminus3:FSplus2,:));
    area_m1{i,1}= trapz(m1_rect_RMS_normalized(FOminus3:FSplus2,:));
    area_m2{i,1}= trapz(m2_rect_RMS_normalized(FOminus3:FSplus2,:));


    %     area_GasTib{i,1} = trapz(area_under_GasTib_stride);
    %     area_RectHam{i,1} = trapz(area_under_RectHam_stride);
    area_m1m2{i,1} = trapz(area_under_m1m2_stride);

    %     coContraction_GasTib{i,3} = 2*(area_GasTib{i,1}/(area_GAS{i,1}+area_TIB{i,1}))*100;
    %     coContraction_RectHam{i,3} = 2*(area_RectHam{i,1} /(area_RECT{i,1}+area_HAM{i,1}))*100;
    coContraction_m1m2{i,3} = 2*(area_m1m2{i,1} /(area_m1{i,1}+area_m2{i,1}))*100;
end
        
        
        
