function y=char2num(y)

% y=char2num(y) support function for machine learning module, converts
% charater to number

if ~isa(y,'double')
    temp=y;
    y=zeros([length(y),1]);
    condi=unique(temp);
    for i=1:length(condi)
        y(contains(temp,condi{i}))=i;
    end
    
end