function bmech_imu_gait_cycle_sepration(fld,n_cycles)

fl = engine('fld', fld, 'extension', 'zoo');
for i = 1:length(fl)
    batchdisp(fl{i}, 'extracting gait cycles')
    [fpath, fname, ext] = fileparts(fl{i});
    data = load(fl{i},'-mat');
    r = data.data;
    alldata = gait_side_data(r,n_cycles);
    ncycles = fieldnames(alldata);
    for j = 1:length(ncycles)
        fname_cycle = [fpath, filesep, fname , '_cycle_',   num2str(j), ext];
        disp(['...cycle ', num2str(j)])
        data = alldata.(ncycles{j});
        zsave(fname_cycle,data)
    end
    
    delfile(fl{i})
    
end

function alldata= gait_side_data(data,n_cycles)
% generate a structure of data structs

% extracting Right side gait cycle data
HSevts=fieldnames(data.shankR_Gyr_X.event);
alldata= gait_struct(data,HSevts,n_cycles);


function gait = gait_struct(data,HSevts,n_cycles)

HS = [];
for i = 1:length(HSevts)
    if contains(HSevts{i}, 'RHS')
        r = data.shankR_Gyr_X.event.(HSevts{i});
        HS(i)  =r(1);
    end
end

gait = struct;
for i=1:length(HS)-n_cycles
    start_row=HS(i);
    end_row= HS(i+n_cycles);
    Gait_out=[];
            
    for run=1:n_cycles
        gaitcondition= HS(i+run)-HS(i+run-1);
        if gaitcondition<150
            condition='True';
        else
            condition='False';
        end
        Gait_out= [Gait_out,condition];
    end
    
    if contains(Gait_out,'False')
        disp(['...cycle rejected'])
    else
        data_new = partition_data(data, HSevts{i}, HSevts{i+n_cycles});
        %data_new.avg_cycle_time.line = (HSevts{i+n_cycles}-HSevts{i}+1)/n_cycles;
        gait.(['cycle', num2str(i)]) = data_new;
    end
end

%add extracted cycles gait.cycle_num= total extracted gait cycles
% 
% cycle_total = struct('line',cycle_num-1,'event',double.empty(0,3));
% gait(:,cycle_num)=table(cycle_total);
% gait.Properties.VariableNames{cycle_num}= 'cycle_num';
% cycle_num=cycle_num+1;
% %add extracted var gait.var_num= total extracted var gait cycles
% var_total = struct('line',var_num-1,'event',double.empty(0,3));
% gait(:,cycle_num)=table(var_total);
% gait.Properties.VariableNames{cycle_num}= 'var_num';
% 
% 
% %table to struct conversation
% gait=table2struct(gait);

function [cycle,var_num] = add_gait_event(data,i,n_cycles,HS,side,var_num)
posi_si_var = "shank"+(side)+"_Gyr_X";
MS = (side)+ "MS";
TO = (side)+ "TO";
M_S = data.(posi_si_var).event.(MS)(i:i+n_cycles)-HS(i);
T_O = data.(posi_si_var).event.(TO)(i:i+n_cycles)-HS(i);
H_S = HS(i:i+n_cycles)-HS(i);% HS(i:i+n_cycles)-HS(i) [100,205,309,407]-100=[0,105,209,307]
% add midswing
out_data= struct('line',M_S,'event',double.empty(0,3));
cycle(1,var_num) = table(out_data);
cycle.Properties.VariableNames{var_num}= 'MS';
var_num=var_num+1;
% add toe-off
out_data= struct('line',T_O,'event',double.empty(0,3));
cycle(1,var_num) = table(out_data);
cycle.Properties.VariableNames{var_num}= 'TO';
var_num=var_num+1;
% add heel strike
out_data= struct('line',H_S,'event',double.empty(0,3));
cycle(1,var_num) = table(out_data);
cycle.Properties.VariableNames{var_num}= 'HS';
var_num=var_num+1;


function data_new = gait_partition_by_cycle(data, start_row, end_row)

data_new = data;
chns = setdiff(fieldames(data_new), 'zoosystem');
for i = 1:length(chns)
    r = data_new.(chns{i}).line;  
    r_cycle = r(start_row:end_row);
    data_new.(chns{i}).line = r_cycle;
end


function [cycle,var_num] = gait_extract_by_cycle(data,start_row,end_row,var_num)
% extracts data for n_cycles of acceleration, gyroscope, and magnotometer
% for sensor s_pos

sensor_pos={'trunk','thighR','shankR','thighL','shankL'};
% extract each gyro,acc,mag for single cycle for all sensor position
for i=1:length(sensor_pos)
    s_pos=sensor_pos(i);
    g_x= s_pos+"_Gyr_X";
    g_y= s_pos+"_Gyr_Y";
    g_z= s_pos+"_Gyr_Z";
    a_x= s_pos+"_Acc_X";
    a_y= s_pos+"_Acc_Y";
    a_z= s_pos+"_Acc_Z";
    m_x= s_pos+"_Mag_X";
    m_y= s_pos+"_Mag_Y";
    m_z= s_pos+"_Mag_Z";
    
    pos={g_x,g_y,g_z,a_x,a_y,a_z,m_x,m_y,m_z};
    % extract each gyro,acc,mag for single cycle according to sensor position
    for j=1:length(pos)
        var=pos(j);
        var=var{1,1};
        out_data= struct('line',data.(pos(j)).line(start_row:end_row),'event',double.empty(0,3));
        cycle(1,var_num) = table(out_data);
        cycle.Properties.VariableNames{var_num}= (var);
        var_num=var_num+1;
    end
    
end
% extract joint angles
j_angle={'hipR_flex','hipL_flex','kneeR_flex','kneeL_flex'};
for j=1:length(j_angle)
    var=j_angle(j);
    var=var{1,1};
    out_data= struct('line',data.(j_angle(j)).line(start_row:end_row),'event',double.empty(0,3));
    cycle(1,var_num) = table(out_data);
    cycle.Properties.VariableNames{var_num}= (var);
    var_num=var_num+1;
end




