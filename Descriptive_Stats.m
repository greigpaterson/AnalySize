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

% Last Modified by GUIDE v2.5 22-Mar-2023 12:44:38

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
handles.All_Stats = cell(7,1);
for ii = 1:7
    handles.All_Stats(ii) = {Get_Descriptive_Stats(handles.Data, handles.GS, ii)};
end

% Format for the table
T1 = arrayfun(@(x) sprintf('     %3.2f', x), handles.All_Stats{1}, 'UniformOutput', 0);
T2 = arrayfun(@(x) sprintf('     %3.2f', x), handles.All_Stats{2}, 'UniformOutput', 0);
T3 = arrayfun(@(x) sprintf('     %3.2f', x), handles.All_Stats{3}, 'UniformOutput', 0);
T4 = arrayfun(@(x) sprintf('     %3.2f', x), handles.All_Stats{4}, 'UniformOutput', 0);
T5 = arrayfun(@(x) sprintf('   %3.2f', x), handles.All_Stats{5}, 'UniformOutput', 0);
T6 = arrayfun(@(x) sprintf('   %3.2f', x), handles.All_Stats{6}, 'UniformOutput', 0);
T7 = arrayfun(@(x) sprintf('   %3.2f', x), handles.All_Stats{7}, 'UniformOutput', 0);

set(handles.Table_Geo_Moment, 'Data', [handles.All_Names, T1]);
set(handles.Table_Log_Moment, 'Data', [handles.All_Names, T2]);
set(handles.Table_Geo_Graphic, 'Data',[handles.All_Names, T3]);
set(handles.Table_Log_Graphic, 'Data', [handles.All_Names, T4]);
set(handles.Table_Percentiles, 'Data', [handles.All_Names, T5]);
set(handles.Table_Size_Fractions, 'Data', [handles.All_Names, T6]);
set(handles.Table_Sortable_Silt, 'Data', [handles.All_Names, T7]);

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

LineEnd = getappdata(handles.MainWindow, 'LineEnd');

switch Flag
    case 1
        Name = 'Geometric_Moment_Stats.dat';
        Header = [{'Specimen'}, {'Mean (microns)'}, {'Sigma (microns)'}, {'Skewness'}, {'Kurtosis'}];
        fmt1 = strcat('%s\t%s\t%s\t%s\t%s', LineEnd);
        fmt2 = strcat('%s\t%f\t%f\t%f\t%f', LineEnd);
    case 2
        Name = 'Log_Moment_Stats.dat';
        Header = [{'Specimen'}, {'Mean (phi)'}, {'Sigma (phi)'}, {'Skewness'}, {'Kurtosis'}];
        fmt1 = strcat('%s\t%s\t%s\t%s\t%s', LineEnd);
        fmt2 = strcat('%s\t%f\t%f\t%f\t%f', LineEnd);
    case 3
        Name = 'Geometric_Graphic_Stats.dat';
        Header = [{'Specimen'}, {'Mean (microns)'}, {'Sigma (microns)'}, {'Skewness'}, {'Kurtosis'}];
        fmt1 = strcat('%s\t%s\t%s\t%s\t%s', LineEnd);
        fmt2 = strcat('%s\t%f\t%f\t%f\t%f', LineEnd);
    case 4
        Name = 'Log_Graphic_Stats.dat';
        Header = [{'Specimen'}, {'Mean (phi)'}, {'Sigma (phi)'}, {'Skewness'}, {'Kurtosis'}];
        fmt1 = strcat('%s\t%s\t%s\t%s\t%s', LineEnd);
        fmt2 = strcat('%s\t%f\t%f\t%f\t%f', LineEnd);
    case 5
        Name = 'Percentile_Stats.dat';
        Header = [{'Specimen'}, {'P10'}, {'P25'}, {'P50'}, {'P75'}, {'P90'}];
        fmt1 = strcat('%s\t%s\t%s\t%s\t%s\t%s', LineEnd);
        fmt2 = strcat('%s\t%f\t%f\t%f\t%f\t%f', LineEnd);
    case 6
        Name = 'Size_Fraction_Stats.dat';
        Header = [{'Specimen'}, {'Clay'}, {'Silt'}, {'Sand'}, {'Gravel'}];
        fmt1 = strcat('%s\t%s\t%s\t%s\t%s', LineEnd);
        fmt2 = strcat('%s\t%f\t%f\t%f\t%f', LineEnd);
    case 7
        Name = 'Sortable_Silt_Stats.dat';
        Header = [{'Specimen'}, {'Geo. Mean'}, {'Log. Mean'}, {'Percentage'}];
        fmt1 = strcat('%s\t%s\t%s\t%s', LineEnd);
        fmt2 = strcat('%s\t%f\t%f\t%f', LineEnd);
end

[file, path] = uiputfile(Name, 'Save descriptive stats...');


if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end


Data = num2cell(handles.All_Stats{Flag});
Data = [handles.All_Names, Data]';

fout = fopen(strcat(path, file), 'wt');
fprintf(fout, fmt1, Header{:});

fprintf(fout, fmt2, Data{:});

fclose(fout);
