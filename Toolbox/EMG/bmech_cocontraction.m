function bmech_cocontraction(fld,pairs,varargin)

% BMECH_COCONTRACTION computes co-contraction index for muscle pairs
%
% ARGUMENTS
%  fld       ...  str, folder to operate on
%
%  pairs     ...  cell array of str, names of muscle pairs.
%                 Example = {'L_TibAnt-L_GM','L_RF-L_Ham'} computes co-contaction 
%                 for L_TibAnt and L_GM & L_RF and L_Ham muscle pairs.
%
% 'method'  ...   str, optional. Choice of algorithm to use. 
%                 Default :'Rudolph'. Other choices :'Falconer' and 'Lo2017'.
%                 See - Rudolph et al. 2000. Dynamic stability after ACL injury: who can hop?
%                       Knee Surg Sports Traumatol Arthrosc 8, 262-269 (commented)
%                     - Falconer, K., Winter, D., 1985. Quantitative assessment of co-contraction at the
%                       ankle joint in walking. Electromyogr. Clin. Neurophysiol. 25, 135149.
%                     - Lo J, Lo O-Y, Olson E-A et al. Functional implications of muscle co-contraction 
%                       during gait in advanced age. Gait & Posture,Volume 53,2017,p 110-114.
%
% 'events'   ...  cell arrat of str. Optional, Pair of global events (only for Lo2017 method). 
%                 Estimates  percent co-contraction btw the events (value stored in event). 
%                 Note: Ignores events for other methods and computes co-contation line for entire data
%                 Example = {'Left_FootStrike1','Left_FootStrike2'}
%
%
% See also cocontraction_data, cocontraction_line

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

method_exists = false;
events_exists = false;
evts ={''};

if nargin <2
    error('Check Input')
elseif nargin ==3
    error('Check Input')
elseif nargin>3
    for i = 1:2:nargin-2    
        
        switch varargin{i}
            
            case 'method'
                method = varargin{i+1};
                method_exists = true;
                
            case 'events'
                evts = varargin{i+1};
                events_exists =true;
                
        end
    end
end


for i = 1:length(fl)
    data = zload(fl{i});
    
    batchdisp(fl{i},['computing co-contraction using method ', method]);
    
    if method_exists&&events_exists
        data = cocontraction_data(data,pairs,method,evts);
    elseif method_exists
        data = cocontraction_data(data,pairs,method);
    elseif events_exists
        data = cocontraction_data(data,pairs,evts);
    else
        data = cocontraction_data(data,pairs);
    end
    
    zsave(fl{i},data);
end