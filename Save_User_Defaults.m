function Save_User_Defaults(Defaults)
%
% Saves user specified default paramters for AnalySize
%


% Get the main path
S = mfilename('fullpath');
name_len = length(mfilename());
MyPath = S(1:end-name_len);


% Do the color defaults first
Data_Plot = Defaults.Data_Plot_Color;%#ok<*NASGU>
EM_Plot = Defaults.EM_Plot_Color;
Tern_Plot = Defaults.Tern_Plot_Color;
CM_Plot = Defaults.CM_Plot_Color;
SEM_Box = Defaults.SEM_Box_Plot_Color;
SEM_Median = Defaults.SEM_Median_Plot_Color;
SEM_Outlier = Defaults.SEM_Outlier_Plot_Color;
SEM_Data_R2 = Defaults.SEM_Data_Plot_Color;
SEM_EM_R2 = Defaults.SEM_EM_Plot_Color;

% Save the color file and remove the fields from Defaults
save(strcat(MyPath, 'UserColorDefaults.mat'), 'EM_Plot', 'Data_Plot', 'Tern_Plot', 'CM_Plot',...
    'SEM_Box', 'SEM_Median', 'SEM_Outlier', 'SEM_Data_R2', 'SEM_EM_R2');

Defaults = rmfield(Defaults, {'EM_Plot_Color', 'Data_Plot_Color', 'Tern_Plot_Color', 'CM_Plot_Color',...
    'SEM_Box_Plot_Color', 'SEM_Median_Plot_Color', 'SEM_Outlier_Plot_Color', 'SEM_Data_Plot_Color', 'SEM_EM_Plot_Color'});

% Get the text based settings
FID = fopen( strcat(MyPath, 'UserDefaults.cfg'), 'wt');
fprintf(FID, '%s\n', 'PlotColorFile = UserColorDefaults.mat');

FN = fieldnames(Defaults);
nFields = length(fieldnames(Defaults));

for ii=1:nFields
    fprintf(FID, '%s\n', [FN{ii}, ' = ', num2str(Defaults.(FN{ii})) ] );
end

fclose(FID);

msgbox('Default values saved.', 'modal')
