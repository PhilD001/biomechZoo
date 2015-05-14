function zoosystem

% Updated August 2009
% - ensembler has been vastly improved
% - figs2subplot is a great new tool
%
% © Part of the Biomechanics Toolbox, Copyright ©2008, 
% Phil Dixon, Montreal, Qc, CANADA


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
% 
% Contact: 
% philippe.dixon@gmail.com
%
% Web: 
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis 
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in 
% Aduts and Children. Rome, Italy.Sept 29-Oct 4th 2014. 



disp('=======================================================')
disp('           ZOOSYSTEM BIOMECH TOOLBOX SUMMARY')
disp('=======================================================')
disp(' ')
disp('The following is a summary of the Biomech Toolbox functions for analysis of biomechanical data')
disp(' ')
disp(' (1) Basic Ops: A list of useful functions for data analysis');
disp(' (2) Linear Algebra Ops: A list of useful Linear Algebra functions');
disp(' (3) Biomech Ops: A list of useful functions specific to biomechanics');
disp(' (4) Plugingait Ops: A list of ops that can be run on plug-in gait vicon data');
disp(' (5) Data Acquisition:: A list of useful functions for analog data acquisition');
disp(' (6) Zoo Conversions: Converting third party file types to zoo');
disp(' (7) Zoo Processing: Standard biomech processing tools');
disp(' (8) Visualisation: Viewing/graphing data');
disp(' (9) Statistics: Conduct descritive and advanced statistics');
disp(' (0) to quit Biomech Toolbox summary');
disp(' ')
selection = num2str(input('please make a selection for further instructions '));


while selection ~= 0

switch selection
    
     case '1'
        
         disp(' ')
         disp ('Basic Ops: The following is a list of existing basic functions')
         disp(' ')
         disp('delfiles: deletes files in a given folder by file type')
         disp('filename: returns only the file name from the output of engine')
         disp('findindx: converts an indx in sampling rate fsamp1 to an indx in sampling rate fsamp2')
         disp('g: returns value of acceleration due to gravity in Montreal')
         disp('grab: quickly load zoo files ')
         disp('iseven: determines if a number is even or odd')
         disp('kg2newtons: converts mass from kilograms to newtons(N)')
         disp('lbs2newtons: converts mass from pounds (lbs) to newtons (N)')
         disp('movefiles: moves files from directory a to directory b')
         disp('nanintep: interpolates over NaNs')
         disp('normalization: normalizes a column vector to specified length')
         disp('percent2deg: transforms slope inclinations from percent to degrees')
         disp('setpath: useful function to quickly set path')
         disp('subdir: returns all subdirectories in a given directory')
         disp(' ')
         disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
         disp(' ')
         selection  = num2str(input('to make another selection type appropriate number '));
       
         
    case '2'

        disp(' ')
        disp ('Linear Algebra Ops: The following is a list of existing vector and matrix related functions')
        disp(' ')
        disp('angle: determines the angle between 2 vectors')
        disp('deg2rad: converts angle measurements from degrees to radians')
        disp('grood_suntay: calculates the angle between two rigid segments using Grood and Suntay method')
        disp('magnitude: returns the magnitude of a vector')
        disp('make_local_coord: creates local coordinate system based on three 3D points')
        disp('plane_plane_angle: determines the angle between two planes')
        disp('rad2deg: converts angle measurement from radians to degrees')
        disp('segment_rotation: determines the yaw, pitch and roll of a segment')
        disp(' ')
        disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
        disp(' ')
        selection  = num2str(input('to make another selection type appropriate number '));


    case '3'

        disp(' ')
        disp ('Biomech Ops: The following is a list of standard biomechanics related functions')
        disp(' ')
        disp('bmech_area: calculates area under a curve based on trapazoidal integration')
        disp('bmech_datazero: removes DC offset from data')
        disp('bmech_deriv: performs derivation on data')
        disp('bmech_fft: runs fourier analysis on data')
        disp('bmech_filter: runs a number of possible filters')
        disp('bmech_integral: performs integration of data')
        disp('bmech_kinematics: outputs diplacement, velocity, and acceleration of each frame of a trial')
        disp('bmech_normalize: normalizes data to a given length (for graphing)')
        disp('bmech_peakdet: finds the peaks in a data vector')
        disp('bmech_rectify: rectify data')
        disp('bmech_reversepol: reverses polarity of data')
        disp('bmech_resample: resamples data using a polyphase implementation')
        disp('bmech_rms: computes the root mean square of your data') 
        disp('bmech_velocity: computes velocity of a given marker')
        disp('bmech_xcorrAlign: Aligns two signals based on cross-correlation')
        disp(' ')
        disp('Please note: All Zoo Conversion functions are batch processing functions  ')
        disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
        disp(' ')
        selection  = num2str(input('to make another selection type appropriate number '));

    case '4'

        disp(' ')
        disp ('Plugingait Ops: The following is a list of ops that can be run on plug-in gait vicon data')
        disp(' ')
        disp('plugingait2groodsuntay: kinematic analysis of lower-limbs')
        disp('plugingait2ida: kinetic analysis of lower-limbs')
        disp('plugingait2jointcenters: computes lower-limb joint centers')
        disp('plugingait2leglength: computes leg length')
        disp('plugingait2qangle: computes Q-angle')
        disp('plugingait2strideprop: computes various stride properties')
        disp('plugingait2xfactor: computes X-Factor between shoulder and pelvis')
        disp(' ')
        disp('Please note: All Zoo Conversion functions are batch processing functions  ')
        disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
        disp(' ')
        selection  = num2str(input('to make another selection type appropriate number '));
       
        
    case '5'

        disp(' ')
        disp ('Data Acquisition: The following is a list of existing data acquisition routines')
        disp(' ')
        disp('AnalogAcquireAMTI: Simulink file to acquire data from NI DAQ card for AMTI plate')
        disp('AnalogAcquireAMTIvicon: Simulink file to acquire synchronized data from NI DAQ card and Nexus using AMTI plate')
        disp('AnalogAcquireAMTIvicon2zoo: Exports data collected by AnalogAcquireAMTIvicon to zoo format')
        disp('AnalogAcquireBertec: Simulink file to acquire data from NI DAQ card for BERTEC')
        disp('AnalogAcquirevicon2zoo: Exports data collected by AnalogAcquireAMTIvicon containing trigger data')
        disp('AnalogAcquire2zoo: Exports data collected by AnalogAcquireAMTI')
        disp(' ')
        disp('Please note: Data Acquisiton functions require the use of suitable DAQ cards connected to your computer')
        disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
        disp(' ')
        selection  = num2str(input('to make another selection type appropriate number '));
          
    case '6'
        
        disp(' ')
        disp ('Zoo Conversions: The following is a list of existing zoo converters')
        disp(' ')
        disp('analog2zoo: converts analog data stored in the workspace to zoo format')
        disp('c3d2zoo: converts c3d files to zoo format')
        disp('delim2zoo: converts any tab delimited file to zoo format')
        disp('emg2zoo: converts emg files to zoo format')
        disp('log2zoo: converts log files to zoo format')
        disp('rjf2zoo: converts rjf files to zoo format')
        disp('tsv2zoo: converts tsv files to zoo format')
        disp('txt2zoo: converts txt files to zoo format')
       
        disp(' ')
        disp('Please note: All Zoo Conversion functions are batch processing functions')
        disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
        disp(' ')
        selection  = num2str(input('to make another selection type appropriate number '));
     
        
    case '7' 
        
        disp(' ')
        disp('Zoo Processing: The following is a list of existing processing tools')
        disp(' ')
        disp('bmech_addchannel: adds computed data into a new channel')
        disp('bmech_addevent: adds an event to zoo file')
        disp('bmech_align: Aligns data based on events')
        disp('bmech_AMTIvolt2newton: converts voltage signal from AMTI forceplate to Newtons')
        disp('bmech_combinezoofiles: combines data collected by 2 systems into a single zoo file ')
        disp('bmech_explode: expands zoo channels containing 3D data into separate channels')
        disp('bmech_extrapolate: extrapolate data')
        disp('bmech_partition: cut data to remove unwanted indices ')
        disp('bmech_removechannel: removes a channel from zoo file')
        disp('bmech_removeevent: removes unwanted events from data')
        disp('bmech_removeoutlier: deletes files listed in cell array "out"')
        disp('bmech_removeNAN: removes NaN values from data')
        disp('bmech_renamechannel: renames channels')      
        disp('bmech_renameevent: renames events')  
        disp('bmech_retag: reassigns an event to modified line data')  
        disp(' ')
        disp('Please note: All Zoo Processing functions are batch processing functions  ')
        disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
        disp(' ')
        selection  = num2str(input('to make another selection type appropriate number '));
           
        
    case '8'
        disp(' ')
        disp('Visualization: The following is a list of existing graphing tools')
        disp(' ')
        disp('barweb: create bar graphs')
        disp('director: 3D animation suite, part of JJ library (no longer supported)')
        disp('ensembler: graphing suite to display average curves for all data , also adds events')
        disp('erase: erases standard deviation lines in figures')
        disp('figs2subplot: places a large number of open figures into a subplot')
        disp('forceplaterotate: to be used with director')
        disp('greyscale: turn color graph into greyscale')
        disp('hline: places a horizontal line in figures')
        disp('structplot: plots any number of given channels in a structed array')
        disp('vline: place a vertical line in figures')
        disp('zplot: easily display a single channel of a zoo file, including events')
        disp(' ')
        disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
        disp(' ')
        selection  = num2str(input('to make another selection type appropriate number '));

                
    case '9'
        
        disp(' ')
        disp('Statistics: The following is a list of statistical analysis tools ')
        disp(' ')
        disp('eventval: returns the values stored in events to an xls file')
        disp('eventval2descstats: returs average event data sorted by subject and condition')
        disp('eventval2spss: exports data to be processed in SPSS')
        disp(' ')
        
        selection  = num2str(input('to make another selection type appropriate number ')); 
        
   
        
    case '0'
        disp(' ')
        disp('Thank you for using the Biomech Toolbox')
        disp(' ')
        disp('© Part of the Biomechanics Toolbox, Copyright ©2008-2010') 
        disp('Phil Dixon, Montreal, Qc, CANADA')
        
        return

        
        
end

end








