function SaveSession(handles)
%
% Function to save an AnalySize session
%

% Get the output file
[file,path] = uiputfile('AnalySize_Saved_Session.mat','Save session...');


if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end


fNames = [{'Data_Loaded'}, {'Plot_Fits_Flag'}, {'FitStatus'},...
    {'All_Fit_Types'}, {'All_Fit_EMs'}, {'All_Fit_Abunds'}, {'All_Fit_Params'},...
    {'Fit_Table_Data'}, {'All_DataSet_QFit'}, {'All_Specimen_QFit'}, {'All_Fit_N'}, {'Fit_Data_Ind'}, {'Sel_EM_Data'},...
    {'Current_Fit_Type'}, {'Current_Fit_EMs'}, {'Current_Fit_Abunds'}, {'Current_Fit_Params'}, {'Current_Fit_PDFs'}, {'Current_Specimen_Fit'},...
    {'nEnd'}, {'DataSet_QFit'}, {'Specimen_QFit'}, {'nVar'}, {'Nspec'},{'spec_ind'}, ...
    {'All_Names'}, {'All_Data'}, {'All_GS'},{'All_LGS'}, {'All_Phi'},...
    {'Current_Data'}, {'Current_GS'}, {'Current_LGS'}, {'Current_Phi'}];

nFields = length(fNames);
Session_handles = struct();

for ii = 1:nFields
        Session_handles.(fNames{ii}) = handles.(fNames{ii});
end

save(strcat(path, file), 'Session_handles');