function prmt = concatPrompt(prmt,n)

% prmt = CONCATENSPROMPT(prmt,n) recursively concatenates the prompt at the top of ensembler
% figures to a maximum number n of characters

if nargin==1
    
    indx = strfind(prmt,filesep);
    if length(indx) > 6
       prmt = prmt(indx(5):end);
    elseif length(indx) > 5
       prmt = prmt(indx(4):end);
    elseif length(indx) > 4
       prmt = prmt(indx(3):end);
    elseif length(indx) > 3
       prmt = prmt(indx(2):end);
    elseif length(indx) > 2
       prmt = prmt(indx(1):end);
       
    end
    
else
    
    while length(prmt) > n
        sindx = strfind(prmt,filesep);
        nsindx = round(length(sindx)/2)-1;
        prmt = prmt(sindx(nsindx):end);
    end
    
end