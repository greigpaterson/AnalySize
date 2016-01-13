function [EMs, Sinds, Vals] = sortEMs(EMs, GS, Type)
%
% Function to sort returned end members by their median or modal grain size
%

if nargin < 3
    Type = 'Median';   
end

k = size(EMs, 1);

if strcmpi(Type, 'Mode')
    Vals = NaN(k,1);
    for ii = 1:k
        Vals(ii) = GS(EMs(ii,:) == max(EMs(ii,:)));
    end
else
    Vals = GetPercentile(EMs, GS', 50);
end

[SortedVals, Sinds] = sort(Vals);
EMs = EMs(Sinds,:);
Vals = Vals(Sinds);
