%% joint angle computation
fld=uigetfolder;
segment_pairs = { {'trunk', 'thighR'}, {'thighR', 'shankR'},{'trunk', 'thighL'},{'thighL', 'shankL'}};
parameters.SampleRate=100;
parameters.AccelerometerGain=0.01;
parameters.MagnetometerGain=0.01;
parameters.HasMagnetometer=true;
parameters.OrientationFormat="quaternion";
bmech_imu_joint_angle(fld,parameters,segment_pairs)
%   SampleRate           - Input sample rate of sensor data (Hz)
%   AccelerometerGain    - Gain of accelerometer versus gyroscope
%   MagnetometerGain     - Gain of magnetometer versus gyroscope
%   HasMagnetometer      - Enable magnetometer input
%   OrientationFormat    - Output format specified as "quaternion" or
%                          "Rotation matrix"
%% comparing IMU vs Mocap data
path='C:\PhD new\Final_data\Test_Data_for_menu\Test_data\test_data.zoo';
data=zload(path);
compare_imu_vs_mocap(data)
%% Heel strike detection ----------------------------------------------------------------------------------------
peak_lim=0.7;
bmech_imu_heelstrike_detect(fld, peak_lim)
%% gait cycle sepration
n_cycles=1;
bmech_imu_gait_cycle_sepration(fld,n_cycles)
