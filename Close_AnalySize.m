function Close_AnalySize()
%
% Function that will forcibly close all AnalySize windows.
% Useful in the event of an error that occurs when a window is modal (i.e.,
% other windows or functions cannot be access until the modal window has
% completed its process).
%
% Note:
%       This will close all widows with the same names as those used by
%       AnalySize, but which might not be related to AnalySize function.
%

%% Get all the window names
WindowNames = [{'AnalySize'}; {'About AnalySize'};...
    {'Calculating end member fits...'}; {'Censor Data'}; {'Choose the fit type'}; {'CM Plot'};...
    {'Data file load options'}; {'Descriptive Statistics'}; {'EM Colors'};...
    {'Remove Specimen?'}; {'Select End Members'}; {'Set Symbols'}; {'Spectra Plot'};...
    {'Ternary Plots'}];


nWindows = size(WindowNames, 1);

%% Close them

for ii = 1:nWindows
    h = findall(0,'type','figure', 'name', WindowNames{ii});
    delete(h);
end


