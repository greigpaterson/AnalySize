function [EMs, Sinds] = sortEMs(EMs, GS)
%
% Function to sort returned end members by their median grain size
%

Meds = GetPercentile(EMs, GS', 50);

[~, Sinds] = sort(Meds);
EMs = EMs(Sinds,:);