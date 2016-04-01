function [N,time] = normalfu(A,n,before,after,nanum)
% function [N, time] = normalfu(A,n,before,after,nanum)
% Description:  normalizes to n-data points using "linear interpolation"
% Input:    A        = matrix to be normalized
%           n        = normalized to n points (default = 101; 0% to 100%)
%           before   = # of data points before the phase determining 
%                      determining the 'normalization phase'
%           after    = --"--, but after
%           nanum    =    1 -> will leave NaNs'
%                      else -> will interpolate for missing values (NaNs')
%                      (default)
%                      Note: NaNs' at the beginninng or end of column
%                            are not replaced
% Output:   N        = matrix with normalized data
%           time     = time ("xaxis"), starts at zero (if before =0)
%                      e.g. if n=101 -> time = [0:100]
% Remarks:      This function may be used just in the form normalfu(A). In that
%	        case, n=101, before=0; after=0; nanum=0;
%               The code for this function is far from being optimal and
%		therefore this function is rather slow.
% Author:       Christoph Reinschmidt, HPL, The University of Calgary
% Date:	        September, 1994
% Last Changes: November 29, 1996
% Version:	1.0

if (nargin==1),  n=101; nanum=0 ; before =0 ; after =0; end
if (nargin==2),  nanum=0 ; before =0 ; after =0; end
if (nargin==3),  nanum =0 ; after =0; end
if (nargin==4),  nanum=0; end

[m,q]=size(A);

% linear interpolation for missing values (NaNs')
if nanum~=1
 for k=1:q   % q number of columns
  %find first and last not NaNs' entries in each columns  
    first=min(find(~isnan(A(:,k))));
    last=max(find(~isnan(A(:,k))));
  for j=[first+1]:[last-1]   % from first to last column entry not being NaN
    if isnan(A(j,k))
       low=j-1;
       high=find(~isnan(A(:,k)));    
       highindex=min(find(high>j));
       high=high(highindex,1);
       H1=[low,1;high,1] ; H2=[A(low,k);A(high,k)];
       c=H1\H2;
       A(j,k)=[c(1,1)*j+c(2,1)];
    end
  end % rows
 end % columns
end % if nanum~==1

% cut before
Abefore=A(1:before,:); A(1:before,:)=[];
% cut after
tmp=flipud(A); Aafter=tmp(1:after,:); Aafter=flipud(Aafter); 
tmp(1:after,:)=[]; A=flipud(tmp);

% ________normalization of 'normalization phase'__________________
[m,q]=size(A);
spaces=n-1;
inc=spaces/(m-1);
tmpa=[0:inc:spaces]';
tmpa=[tmpa,A];
for k=2:q+1   % q number of columns
for i=0:spaces
    low =max(find(tmpa(:,1)<i));
    high=min(find(tmpa(:,1)>=i));
    if i==0; low=[1]; high=[2]; end;
      a1=tmpa(low,k);
      a2=tmpa(high,k);
      H1=[tmpa(low,1),1;tmpa(high,1),1]; H2=[a1;a2]; % solve for y=mx+b  
      Coef=H1\H2;
    N(i+1,k-1)= Coef(1,1)  * i + Coef(2,1);
    end
end
time=[0:spaces]';

% ___________________normalization for before________________________________
temp1=[0:before]';
temp1=-temp1.*inc;
temp1=[temp1,[A(1,:);flipud(Abefore)]]; %temp = [ 0     , data, data;
last=fix(min(temp1(:,1)));              %        -1*inc, data, data;...]
[p,q]=size(temp1);
for k=2:q %columns
    for i=-1:-1:last
    
    low=max(find(temp1(:,1)>i));
    high=min(find(temp1(:,1)<=i));
      
      a1=temp1(low,k);
      a2=temp1(high,k);
      H1=[temp1(low,1),1;temp1(high,1),1]; H2=[a1;a2]; % solve for y=mx+b  
      Coef=H1\H2;
    Nbefore(-i,k)= Coef(1,1)  * i + Coef(2,1);
    end
end
if before~=0; Nbefore(:,1)=[]; end
Nbefore=flipud(Nbefore);
timebefore=[last:1:-1]';


%___________________normalization for after_____________________________
temp1=[0:after]';
temp1=temp1.*inc+spaces;
temp1=[temp1,[A(size(A,1),:);Aafter]];  %temp1= [n-1     , data, data;
last=fix(max(temp1(:,1)));              %       n-1+1*inc, data, data;...]

[p,q]=size(temp1);
for k=2:q %columns
    for i=n:last
    low =max(find(temp1(:,1)<i));
    high=min(find(temp1(:,1)>=i));
      a1=temp1(low,k);
      a2=temp1(high,k);
      H1=[temp1(low,1),1;temp1(high,1),1]; H2=[a1;a2]; % solve for y=mx+b  
      Coef=H1\H2;
    Nafter(i-spaces,k)= Coef(1,1)  * i + Coef(2,1);
    end
end
if after~=0 ; Nafter(:,1)=[]; end;
timeafter=[n:last]';

N=[Nbefore;N;Nafter];
time=[timebefore;time;timeafter];

