function [O,A,L,P] = getGlobalCoord(data,O,A,L,P,segment,boneLength,test)

% [O,A,L,P] = GETGLOBALCOORD(data,O,A,L,P,segment,boneLength,test) moves
% locally defined coordinate system vectors to global and scales to bone
% length (required for matching with Vicon outputs)

% make unit vectors
%
P = makeunit(P);
A = makeunit(A);
L = makeunit(L);


% Scale to length of bone
%
for i = 1:3
    A(:,i) = A(:,i).*boneLength;
    L(:,i) = L(:,i).*boneLength;
    P(:,i) = P(:,i).*boneLength;
end

% Move to global coordinate system
%
A = A + O;
L = L + O;
P = P + O;

% Check results
if test ==1
    comparePiG(data,segment,O,A,L,P)
    comparePiGangles(data,segment,O,A,L,P)
end
