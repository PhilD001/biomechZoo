function [mdiffdatastk,maxvalstk,mult,cons,SigDiffIndxStk,frames,compconsstk] = computecolorbars(r,cons,ch,fl,nboots,alpha,check,mode)

% made as stanalone function July 29th 2013
%
% Updated November 18th 2013
% - function can handle any number of comparisons
% - stratified bootstrap is used unless number of lines are equal and
%   condition names start with the same 2 letters.


%-get data info and initialize variables
%
disp(['computing color bars for: ',ch])
[frames,indx] = getframesforcontinuous(fl,ch);
compconsstk = {};                      % make more than needed than remove extra
calphastk = [] ;
maxvalstk = []; % ones(3*length(cons),1);
mdiffdatastk = []; %ones(3*length(cons),length(frames));
SigDiffIndxStk = []; %ones(3*length(cons),length(frames));


if nargin==7
    mode = 'yes disp';
end

%-compute variables for all condition pairs
%


for i=1:length(cons)-1
    
    
    for j = 1:length(cons)-i
        
        u = struct;
        
        con1 = cons{i};
        con2 = cons{i+j};
        
        aindx1 = strfind(con1,'_and_');
        aindx2 = strfind(con2,'_and_');
        
        c11 = con1(1:aindx1-1);
        c12 = con1(aindx1+5:end);
        
        c21 = con2(1:aindx2-1);
        c22 = con2(aindx2+5:end);
        
        if strcmp(c11,c21) %|| strcmp(c12,c22) % maybe a worthy comparison
            
            if  r.(ch).(con1).nlines == r.(ch).(con2).nlines
                diffdata =  r.(ch).(con1).lines - r.(ch).(con2).lines;
            else
                u.(con1).line = r.(ch).(con1).lines;
                u.(con2).line = r.(ch).(con2).lines;
            end
            
            compcons = [cons{i},' vs ',cons{i+j}];
            compconsstk =[compconsstk; compcons  ];
            
            
            if isin(ch,'OFM') && isempty(u)
                diffdata = diffdata(:,indx:end);
            end
            
            
            if isempty(fieldnames(u))
                
                if isin(mode,'yes')
                    disp('Equal number of subjects detected between same group conditions ... implementing regular bootstrap-t');
                end
                
                
                if ~isempty(check)
                    [calpha_b, CIlow_b, CIhigh_b,~,~,~,~,muhat] = bootstrap_t(diffdata,nboots,alpha,[ch,' ',compcons]);   % bootstrap algorithm
                else
                    [calpha_b, CIlow_b, CIhigh_b,~,~,~,~,muhat] = bootstrap_t(diffdata,nboots,alpha);   % bootstrap algorithm
                end
                
            else
                
                if isin(mode,'yes')
                    disp('Unequal number of subjects detected between conditions ...implementing stratified bootstrap design');
                end
                
                if ~isempty(check)
                    [calpha_b, CIlow_b, CIhigh_b,~,~,~,~,muhat] = bootstrap_t(u,nboots,alpha,[ch,' ',compcons]);   % bootstrap algorithm
                else
                    [calpha_b, CIlow_b, CIhigh_b,~,~,~,~,muhat] = bootstrap_t(u,nboots,alpha);   % bootstrap algorithm
                end
                
            end
            
            mdiffdatastk =[mdiffdatastk; muhat];     % this is not a bootstrap estimate
            calphastk = [calphastk; calpha_b];
            
            SigDiffIndx = ones(1,length(frames));
            
            for k  =1:length(CIlow_b)
                
                if ~isnan(CIlow_b(k))
                    
                    if CIlow_b(k)>0 || CIhigh_b(k)<0
                        SigDiffIndx(k) = k;
                    else
                        SigDiffIndx(k) = NaN;
                    end
                else
                    SigDiffIndx(k) = NaN;
                end
                
            end
            
            SigDiffIndxStk = [SigDiffIndxStk; SigDiffIndx];
            
            %----match data to color----
            yd = abs(muhat);
            
            if max(yd) < 1
                mult = 100;
            elseif max(yd) < 2
                mult = 10;
            else
                mult = 1;
            end
            
            yd_round = ceil(yd*mult); % ceil must be used since any 0 value would not work
            yd_round(isnan(SigDiffIndx))=2;
            
            maxval = max(yd_round)./mult;
            maxvalstk = [maxvalstk; maxval];
            
        end
    end
end




% compute average vals and maxvals
%
maxvalstk = max(maxvalstk);
mcalpha = mean(calphastk);
disp(['mean calpha value for all channels and conditions is ',num2str(mcalpha)])
disp(['maxdiff is ',num2str(maxvalstk)])


