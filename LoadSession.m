function handles = LoadSession(handles, Session_handles)
%
% Function to load a saved AnalySize session
%

% TODO: Add version checking for compatability

fNames = fieldnames(Session_handles);
nFields = length(fNames);

for ii = 1:nFields
    handles.(fNames{ii}) = Session_handles.(fNames{ii});
end

