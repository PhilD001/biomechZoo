function rmdir(fld)

% RMDIR removes folders for the mac platform
%
% ARGUMENTS
%  fld         ... folder to remove as string


% Revision History
%
% Created by Philippe C. Dixon based on Matlab Newsgroup file Feb 2012


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
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 


if ispc
    dos(['rmdir /S/Q ' fld]);
    disp('this function should only load on mac platform. Check your path')
else
    unix(['rm -f -R ' '"' fld '"']);
end

