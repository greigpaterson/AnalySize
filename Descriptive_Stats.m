function varargout = Descriptive_Stats(varargin)
% DESCRIPTIVE_STATS MATLAB code for Descriptive_Stats.fig
%      DESCRIPTIVE_STATS, by itself, creates a new DESCRIPTIVE_STATS or raises the existing
%      singleton*.
%
%      H = DESCRIPTIVE_STATS returns the handle to a new DESCRIPTIVE_STATS or the handle to
%      the existing singleton*.
%
%      DESCRIPTIVE_STATS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DESCRIPTIVE_STATS.M with the given input arguments.
%
%      DESCRIPTIVE_STATS('Property','Value',...) creates a new DESCRIPTIVE_STATS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Descriptive_Stats_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Descriptive_Stats_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Descriptive_Stats

% Last Modified by GUIDE v2.5 20-May-2015 15:11:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Descriptive_Stats_OpeningFcn, ...
    'gui_OutputFcn',  @Descriptive_Stats_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Descriptive_Stats is made visible.
function Descriptive_Stats_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Descriptive_Stats (see VARARGIN)

% Choose default command line output for Descriptive_Stats
handles.output = hObject;


DataTransfer = find(strcmp(varargin, 'DataTransfer'));
if (isempty(DataTransfer)) ...
        || (length(varargin) <= DataTransfer)% ...
    
    disp('------------------------------------------');
    disp('If you see this, something has gone wrong.')
    disp('      Please contact Greig Paterson       ')
    disp('------------------------------------------');
    
else
    DataTransfer = varargin{DataTransfer+1};
    handles.MainWindow = varargin{3};
    handles.SSU_Flag = varargin{4};
end


% Position to be relative to parent:
parentPosition = get(handles.MainWindow, 'Position'); %getpixelposition(handles.MainWindow)
currentPosition = get(hObject, 'Position');
% Set x to be directly in the middle, and y so that their tops align.
newX = parentPosition(1) + (parentPosition(3)/2 - currentPosition(3)/2);
newY = parentPosition(2) + (parentPosition(4)/2 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);
set(hObject, 'Position', [newX, newY, newW, newH]);


% Get the data from previous window
handles.Data = DataTransfer.Data;
handles.GS = DataTransfer.GS;
handles.All_Names = DataTransfer.Names;


% Call the function to get the stats
handles.All_Stats = cell(5,1);
for ii = 1:5
    handles.All_Stats(ii) = {Get_Descriptive_Stats(handles.Data, handles.GS, ii)};
end

% Format for the table
T1 = arrayfun(@(x) sprintf('     %3.2f', x), handles.All_Stats{1}, 'UniformOutput', 0);
T2 = arrayfun(@(x) sprintf('     %3.2f', x), handles.All_Stats{2}, 'UniformOutput', 0);
T3 = arrayfun(@(x) sprintf('     %3.2f', x), handles.All_Stats{3}, 'UniformOutput', 0);
T4 = arrayfun(@(x) sprintf('     %3.2f', x), handles.All_Stats{4}, 'UniformOutput', 0);
T5 = arrayfun(@(x) sprintf('   %3.2f', x), handles.All_Stats{5}, 'UniformOutput', 0);

set(handles.Table_Geo_Moment, 'Data', [handles.All_Names, T1]);
set(handles.Table_Log_Moment, 'Data', [handles.All_Names, T2]);
set(handles.Table_Geo_Graphic, 'Data',[handles.All_Names, T3]);
set(handles.Table_Log_Graphic, 'Data', [handles.All_Names, T4]);
set(handles.Table_Percentiles, 'Data', [handles.All_Names, T5]);


if handles.SSU_Flag == 1
    set(handles.SSU_Panel, 'Visible', 'On');
    handles.All_SSU_EMs = varargin{5};
    handles.All_SSU_Names = varargin{6};
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Descriptive_Stats wait for user response (see UIRESUME)
% uiwait(handles.Descriptive_Stats_MW);


% --- Outputs from this function are returned to the command line.
function varargout = Descriptive_Stats_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in any Svae buttons.
function Save_Data_Callback(hObject, eventdata, handles, Flag)
% hObject    handle to Save_Geo_Moments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch Flag
    case 1
        Name = 'Geometric_Moment_Stats.dat';
        Header = [{'Specimen'}, {'Mean (microns)'}, {'Sigma (microns)'}, {'Skewness'}, {'Kurtosis'}];
    case 2
        Name = 'Log_Moment_Stats.dat';
        Header = [{'Specimen'}, {'Mean (phi)'}, {'Sigma (phi)'}, {'Skewness'}, {'Kurtosis'}];
    case 3
        Name = 'Geometric_Graphic_Stats.dat';
        Header = [{'Specimen'}, {'Mean (microns)'}, {'Sigma (microns)'}, {'Skewness'}, {'Kurtosis'}];
    case 4
        Name = 'Log_Graphic_Stats.dat';
        Header = [{'Specimen'}, {'Mean (phi)'}, {'Sigma (phi)'}, {'Skewness'}, {'Kurtosis'}];
    case 5
        Name = 'Percentile_Stats.dat';
        Header = [{'Specimen'}, {'P10'}, {'P25'}, {'P50'}, {'P75'}, {'P90'}];

end

[file, path] = uiputfile(Name, 'Save descriptive stats...');


if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end

LineEnd = getappdata(handles.MainWindow, 'LineEnd');

Data = num2cell(handles.All_Stats{Flag});
Data = [handles.All_Names, Data]';


if Flag ==5 
    fmt1 = strcat('%s\t%s\t%s\t%s\t%s\t%s', LineEnd);
    fmt2 = strcat('%s\t%f\t%f\t%f\t%f\t%f', LineEnd);    
else
    fmt1 = strcat('%s\t%s\t%s\t%s\t%s', LineEnd);
    fmt2 = strcat('%s\t%f\t%f\t%f\t%f', LineEnd);
end

fout = fopen(strcat(path, file), 'wt');
fprintf(fout, fmt1, Header{:});

fprintf(fout, fmt2, Data{:});

fclose(fout);


% --- Executes on selection change in SSU_Stat_Menu.
function SSU_Stat_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to SSU_Stat_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SSU_Stat_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SSU_Stat_Menu


% --- Executes during object creation, after setting all properties.
function SSU_Stat_Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SSU_Stat_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save_SSU.
function Save_SSU_Callback(hObject, eventdata, handles)
% hObject    handle to Save_SSU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Stat_Flag = get(handles.SSU_Stat_Menu, 'Value');

switch Stat_Flag
    case 1
        Name = 'SSU_Geometric_Moment_Stats.dat';
    case 2
        Name = 'SSU_Log_Moment_Stats.dat';
    case 3
        Name = 'SSU_Geometric_Graphic_Stats.dat';
    case 4
        Name = 'SSU_Log_Graphic_Stats.dat';
    case 5
        Name = 'SSU_Percentile_Stats.dat';
end

[file, path] = uiputfile(Name, 'Save all SSU descriptive stats...');


if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end


nStat = 4;
Stat_Names = [{'Mean'}, {'StDev'}, {'Skewness'}, {'Kurtosis'}];
if Stat_Flag == 5
    nStat = 5;
    Stat_Names = [{'P10'}, {'P25'}, {'P50'}, {'P75'}, {'P90'}];
end

Data = handles.All_SSU_EMs;
GS = handles.GS;

nData = length(Data);
kmax = max(cellfun(@(x) size(x, 1), Data));
nVals = nStat*kmax;

% Get the stats and reshape for output
Stats = cellfun(@(x) Get_Descriptive_Stats(x, GS, Stat_Flag), Data, 'UniformOutput', 0);
tmp_out = cellfun(@(x) reshape(x', 1, numel(x)) , Stats, 'UniformOutput', 0);

% Find the indices with < kmax end members and pad with NaNs
inds = cellfun(@(x) size(x,2) < nVals , tmp_out);
tmp_out(inds) = cellfun(@(x) [x, NaN(1, nVals-size(x,2))], tmp_out(inds), 'UniformOutput', 0);

% the final output
Output = [handles.All_SSU_Names, num2cell(cell2mat(tmp_out))]';

% Make the header
Header = {'Specimen'};

LineEnd = getappdata(handles.MainWindow, 'LineEnd');
fmt1 = '%s';
fmt2 = '%s';

for ii = 1:kmax
    for jj = 1:nStat
        Header = [Header, { ['EM', sprintf('% d ', ii), Stat_Names{jj}] } ]; %#ok<AGROW>
        fmt1 = strcat(fmt1, '\t%s');
        fmt2 = strcat(fmt2, '\t%f');
    end
end

fmt1 = strcat(fmt1, LineEnd);
fmt2 = strcat(fmt2, LineEnd);

fout = fopen(strcat(path, file), 'wt');
fprintf(fout, fmt1, Header{:});
fprintf(fout, fmt2, Output{:});
fclose(fout);
