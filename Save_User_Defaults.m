function Save_User_Defaults(Defaults)
%
% Saves user specified default paramters for AnalySize
%

% Get the main path
S = mfilename('fullpath');
name_len = length(mfilename());
MyPath = S(1:end-name_len);


% Do the color defaults first
EM_Plot = Defaults.EM_Plot_Color;
Tern_Plot = Defaults.Tern_Plot_Color;

% Save the color file and remove the fields from Defaults
save(strcat(MyPath, 'UserColorDefaults.mat'), 'EM_Plot', 'Tern_Plot');
Defaults = rmfield(Defaults, {'EM_Plot_Color', 'Tern_Plot_Color'});

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