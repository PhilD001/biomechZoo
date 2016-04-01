function [acorr] = correct(a)

% function [acorr] = correct(a)
% Description:	   "The ultimate cheating program": This programs helps to find 
%		   outliers in data. This program is very helpful to check
% 		   manually (or even automatically) digitized markers.
% Input:	   a:     Data that should be corrected/ screened. 
%		          "a" has to be a vector.
% Output:	   acorr: Corrected data or if no corrections were used "acorr"
%		          is identical to "a".
% Author:	   Christoph Reinschmidt, HPL, The University of Calgary
% Date:		   September, 1994,
% Last Changes:	   November 29, 1996
% Version:	   1.0


if size(a,2)~=1
disp('Input matrix should only have one column. Try again!'), break;
end

choice=[3];
ax=[1:1:size(a)]';
acorr=a;

while choice==[3] | choice==[4];
  clg
  plot(ax,a)
  hold on
  plot(ax,a,'r.')
  title('Correct: left mouse button        Exit: right mouse button')
  [x,y,button]=ginput(1);

  if button==[2] | button==[3]; clg; close; return; end
  
  acorr(round(x),1)=y;
  x
   if (x<2) | (x>(size(a,1)-1))
     plot(ax,acorr,'-c',ax,acorr,'.b',[x],a(x,1),'or')
   else
     adjacent=a(round(x)-1:round(x)+1,1);
     plot(ax,acorr,'-c',ax,acorr,'.b',...
          [round(x)-1;round(x);round(x)+1],adjacent,'or')
  end

  text([round(x)],a(round(x),1),'outlier')
  choice=menu('CORRECTIONS','accept and exit','reject and exit',...
               'accept and more', 'reject and more');

  if choice==[1]; clg; close; return; end
  if choice==[2]; acorr=a; close; end
  if choice==[3]; a=acorr; end
  if choice==[4]; acorr=a; end   

end %while choice==[3]
