function zsave(fl,data,info)

% ZSAVE(fl,data) saves zoo files to disk. The processing step 
% information (name of calling function) is also saved to the 
% zoosystem 'processing' branch
%
% ARGUMENTS
% fl      ...  full path to file
% data    ...  zoo data
% info    ...  further information about process (optional)
%
% e.g.1 If the function bmech_partition is run, then calling zsave(fl,data)
% will add 'bmech_partition' to the branch 'data.zoosystem.processing'
%
% e.g.2 If the function bmech_removechannel is called to remove the
% channels ch = {'RKneeAngle_x','LAnkleAngle_y'} then calling
% zsave(fl,data,ch) will add 'bmech_removechannel 'RKneeAngle_x','LAnkleAngle_y'
% to the branch 'data.zoosystem.processing'


% Revision History
%
% Created by Philippe C. Dixon Sept 15th 2015


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Dr. Philippe C. Dixon, Harvard University. Boston, USA.
% Yannick Michaud-Paquette, McGill University. Montreal, Canada.
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
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 





% determine which function called zsave
%
ST = dbstack(1);
process = ST.name;


% Add additional processing info
%
if nargin==3
    process = [process,' ',info];
end



% write processing step to zoosystem
%
if ~isfield(data.zoosystem,'processing')
    data.zoosystem.processing = {process};
else
    r = data.zoosystem.processing;
    r{end+1,1} = process;
    data.zoosystem.processing = r;
end    
    

% traditional save
%
save(fl,'data');








