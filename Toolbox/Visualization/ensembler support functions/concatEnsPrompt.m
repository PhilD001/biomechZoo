function prmt = concatEnsPrompt(prmt)

% prmt = CONCATENSPROMPT(prmt) recursively concatenates the prompt at the top of ensembler 
% figures to a maximum number n of characters


indx = strfind(prmt,filesep);

if length(indx) >1
    prmt = prmt(indx(2):end);
end



% old code

% if nargin==1
%     n = 100;
% end
% 
% 
% while length(prmt) > n
%     sindx = strfind(prmt,filesep);
%     nsindx = round(length(sindx)/2)-1;
%     prmt = prmt(sindx(nsindx):end);
%     prmt = concatEnsPrompt(prmt);
% end