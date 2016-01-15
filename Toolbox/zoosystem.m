function zoosystem

% ZOOSYSTEM gives a quick summary of the functions included in the
% latest version of the zoosystem

disp('==============================================================================================')
disp('                             ZOOSYSTEM BIOMECHANICAL TOOLBOX SUMMARY')
disp('=============================================================================================')
disp(' ')
disp('The following is a summary of the Zoosystem Toolbox functions for analysis of biomechanical data')
disp(' ')
disp(' (1) Biomech Ops: Functions to conduct basic biomechanical analysis');
disp(' (2) Gait: Functions for walking research, including display of normative gait curves in Ensembler');
disp(' (3) Mac: Functions to implement general fixes for MAC OS');
disp(' (4) Statistics: Functions to run statistics within Matlab and export event data to statistical software');
disp(' (5) Support Functions: Function in support of main zoosystem suites');
disp(' (6) Visualization: Functions mainly controlling GUIs (Director and Ensembler)');
disp(' (7) Zoo Conversions: Functions to convert data to zoosystem format (.zoo)');
disp(' (8) Zoo Processing: Functions to perform processing of zoo files');
disp(' (9) to output citation information for the Zoosystem Toolbox');
disp(' (10) to quit Zoosystem Toolbox summary');

disp(' ')
selection = num2str(input('please make a selection for further instructions '));


while selection ~= 0
    
    switch selection
        
        case '1'
            disp(' ')
            disp ('(1) Biomech Ops: Functions to conduct basic biomechanical analysis')
            disp(' ')
            disp('bmech_deriv: Performs differentiation on data')
            disp('bmech_fft: Runs fourier analysis on data')
            disp('bmech_filter: Runs a number of possible filters')
            disp('bmech_normalize: Normalizes data to a given length (for graphing)')
            disp('bmech_reversepol: Reverses polarity of data')
            disp('bmech_velocity: Computes velocity of a given marker')
            disp(' ')
            disp('For additional information regarding a specific function, type "help functionname" in the command prompt')
            disp(' ')
            selection  = num2str(input('to make another selection type appropriate number '));
            
        case '2'
            disp(' ')
            disp('(2) Gait: Functions for walking research, including display of normative gait curves in Ensembler');
            disp(' ')
            disp('bmech_leglength: Computes average leg-length from Anthro branch (does not compute from markers)')
            disp('SpatialParameters: Computes stride length, step length, and stride width based on gait events')
            disp('TemporalParameters: Computes step time and stride time based on gait events')
            disp('Walking norm data: Folder containing normative gait data')
            disp('ZeniEventDetect: Computes gait events using the method proposed by Zeni et al. 2008 )')
            disp(' ')
            disp('For additional information regarding a specific function, type "help functionname" in the command prompt')
            disp(' ')
            selection  = num2str(input('to make another selection type appropriate number '));
            
        case '3'
            disp(' ')
            disp('(3) Mac: Functions to implement general fixes for MAC OS');
            disp(' ')
            disp('FixFigMac: Fixes problems with an Ensembler figure created in Windows and opened on OSX ')
            disp('rmdir: Implements remove diretory command based on unix command')
            disp('uigetfolder: Replaces standard uigetfolder command')
            disp(' ')
            disp('For additional information regarding a specific function, type "help functionname" in the command prompt')
            disp(' ')
            selection  = num2str(input('to make another selection type appropriate number '));
            
        case '4'
            disp(' ')
            disp('(4) Statistics: Functions to run statistics within Matlab and export event data to statistical software');
            disp('anthrobycon: Returns anthropometric data by conditon (useful for summary tables in publications)')
            disp('bmech_CI: Computes parametric/non-parametric confidence intervals')
            disp('bmech_reptrial: Chooses representative trial from a set of trials based on RMSE')
            disp('bootsrap_t: Perform Bootstrap analysis (used by Ensembler)')
            disp('eventval: Outputs data to excel for general analysis')
            disp('eventval2mixedANOVAspss: Outputs data to excel for repeated measures statistical analysis in SPSS.')
            disp('extract_filestruct: Returns file structure of dataset ')
            disp('extractevents: Extracts events into structured array for Matlab based analyses')
            disp('Levenetest: Performs Levenes test for homogeneity of variance')
            disp('omni_ttest: Performs parametric/non-paramtric tests for within/betwen subject data')
            disp('rmse: Computes the root mean squared error between two signals')
            disp(' ')
            disp('For additional information regarding a specific function, type "help functionname" in the command prompt')
            disp(' ')
            selection  = num2str(input('to make another selection type appropriate number '));
            
        case '5'
            disp(' ')
            disp('(5) Support Functions: Function in support of main zoosystem suites');
            disp(' ')
            disp('For additional information regarding a specific function, type "help functionname" in the command prompt')
            disp(' ')
            selection  = num2str(input('to make another selection type appropriate number '));
            
        case '6'
            disp(' ')
            disp('(6) Visualization: Functions mainly controlling GUIs (Director and Ensembler)');
            disp(' ')
            disp('bmech_footwear: Used to add footwear (e.g. skates) to 3D skeleton model in Ensembler')
            disp('director: 3D animation suite')
            disp('ensembler: Graphing suite to display average curves for all data , also adds events')
            disp('figs2subplot: places a large number of open figures into a subplot')
            disp('mybar: Creates bar graph for Ensembler suite')
            disp('zplot: easily display a single channel of a zoo file, including events')
            disp(' ')
            disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
            disp(' ')
            selection  = num2str(input('to make another selection type appropriate number '));
            
        case '7'
            disp(' ')
            disp('(7) Zoo Conversions: Functions to convert data to zoosystem format (.zoo)');
            disp(' ')
            disp('c3d2zoo: Converts c3d files to zoo format')
            disp(' ')
            disp('Please note: All Zoo Conversion functions are batch processing functions')
            disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
            disp(' ')
            selection  = num2str(input('to make another selection type appropriate number '));
            
        case '8'
            disp(' ')
            disp('(8) Zoo Processing: Functions to perform processing of zoo files');
            disp(' ')
            disp('bmech_addevent: Adds an event to zoo file')
            disp('bmech_combinezoofiles: Combines data collected by 2 systems into a single zoo file ')
            disp('bmech_explode: Expands zoo channels containing 3D data into separate channels')
            disp('bmech_NaNpartition: Cuts data to remove unwanted NaN indices ')
            disp('bmech_partition: Cuts data to remove unwanted indices based on start and end events')
            disp('bmech_removechannel: Removes a channel from zoo file')
            disp('bmech_removeevent: Removes unwanted events from data')
            disp('bmech_renamechannel: Renames channels')
            disp('bmech_renameevent: Renames events')
            disp(' ')
            disp('Please note: All Zoo Processing functions are batch processing functions  ')
            disp('for additional information regarding a specific function, type "help functionname" in the command prompt')
            disp(' ')
            selection  = num2str(input('to make another selection type appropriate number '));
            
        case '9'
            citation
            disp(' ')
            selection  = num2str(input('to make another selection type appropriate number '));
            
        case '10'
            disp(' ')
            disp('Thank you for using the Zoosystem Toolbox')
            disp(' ')
            disp('please reference the paper below if the zoosystem was used in the preparation of a manuscript:')
            disp(' ')
            disp('Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. ')
            disp('The Zoosystem: An Open-Source Movement Analysis Matlab Toolbox.')
            disp('Proceedings of the 23rd meeting of the European Society of Movement Analysis in Adults and Children.')
            disp('Rome, Italy.Sept 29-Oct 4th 2014.')
            
            return
            
        otherwise
            disp(' ')
            disp('invalid entry')
            disp(' ')
            selection  = num2str(input('to make another selection type appropriate number '));
            
            
    end
    
end








