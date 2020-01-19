fld = '/Users/jennymaisonneuve/Code/biomechZoo-help/sample study/Data/7-normalize';
excelserver = 'off';     % 28.9533, 23.6 seconds  9.5808                                  % switch to 'off' 
                                   % switch to 'off' 

ext = '.xlsx';                                                              % if java error

levts = {'max'};                                                            % local evts
gevts = {'RFS', 'RFO'};                                                     % global evts
aevts = {'Bodymass', 'Height', 'InterAsisDistance'};
ch    = {'RightGroundReactionForce_x','RightHipAngle_y',...                 % channels 
         'RightKneeMoment_x','RightAnklePower'};                            % to export
dim1  = {'Straight','Turn'};                                                % conditions
dim2  = {'HC002D','HC030A','HC031A','HC032A','HC033A','HC036A',...          % subjects
         'HC038A','HC039A','HC040A','HC044A','HC050A','HC055A'};
    
eventval('fld',fld,'dim1',dim1,'dim2',dim2,'localevts',levts,...
     'globalevts',gevts,'anthroevts', aevts,'ch',ch,'excelserver',excelserver,...
     'ext',ext)