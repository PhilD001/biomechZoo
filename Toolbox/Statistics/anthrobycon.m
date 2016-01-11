function r = anthrobycon(fld,name,display)

% r = anthrobycon(fld,name,display) returns anthropometric data by condition
%
% ARGUMENTS
%  fld      ... path to data 
%  name     ... group name 
%  display  ... output info to command window. 'on' or 'off'. Default 'on'
%
% RETURNS
%  r       ...  struct containing anthro data


% Revision History
%
% Created by Philippe C. Dixon January 19th 2014
% - Simple implementation based on previous versions
%
% Updated by Philippe C. Dixon January 29th 2014
% -also works when there is more than one trial per subject/condition
%
% Updated by Philippe C. Dixon March 31st 2015
% - generalized subfunctions
% - fixed bug when missing anthro info


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon (D.Phil.), Harvard University. Cambridge, USA.
% Yannick Michaud-Paquette (M.Sc.), McGill University. Montreal, Canada.
% JJ Loh (M.Sc.), Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com or pdixon@hsph.harvard.edu
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the conference abstract below if the zoosystem was used in the 
% preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement 
% Analysis Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of 
% Movement Analysis in Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.


% Set defauls
%
if nargin==2
    display = 'on';
end


% Extract files
%
fl = engine('path',fld,'folder',name);




% Set anthro variables
%
n          = length(fl);
subnames   = cell(n,1);
age        = NaN*zeros(n,1);
height     = NaN*zeros(n,1);
leg_length = NaN*zeros(n,1);
mass       = NaN*zeros(n,1);
sex        = cell(n,1);
Male = 0;
Female =0;

% Extract subject names
%
for i = 1:length(fl)
    data = zload(fl{i});
    subnames{i} = strrep(data.zoosystem.Header.SubName,' ','');
end


% Extract and group anthro data
%
for j = 1:length(subnames)
    
    count = 0;
    
    for i =1:length(fl)
        
        if isin(fl{i},subnames{j}) && count==0 % only check once per subject
            
            data = zload(fl{i});
            
            disp(['collecting anthro info for subject ', subnames{j}])
            
            if isfield(data.zoosystem.Anthro,'Age')
                age(j) = data.zoosystem.Anthro.Age;
            end
            
            if isfield(data.zoosystem.Anthro,'Height')
                height(j) = data.zoosystem.Anthro.Height/1000;
            end
            
            if isfield(data.zoosystem.Anthro,'Bodymass')
                mass(j) = data.zoosystem.Anthro.Bodymass;
            end
            
            if isfield(data.zoosystem.Anthro,'LLegLength')
                leg_length(j)= mean([data.zoosystem.Anthro.LLegLength data.zoosystem.Anthro.RLegLength]);
            end
            
            if isfield(data.zoosystem.Anthro,'Sex')
               sex{j} = data.zoosystem.Anthro.Sex;
            end
            
            if isin(sex{j},'M')
                Male = Male+1;
            elseif isin(sex{j},'F')
                Female = Female+1;
            else
                continue
            end
            
            count = 1;
            
        end
    end
    
end



% add to struct for export
r.samplesize = n;
r.numgirls = Female;
r.numboys = Male;

r.Age.mean = mean(age);
r.Age.max = max(age);
r.Age.min = min(age);

r.Height.mean = mean(height);
r.Height.max = max(height);
r.Height.min = min(height);

r.LLength.mean = mean(leg_length);
r.LLength.max = max(leg_length);
r.LLength.min = min(leg_length);

r.Mass.mean = mean(mass);
r.Mass.max = max(mass);
r.Mass.min = min(mass);


[a_lo, a_hi] =  bmech_CI(age);
[h_lo, h_hi] =  bmech_CI(height);
[l_lo, l_hi] =  bmech_CI(leg_length);
[m_lo, m_hi] =  bmech_CI(mass);


% display results

if isin(display,'on')
    
    disp('-------------------------------------------')
    disp(['Group Statistics for group: ' name])
    disp(' ')
    disp(['number of subjects n= ',num2str(n)])
    disp(['number of girls = ',num2str(Female),' number of boys = ',num2str(Male)])
    disp(['mean age = ',num2str(mean(age)),' (', num2str(std(age)),')',' [',num2str(a_lo),',',num2str(a_hi), ']' ])
    disp(['mean height = ',num2str(mean(height)),' (', num2str(std(height)),')',' [',num2str(h_lo),',',num2str(h_hi), ']'])
    disp(['mean leg length = ',num2str(mean(leg_length)),' (', num2str(std(leg_length)),')',' [',num2str(l_lo),',',num2str(l_hi), ']'])
    disp(['mean mass = ',num2str(mean(mass)),' (', num2str(std(mass)),')',' [',num2str(m_lo),',',num2str(m_hi), ']'])
    disp(' ')
    
end




