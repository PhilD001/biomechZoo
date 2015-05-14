function r = rmse(a,b)

% r = RMSE(a,b) computes the root mean squared error between two vectors
%
% ARGUMENTS
%  a   ...  1st vector of data
%  b   ...  2nd vector of data
%
% RETURN
%  r   ...  RMSE between a and b

% Revision History
%
% Created by Philippe Dixon  Feb 2012 
%
% Updated by Philippe Dixon May 2015
% - preallocated 'diffs' variable instead of stacking it


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



a = makecolumn(a);
b = makecolumn(b);

if size(a) ~=size(b)
    disp('vectors are not the same size')
    return
end


[rows,~] = size(a);

diffs = zeros(rows,1);
for i = 1:rows    
   diffs(i) = (a(i) - b(i)).^2;
end

r = sqrt(sum(diffs)./rows);


