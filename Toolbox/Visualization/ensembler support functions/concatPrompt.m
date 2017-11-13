function prmt = concatPrompt(prmt,n)

% prmt = CONCATENSPROMPT(prmt,n) recursively concatenates the prompt at the top of ensembler
% figures to a maximum number n of characters

if nargin==1
    
    indx = strfind(prmt,filesep);
    if length(indx) >1
        prmt = prmt(indx(2):end);
    end
    
else
    
    while length(prmt) > n
        sindx = strfind(prmt,filesep);
        nsindx = round(length(sindx)/2)-1;
        prmt = prmt(sindx(nsindx):end);
    end
    
end