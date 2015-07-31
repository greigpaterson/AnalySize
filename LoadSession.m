function handles = LoadSession(handles, Session_handles)
%
% Function to load a saved AnalySize session
%

% [file,path] = uigetfile('*.mat','Load a saved session...');
% 
% if ~ischar(file) && file==0
%     % User has cancelled
%     % Do nothing and...
%     handles.Cancel_Flag = 1;
%     return;
% end
% 
% 
% try
%     load(strcat(path, file), 'Session_handles');
% catch
%     % Warn about invalid mat files and return
%     warndlg('This is not a valid session file. Please try another.', 'Invalid files');
%         handles.Cancel_Flag = 1;
%     return;
% end
% 
% handles.Cancel_Flag = 0;


fNames = fieldnames(Session_handles);
nFields = length(fNames);

for ii = 1:nFields
    handles.(fNames{ii}) = Session_handles.(fNames{ii});
end

