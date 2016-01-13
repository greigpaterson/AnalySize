function Defaults = Read_Config_File(MyPath)
%
% Function to read in a AnalySize configuration file, which contains
% various default settings
%

% Get the basic setting names and types
All_Settings = [{'PlotColorFile'}, {'TernFaceColor'}, {'TernSymbol'}, {'TernSymbolSize'},...
    {'CMFaceColor'}, {'CMSymbol'}, {'CMSymbolSize'},...
    {'DataFormat'}, {'FileDelimiter'}, {'MultiSpec'},...
    {'XLLayout'}, {'XL1_1'}, {'XL1_2'}, {'XL1_3'}, {'XL1_4'},...
    {'XL2_1'}, {'XL2_2'}, {'XL2_3'}, {'XL2_4'} ];

Setting_Types = [{'String'}, {'String'}, {'String'}, {'Number'},...
    {'String'}, {'String'}, {'Number'},...
    {'String'}, {'String'}, {'Number'},...
    {'Number'}, {'Number'}, {'String'}, {'String'}, {'String'},...
    {'Number'}, {'String'}, {'String'}, {'String'} ];

nSettings = length(All_Settings);

% Find the config file
if exist(strcat(MyPath, 'UserDefaults.cfg'), 'file') == 2
    % The file exists so load user defaults
    Config_File = strcat(MyPath, 'UserDefaults.cfg');
elseif exist(strcat(MyPath, 'AnalySizeDefaults.cfg'), 'file') == 2
    % Use the basic defaults
    Config_File = strcat(MyPath, 'AnalySizeDefaults.cfg');
else
    error('AnalySize:Read_Config',...
        'No AnalySize configuration file is present. Please check the AnalySize path for the configuration file.');
end

% Open and read the file
FID=fopen(Config_File, 'r');
input=textscan(FID, '%s = %s\n');
fclose(FID);
nDefault = length(input{1});


if nDefault ~= nSettings
    % if the number of settings doesn't match try different line endings
    FID=fopen(Config_File, 'r');
    input=textscan(FID, '%s = %s\r\n');
    fclose(FID);
    nDefault = length(input{1});
end

if nDefault ~= nSettings
    % if the number of settings still doesn't match try the default config file
    warning('AnalySize:ConfigFile', 'Configuration file inconsistent, attempting load default configuration file.')
    Config_File = strcat(MyPath, 'AnalySizeDefaults.cfg');
    FID=fopen(Config_File, 'r');
    input=textscan(FID, '%s = %s\n');
    fclose(FID);
    nDefault = length(input{1});
end

if nDefault ~= nSettings
    % if the number of settings STILL doesn't match - ERROR
    error('AnalySize:ConfigFile', 'Default configuration file is corrupted or settings are missing.');
end

% The return structure
Defaults = struct();

for ii=1:nSettings
    
    % Check the input type
    if strcmpi(Setting_Types{ii}, 'String')
        if ~ischar(input{2}{ii})
            error('AnalySize:ConfigFile', '%s should be a text input.', All_Settings{ii});
        end
    else
        if ~isnumeric(str2double(input{2}{ii}))
            error('AnalySize:ConfigFile', '%s should be a number input.', All_Settings{ii});
        end
    end
    
    if strcmpi(All_Settings{ii}, 'PlotColorFile')
        
        try
            tmp_input = load(strcat(MyPath, input{2}{ii}) );
            Defaults.EM_Plot_Color = tmp_input.EM_Plot;
            Defaults.Tern_Plot_Color = tmp_input.Tern_Plot;
            Defaults.CM_Plot_Color = tmp_input.CM_Plot;
            
        catch
            error('AnalySize:ConfigFile', 'Default color file (%s) not found.', input{2}{ii})
        end
        
    elseif strcmpi(Setting_Types{ii}, 'String')
        % It is a text input
        Defaults.(All_Settings{ii}) = input{2}{ii};
    else %number
        Defaults.(All_Settings{ii}) = str2double(input{1,2}{ii});
    end
end

