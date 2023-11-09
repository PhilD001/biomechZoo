function Q_outdoor= quaternion_line_v2(data,s_pos,parameters)
% computes quaternion based on acceleration, gyroscope, and magnotometer
% for sensor s_pos


%FUSE = ahrsfilter();
if parameters.HasMagnetometer==true
    g_x= s_pos+"_Gyr_X";
    g_y= s_pos+"_Gyr_Y";
    g_z= s_pos+"_Gyr_Z";
    a_x= s_pos+"_Acc_X";
    a_y= s_pos+"_Acc_Y";
    a_z= s_pos+"_Acc_Z";
    m_x= s_pos+"_Mag_X";
    m_y= s_pos+"_Mag_Y";
    m_z= s_pos+"_Mag_Z";
    G=[data.(g_x).line, data.(g_y).line, data.(g_z).line];
    A=[data.(a_x).line, data.(a_y).line, data.(a_z).line];
    M=[data.(m_x).line, data.(m_y).line, data.(m_z).line];
FUSE = complementaryFilter("SampleRate",parameters.SampleRate,"AccelerometerGain",parameters.AccelerometerGain,"MagnetometerGain",parameters.MagnetometerGain,"HasMagnetometer",parameters.HasMagnetometer,"OrientationFormat",parameters.OrientationFormat);
    
    [Q_outdoor,~] = FUSE(A,G,M);
else
    g_x= s_pos+"_Gyr_X";
    g_y= s_pos+"_Gyr_Y";
    g_z= s_pos+"_Gyr_Z";
    a_x= s_pos+"_Acc_X";
    a_y= s_pos+"_Acc_Y";
    a_z= s_pos+"_Acc_Z";
    G=[data.(g_x).line, data.(g_y).line, data.(g_z).line];
    A=[data.(a_x).line, data.(a_y).line, data.(a_z).line];
    FUSE = complementaryFilter("SampleRate",parameters.SampleRate,"AccelerometerGain",parameters.AccelerometerGain,"HasMagnetometer",parameters.HasMagnetometer,"OrientationFormat",parameters.OrientationFormat);

    [Q_outdoor,~] = FUSE(A,G);
end