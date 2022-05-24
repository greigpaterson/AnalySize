function varargout = AnalySize(varargin)
% ANALYSIZE MATLAB code for AnalySize.fig
%      ANALYSIZE, by itself, creates a new ANALYSIZE or raises the existing
%      singleton*.
%
%      H = ANALYSIZE returns the handle to a new ANALYSIZE or the handle to
%      the existing singleton*.
%
%      ANALYSIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSIZE.M with the given input arguments.
%
%      ANALYSIZE('Property','Value',...) creates a new ANALYSIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnalySize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnalySize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnalySize

% Last Modified by Greig Paterson 04-Jul-2020

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @AnalySize_OpeningFcn, ...
    'gui_OutputFcn',  @AnalySize_OutputFcn, ...
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


% --- Executes just before AnalySize is made visible.
function AnalySize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AnalySize (see VARARGIN)

% Choose default command line output for AnalySize
handles.output = hObject;

% UIWAIT makes AnalySize wait for user response (see UIRESUME)
% uiwait(handles.AnalySize_MW);

%% Get some system info and set some defaults

% Get the MATLAB version
Ver = ver('MATLAB');
handles.Version = str2double(Ver.Version);

handles.AnalySize_Version = '1.2.2';
handles.AnalySize_Date = 'May 2022';

handles.Curent_Pos = get(handles.AnalySize_MW, 'Position');

% Get the screen dpi
set(0, 'Units', 'Pixels');
Sp = get(0, 'ScreenSize');
handles.Screen_Res = Sp(3:4);

try
    handles.Screen_DPI = get(0, 'ScreenPixelsPerInch');
catch %#ok<CTCH>
    set(0, 'Units', 'Inches');
    Si = get(0, 'ScreenSize');
    set(0, 'Units', 'Pixels');
    dpi = Sp./Si;
    handles.Screen_DPI = mean(dpi(3:4));
end

% Set the position to about mid screen
currentPosition = get(handles.AnalySize_MW, 'Position');
newX = Sp(1) + (Sp(3)/2 - currentPosition(3)/2);
newY = Sp(2) + (Sp(4)/2 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);
set(handles.AnalySize_MW, 'Position', [newX, newY, newW, newH]);


% Get the OS and line endings for outputting files
if ispc
    handles.OS = 'Win';
    handles.Line_End = '\r\n';
elseif ismac
    handles.OS = 'Mac';
    handles.Line_End = '\n';
elseif isunix
    handles.OS = 'Unix';
    handles.Line_End = '\n';
else
    handles.OS = 'Unknown';
    handles.Line_End = '\n';
end

% Get the user defaults

% Get the current path of the main m-file
S = mfilename('fullpath');
name_len = length(mfilename());
MyPath = S(1:end-name_len);

Defaults = Read_Config_File(MyPath);


% Get the defaults needed for the main window
handles.Default_Plot_Colors = Defaults.EM_Plot_Color;
handles.Default_Data_Color = Defaults.Data_Plot_Color;
handles.Default_Data_Symbol = Defaults.DataSymbol;
handles.Default_Data_Symbol_Size = Defaults.DataSymbolSize;

if strcmpi(Defaults.DataFaceColor, 'filled')
    handles.Default_Data_Symbol_Fill = handles.Default_Data_Color;
else
    handles.Default_Data_Symbol_Fill = 'none';
end


% set(handles.PDF_Axes, 'ColorOrder', handles.Default_Plot_Colors);
% set(handles.EM_Axes, 'ColorOrder', handles.Default_Plot_Colors);

func_handles = SetDefaultHandles(handles, 'All');
handles = func_handles;


% Set key data to appdata
setappdata(handles.AnalySize_MW, 'LineEnd', handles.Line_End);
setappdata(handles.AnalySize_MW, 'OS', handles.OS);
setappdata(handles.AnalySize_MW, 'Resolution', handles.Screen_Res);
setappdata(handles.AnalySize_MW, 'DPI', handles.Screen_DPI);
setappdata(handles.AnalySize_MW, 'Defaults', Defaults );
setappdata(handles.AnalySize_MW, 'Version', handles.Version);


% Set window names for closing function
handles.WindowNames = [{'About AnalySize'}; {'Censor Data'}; {'CM Plot'}; {'Descriptive Statistics'}; {'EM Colors'};...
    {'Set Symbol'}; {'Spectra Plot'}; {'Ternary Plots'}];

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = AnalySize_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close AnalySize_MW.
function AnalySize_MW_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to AnalySize_MW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if handles.Data_Loaded ~= 0
    
    choice = questdlg('Do you want to save before quitting?', 'Save Session?', 'Yes', 'No', 'Cancel', 'Cancel');
    
    if strcmpi(choice, 'Yes')
        MB_Save_Session_Callback(hObject, eventdata, handles);
    end
    
    if strcmpi(choice, 'Cancel')
        return;
    else
        nWindows = size(handles.WindowNames, 1);
        
        for ii = 1:nWindows
            h = findall(0,'type','figure', 'name', handles.WindowNames{ii});
            close(h);
        end
        
        delete(hObject);
    end
    
    
else
    % No data loaded, just ask to quit or not
    choice = questdlg('Do you want to quit?', 'Quite AnalySize?', 'Yes', 'No', 'No');
    
    if strcmpi(choice, 'Yes')
        
        nWindows = size(handles.WindowNames, 1);
        
        for ii = 1:nWindows
            h = findall(0,'type','figure', 'name', handles.WindowNames{ii});
            close(h);
        end
        
        delete(hObject);
        
    else
        return;
    end
    
end


% --- Set the current data
% set the data for the currently loaded sample
function func_handles = Set_Current_Data(handles)

X = handles.All_Data{handles.spec_ind};

GS=handles.All_GS{:,handles.spec_ind};
LGS=handles.All_LGS{:,handles.spec_ind};
Phi = handles.All_Phi{:,handles.spec_ind};

handles.Current_Data = X;
% handles.Current_Data_CS = cumsum(X);
handles.Current_LGS = LGS;
handles.Current_GS = GS;
handles.Current_Phi = Phi;

% Need to update the endmember fit for SSU
func_handles=Set_Current_Fit(handles);
handles = func_handles;

Update_Plots(handles)

% Save the updated handles to the temporary variable func_handles
func_handles=handles;


% --- Set the currently selected fit
% set the data for the currently selected fit
function func_handles=Set_Current_Fit(handles)

Fit_Ind = handles.Fit_Data_Ind;
spec_ind = handles.spec_ind;

if Fit_Ind ~= 0
    
    handles.Current_Fit_Type = handles.All_Fit_Types{1,Fit_Ind};
    handles.Specimen_QFit = handles.All_Specimen_QFit{1, Fit_Ind};
    handles.DataSet_QFit = handles.All_DataSet_QFit{1, Fit_Ind};
    
    
    handles.Current_Fit_EMs = handles.All_Fit_EMs{1,Fit_Ind};
    handles.Current_Fit_Abunds = handles.All_Fit_Abunds{1,Fit_Ind};
    handles.Current_Fit_Params = handles.All_Fit_Params{1,Fit_Ind};
    
    handles.Current_Fit_PDFs = handles.Current_Fit_Abunds(spec_ind,:) * handles.Current_Fit_EMs;
    handles.Current_Specimen_Fit = repmat(handles.Current_Fit_Abunds(handles.spec_ind,:), handles.nVar, 1)'.*handles.Current_Fit_EMs;
    handles.nEnd = size(handles.Current_Fit_EMs, 1);
    
    Table_Abunds = 100.*handles.Current_Fit_Abunds;
    
end

% Update the plots
Update_Plots(handles);

% update the data table
nFits = handles.nEnd;
Cols = handles.Table_Cols;
Tdata = [handles.All_Names, num2cell(handles.Specimen_QFit) ];
for ii = 1:nFits
    Cols = [Cols, strcat('EM', sprintf('% d', ii) ) ]; %#ok<AGROW>
    Tdata = [Tdata, num2cell(Table_Abunds(:,ii))]; %#ok<AGROW>
end

set(handles.Data_Table, 'Data', Tdata, 'ColumnName', Cols);

func_handles = handles;


% --- update the plots
function Update_Plots(handles)

Plot_Type = get(handles.Plot_Type, 'Value');
Plot_Fits = handles.Plot_Fits_Flag;

% Get the plot symbols
Msymbol = handles.Default_Data_Symbol;
Msize = handles.Default_Data_Symbol_Size;
Mcolor = handles.Default_Data_Color;
Mfill = handles.Default_Data_Symbol_Fill;


FUnits = 'Pixels';
FontSize1 = 12; % 12pt font
FontSize2 = 14; % 14pt font

switch Plot_Type
    case 1 % Log Scale
        Xplot=handles.Current_LGS;
        plot(handles.PDF_Axes, Xplot, 100.*handles.Current_Data, 'Marker', Msymbol, 'MarkerSize', Msize, 'MarkerFaceColor', Mfill, 'Color', Mcolor, 'LineStyle', 'none','LineWidth', 1);
        set(get(handles.PDF_Axes, 'XLabel'), 'String', 'Ln(grain size in \mu{m})', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.PDF_Axes, 'YLabel'), 'String', 'Fractional abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.PDF_Axes, 'Title'), 'Interpreter', 'none');
        set(get(handles.PDF_Axes, 'Title'), 'String', handles.All_Names{handles.spec_ind}, 'FontUnits', FUnits, 'FontSize', FontSize2);
        
    case 2 % Log-Linear Scale
        Xplot=handles.Current_GS;
        plot(handles.PDF_Axes, Xplot, 100.*handles.Current_Data,  'Marker', Msymbol, 'MarkerSize', Msize, 'MarkerFaceColor', Mfill, 'Color', Mcolor, 'LineStyle', 'none', 'LineWidth', 1);
        set(handles.PDF_Axes, 'XScale', 'Log');
        set(get(handles.PDF_Axes, 'XLabel'), 'String', 'Grain size [\mu{m}]', 'FontUnits', FUnits, 'FontSize', FontSize1)
        set(get(handles.PDF_Axes, 'YLabel'), 'String', 'Fractional abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.PDF_Axes, 'Title'), 'Interpreter', 'none');
        set(get(handles.PDF_Axes, 'Title'), 'String', handles.All_Names{handles.spec_ind}, 'FontUnits', FUnits, 'FontSize', FontSize2);
        
    case 3 % Phi scale
        Xplot=handles.Current_Phi;
        plot(handles.PDF_Axes, Xplot, 100.*handles.Current_Data,  'Marker', Msymbol, 'MarkerSize', Msize, 'MarkerFaceColor', Mfill, 'Color', Mcolor, 'LineStyle', 'none', 'LineWidth', 1);
        set(get(handles.PDF_Axes, 'XLabel'), 'String', '\phi', 'FontUnits', FUnits, 'FontSize', FontSize1)
        set(get(handles.PDF_Axes, 'YLabel'), 'String', 'Fractional abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.PDF_Axes, 'Title'), 'Interpreter', 'none');
        set(get(handles.PDF_Axes, 'Title'), 'String', handles.All_Names{handles.spec_ind}, 'FontUnits', FUnits, 'FontSize', FontSize2);
        
    case 4 % Linear scale
        Xplot=handles.Current_GS;
        plot(handles.PDF_Axes, Xplot, 100.*handles.Current_Data,  'Marker', Msymbol, 'MarkerSize', Msize, 'MarkerFaceColor', Mfill, 'Color', Mcolor, 'LineStyle', 'none', 'LineWidth', 1);
        set(get(handles.PDF_Axes, 'XLabel'), 'String', 'Grain size [\mu{m}]', 'FontUnits', FUnits, 'FontSize', FontSize1)
        set(get(handles.PDF_Axes, 'YLabel'), 'String', 'Fractional abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.PDF_Axes, 'Title'), 'Interpreter', 'none');
        set(get(handles.PDF_Axes, 'Title'), 'String', handles.All_Names{handles.spec_ind}, 'FontUnits', FUnits, 'FontSize', FontSize2);
end

% Set the default color order for the PDF plot
% Do a MATLAB version check
if handles.Version <= 8.3
    % 2014a and before
    set(handles.PDF_Axes, 'ColorOrder',handles.Default_Plot_Colors);
    handles.PDF_Axes.ColorOrderIndex = 1;
else
    % add black to top for the total PDF fit
    set(handles.PDF_Axes, 'ColorOrder', [[0 0 0]; handles.Default_Plot_Colors]);
    handles.PDF_Axes.ColorOrderIndex = 1;
end

if Plot_Fits==1
    
    PDF_Fits = handles.Current_Fit_PDFs;
    
    EM_Fits = handles.Current_Specimen_Fit;%repmat(handles.Current_Fit_Abunds(handles.spec_ind,:), handles.nVar, 1)'.*handles.Current_Fit_EMs;
    
    hold(handles.PDF_Axes, 'on')
    plot(handles.PDF_Axes, Xplot, 100.*PDF_Fits, 'LineWidth', 2)
    plot(handles.PDF_Axes, Xplot, 100.*EM_Fits, 'LineWidth', 1)
    hold(handles.PDF_Axes, 'off')
    
    tmp_r2 = handles.Specimen_QFit(handles.spec_ind,1);
    tmp_theta = handles.Specimen_QFit(handles.spec_ind,2);
    
    % Check the specimen name and format correctly
    if isnumeric(handles.All_Names{handles.spec_ind})
        MSG = [sprintf('%g', handles.All_Names{handles.spec_ind}), '; R^2 = ', sprintf('%2.3f', tmp_r2), ', Theta = ', sprintf('%2.3f', tmp_theta)];
    elseif ischar(handles.All_Names{handles.spec_ind})
        MSG = [handles.All_Names{handles.spec_ind}, '; R^2 = ', sprintf('%2.3f', tmp_r2), ', Theta = ', sprintf('%2.3f', tmp_theta)];
    else
        warning('AnalySize:SpecimenName', 'The specimen name may not appear correctly. If not please contact Greig Paterson.');
        MSG = [sprintf('%g', handles.All_Names{handles.spec_ind}), '; R^2 = ', sprintf('%2.3f', tmp_r2), ', Theta = ', sprintf('%2.3f', tmp_theta)];
    end
    
    set(get(handles.PDF_Axes, 'Title'), 'Interpreter', 'none');
    set(get(handles.PDF_Axes, 'Title'), 'String', MSG, 'FontUnits', FUnits, 'FontSize', FontSize2);
    
    % Plot the end members in their axes
    cla(handles.EM_Axes, 'reset'); % Reset the axes
    set(handles.EM_Axes, 'ColorOrder', handles.Default_Plot_Colors);
    hold(handles.EM_Axes, 'on')
    plot(handles.EM_Axes, Xplot, 100.*handles.Current_Fit_EMs, 'LineWidth', 1)
    hold(handles.EM_Axes, 'off')
    
    set(get(handles.EM_Axes, 'YLabel'), 'String', 'Fractional abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
    set(get(handles.EM_Axes, 'Title'), 'String', 'End Members', 'FontUnits', FUnits, 'FontSize', FontSize2);
    set(handles.EM_Axes, 'Box', 'on')
    
    switch Plot_Type
        case 1 % Log Scale
            set(get(handles.EM_Axes, 'XLabel'), 'String', 'Ln(grain size in \mu{m})', 'FontUnits', FUnits, 'FontSize', FontSize1)
        case 2 % Log-Linear Scale
            set(handles.EM_Axes, 'XScale', 'Log');
            set(get(handles.EM_Axes, 'XLabel'), 'String', 'Grain size [\mu{m}]', 'FontUnits', FUnits, 'FontSize', FontSize1)
        case 3 % Phi scale
            set(get(handles.EM_Axes, 'XLabel'), 'String', '\phi', 'FontUnits', FUnits, 'FontSize', FontSize1)
        case 4 % Linear scale
            set(get(handles.EM_Axes, 'XLabel'), 'String', 'Grain size [\mu{m}]', 'FontUnits', FUnits, 'FontSize', FontSize1)
    end
    
else
    % Make sure the end member plot is clear
    cla(handles.EM_Axes, 'reset'); % Reset the axes
    
    % Set the basic plot
    switch Plot_Type
        case 1 % Log Scale
            set(get(handles.EM_Axes, 'XLabel'), 'String', 'Ln(grain size in \mu{m})', 'FontUnits', FUnits, 'FontSize', FontSize1)
            set(get(handles.EM_Axes, 'YLabel'), 'String', 'Fractional abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        case 2 % Log-Linear Scale
            set(handles.EM_Axes, 'XScale', 'Log');
            set(get(handles.EM_Axes, 'XLabel'), 'String', 'Grain size [\mu{m}]', 'FontUnits', FUnits, 'FontSize', FontSize1)
            set(get(handles.EM_Axes, 'YLabel'), 'String', 'Fractional abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        case 3 % Phi scale
            set(get(handles.EM_Axes, 'XLabel'), 'String', '\phi', 'FontUnits', FUnits, 'FontSize', FontSize1)
            set(get(handles.EM_Axes, 'YLabel'), 'String', 'Fractional abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
    end
    
    set(get(handles.EM_Axes, 'Title'), 'String', 'End Members', 'FontUnits', FUnits, 'FontSize', FontSize2);
    set(handles.EM_Axes, 'Box', 'on')
    
end


% Reset the button down functions
set(handles.PDF_Axes, 'ButtonDownFcn', {@PDF_Axes_ButtonDownFcn, handles});
set(handles.EM_Axes, 'ButtonDownFcn', {@EM_Axes_ButtonDownFcn, handles});



% --- Executes when selected cell(s) is changed in Data_Table.
function Data_Table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Data_Table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Get the list of currently selected table cells
sel = eventdata.Indices;

if ~isempty(sel) == 1 % The user is selecting a data row
    selrow = sel(1,1);
    
    handles.spec_ind = selrow;
    set(handles.Spec_Num, 'String', handles.All_Names{handles.spec_ind}); % set the index
    guidata(hObject, handles);
    
    % Readjust table position to keep in frame
    try
        jscrollpane = javaObjectEDT(findjobj(handles.Data_Table));
        viewport    = javaObjectEDT(jscrollpane.getViewport);
        P = viewport.getViewPosition();
        obj_fail = 0;  % flag to indicate if findjobj failed or not
    catch
        % findjobj not avaiable so resort to default behaviour
        obj_fail = 1;
    end
    
    func_handles=Set_Current_Data(handles);
    handles=func_handles;
    guidata(hObject, handles);
    
    % Restore the table position
    if obj_fail == 0
        drawnow()
        viewport.setViewPosition(P);
    end
    
end


% --- Executes when selected cell(s) is changed in Fit_Table.
function Fit_Table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Fit_Table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Get the list of currently selected table cells
sel = eventdata.Indices;

try any(sel(1,:));
    
    if any(sel(1,:)) == 1 % The user is selecting a data row
        selrow = sel(1,1);
        
        handles.Fit_Data_Ind = selrow;
        guidata(hObject, handles);
        
        func_handles=Set_Current_Fit(handles);
        handles=func_handles;
        guidata(hObject, handles);
        
    end
    
catch
    return
end


% --- Executes on button press in Load_Data.
function Load_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path]=uigetfile({'*.dat;*.$ls;*.mes;*.xls;*.xlsx', 'Supported files (*.dat;*.$ls;*.mes;*.xls;*.xlxs)';...
    '*.*', 'All Files (*.*)'},...
    'Please select your data file(s).', 'MultiSelect', 'on');

if iscell(file) == 0 & file == 0  %#ok<AND2>
    % User cancelled the open dialog box - Do nothing
    handles.Data_Loaded = 0;
    guidata(hObject, handles);
    
elseif size(file,2) ~=0 % load and process
    
    % Get the file extension
    if iscell(file)
        split_name=regexp(file{1,1}, '\.', 'split');
        nFiles=size(file,2);
    else
        split_name=regexp(file, '\.', 'split');
        nFiles=1;
    end
    
    file_ext=split_name{end};
    
    
    % Load the different file types
    if strcmpi(file_ext, 'xls') || strcmpi(file_ext, 'xlsx')
        % Excel file
        handles.File_Type_Flag='Excel';
        
        [status,sheets] = xlsfinfo(strcat(path, file));
        
        if strcmpi(file_ext, 'xls') && strcmpi(handles.OS, 'Mac')
            warndlg({'Older xls files are not fully supported in OS X.';...
                'Please save the file as xlsx or in text format'}, '*.xls not supported')
            return
        end
        
        Load_Options_XL('Main_Window_Call', handles.AnalySize_MW, sheets);
        
        if ~isempty( getappdata(handles.AnalySize_MW, 'Abort_Cancel') )
            % the user canceled or close the window
            % remove the flag and simply return, noting no data loaded
            rmappdata(handles.AnalySize_MW, 'Abort_Cancel')
            handles.Data_Loaded = 0;
            guidata(hObject, handles);
            return
        end
        
        % Retrive the updated values then remove them
        type_data = getappdata(handles.AnalySize_MW, 'Type_Data');
        guidata(hObject, handles);
        
        rmappdata(handles.AnalySize_MW, 'Type_Data');
        
    elseif strcmpi(file_ext, 'dat') || strcmpi(file_ext, '$ls') || strcmpi(file_ext, 'ls')...
            || strcmpi(file_ext, 'csv') || strcmpi(file_ext, 'mes')
        
        Load_Options('Main_Window_Call', handles.AnalySize_MW);
        
        if ~isempty( getappdata(handles.AnalySize_MW, 'Abort_Cancel') )
            % the user canceled or close the window
            % remove the flag and simply return, noting no data loaded
            rmappdata(handles.AnalySize_MW, 'Abort_Cancel')
            return
        end
        
        % Retrive the updated values then remove them
        handles.File_Delimiter = getappdata(handles.AnalySize_MW, 'File_Delimiter');
        handles.File_Type_Flag = getappdata(handles.AnalySize_MW, 'File_Type_Flag');
        handles.Multi_Spec_Flag = getappdata(handles.AnalySize_MW, 'Multi_Spec_Flag');
        guidata(hObject, handles);
        
        rmappdata(handles.AnalySize_MW, 'File_Delimiter');
        rmappdata(handles.AnalySize_MW, 'File_Type_Flag');
        rmappdata(handles.AnalySize_MW, 'Multi_Spec_Flag');
        
        type_data={handles.File_Delimiter, handles.Multi_Spec_Flag};
        
    else
        % Unsupported file type - Warn and return
        MSG = [{'This file type is not currently supported.'}, ...
            {'If it is a valid data file and you would like it added please conatct the developer.'}....
            {'In the meantime use either *.dat or Excel files'}];
        
        warndlg(MSG, 'Unrecognized file type', 'modal');
        %         handles.Data_Loaded = 0;
        guidata(hObject, handles);
        return
    end
    
    
    % Common input to all file formats
    file_data=[{handles.File_Type_Flag}, {nFiles}];
    
    [Sample_Names, Grain_Size, Data]=Read_Data_Files(path, file, file_data, type_data);
    
    % Check that all the grain size bins are consistent
    unique_lengths = length(unique(cellfun(@length, Grain_Size)));
    
    if unique_lengths ~= 1
        warndlg('Number of grain size bins are inconsistent. Please check the data.', 'Data Error!', 'modal');
        return;
    end
    
    GS = cell2mat(Grain_Size);
    LGS = log(GS);
    
    % Check unique grain size bins and try rounding to obtain consistent bins
    if length(unique(GS)) ~= size(GS, 1)
        % The length is inconsistent
        
        % Try rounding
        nGS = round(GS.*1e3)./1e3;
        
        
        if length(unique(nGS)) == size(GS, 1)
            % Sizes are now consistent, but tell the user
            warndlg('Grain size bins have been rounded to 3 d.p. for consisitency.', 'Rounded Grain Sizes', 'modal');
        else
            % The length is still inconsistent
            
            % Try rounding in logspace
            nGS = exp(round(LGS.*1e2)./1e2);
            
            if length(unique(nGS)) == size(GS, 1)
                warndlg('Grain size bins have been rounded to 2 d.p. in log space for consisitency.', 'Rounded Grain Sizes', 'modal');
            else
                % Still inconsistent
                % Throw a warning and do not open the data
                warndlg('Grain size bins are inconsistent. Please check the data.', 'Data Error!', 'modal');
                return;
            end
            
        end
        
        % Assign the new GS to GS
        GS = nGS;
        Grain_Size = mat2cell(GS, size(GS,1), ones(1,nFiles)); % update the grain size cell

    end
    
    % Check and remove zeros from the grain sizes
    inds = (GS(:,1) == 0);
    Data = cellfun(@(x) x(~inds), Data, 'UniformOutput', 0);
    Grain_Size = cellfun(@(x) x(~inds), Grain_Size, 'UniformOutput', 0);
        
    % Set the data to the handles
    handles.All_Names=Sample_Names;
    handles.All_Data=Data;
    handles.All_GS=Grain_Size;
    handles.All_LGS=cellfun(@log, Grain_Size, 'UniformOutput', 0);
    handles.All_Phi = cellfun(@(x) -log2(x./1e3), handles.All_GS, 'Uniformoutput', 0);
    
    handles.spec_ind=1; % Set the specimen index to 1
    handles.nVar=length(Data{1}); % Get the number of variables
    handles.Nspec=length(Data); % Get the number of specimens
    set(handles.Spec_Num, 'String', handles.All_Names{handles.spec_ind}); % set the index
    
    
    % Reset the fits and tables
    func_handles = SetDefaultHandles(handles, 'All');
    handles = func_handles;
    
    handles.Data_Loaded = 1;
    
    % Set and plot the current data
    func_handles=Set_Current_Data(handles);
    handles=func_handles;
    
    % Set the data table info
    set(handles.Data_Table, 'Data', handles.All_Names, 'ColumnName', handles.Table_Cols);
    
    % save the updated handles
    guidata(hObject, handles);
    
end


% --- Executes on button press in Load_Test_Data.
function Load_Test_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Test_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% THIS IS NOT A PRIMARY FUNCTION AND IS DESIGNED FOR TESTING ONLY
% THIS SHOULD NOT BE ENABLED

% choice = menu('Select Test Data', 'Synthetic 1 (50x80, 3 EMs)', 'Real 1 (188x100)', 'Real 2 (1138x100)',...
%     'Real 3 (157x116)', 'Real 4 (151x56)', 'Toy 1 (49x80, 2 EMs)', 'Toy 2 (99x80, 2 EMs)', ...
%     'Weltje I (200x45)', 'Weltje II (200x45)', 'Weltje III (200x45)');
%
%
% S = mfilename('fullpath');
% name_len = length(mfilename());
% MyPath = S(1:end-name_len);
%
%
% switch choice
%     case 1
%         load(strcat(MyPath, 'Test_Data/Synth_Data.mat'));
%     case 2
%         load(strcat(MyPath, 'Test_Data/Data_Trimmed.mat'));
%     case 3
%         load(strcat(MyPath, 'Test_Data/Data.mat'));
%     case 4
%         load(strcat(MyPath, 'Test_Data/Real3.mat'));
%     case 5
%         load(strcat(MyPath, 'Test_Data/Real4.mat'));
%     case 6
%         load(strcat(MyPath, 'Test_Data/Toy1.mat'));
%     case 7
%         load(strcat(MyPath, 'Test_Data/Toy2.mat'));
%     case 8
%         load(strcat(MyPath, 'Test_Data/Weltje_I.mat'));
%     case 9
%         load(strcat(MyPath, 'Test_Data/Weltje_II.mat'));
%     case 10
%         load(strcat(MyPath, 'Test_Data/Weltje_III.mat'));
%
%     otherwise
%         % Do nothing
%         return
% end
%
% % Normalize the data
% Data=bsxfun(@rdivide, Data,sum(Data, 2));
%
% handles.spec_ind=1; % Set the specimen index to 1
% handles.Nspec=size(Data, 1); % Get the number of specimens
% handles.nVar=size(Data, 2); % Get the number of variables
%
% % Reset the fits and tables
% func_handles = SetDefaultHandles(handles, 'All');
% handles = func_handles;
%
% handles.Data_Loaded = 1;
%
% handles.All_Names = cellstr(strcat('Spec', num2str((1:handles.Nspec)')));
% handles.All_Data = num2cell(Data,2);
% handles.All_GS = num2cell(repmat(GS, 1, handles.Nspec), 1);
% handles.All_LGS = num2cell(repmat(log(GS), 1, handles.Nspec), 1);
% handles.All_Phi = cellfun(@(x) -log2(x./1e3), handles.All_GS, 'Uniformoutput', 0);
%
% set(handles.Spec_Num, 'String', handles.All_Names{handles.spec_ind}); % set the index
%
% % Set the data table info
% set(handles.Data_Table, 'Data', handles.All_Names, 'ColumnName', handles.Table_Cols);
%
% % Set and plot the current data
% func_handles=Set_Current_Data(handles);
% handles=func_handles;
%
% % save the updated handles
guidata(hObject, handles);


% --- Executes on button press in either Next_Spec or Prev_Spec.
function Prev_Next_Spec_Callback(hObject, eventdata, handles, str)
% hObject    handle to Next_Sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Get the index pointer and the addresses
    index = handles.spec_ind;
    Nspec = handles.Nspec;
catch
    return;
end

% Depending on whether Prev or Next was clicked change the display
switch str
    case 'Prev'
        % Decrease the index by one
        ind = index - 1;
        % If the index is less then one then set it the number of specimens
        % (Nspec)
        if ind < 1
            ind = Nspec;
        end
    case 'Next'
        % Increase the index by one
        ind = index + 1;
        
        % If the index is greater than the snumber of specimens set index
        % to 1
        if ind > Nspec
            ind = 1;
        end
end

handles.spec_ind=ind;
set(handles.Spec_Num, 'String', handles.All_Names{handles.spec_ind});

guidata(hObject,handles);

func_handles=Set_Current_Data(handles);
handles=func_handles;

guidata(hObject,handles);


% --- Executes on selection change in Plot_Type.
function Plot_Type_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Plot_Type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Plot_Type

try
    handles.All_Data;
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return;
end


Update_Plots(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Plot_Type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Plot_Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Do_EMA.
function Do_EMA_Callback(hObject, eventdata, handles)
% hObject    handle to Do_EMA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Send the data to the maui GUI figure
    setappdata(handles.AnalySize_MW, 'Data_To_Fit', cell2mat(handles.All_Data) );
    setappdata(handles.AnalySize_MW, 'Size', handles.All_GS{1});
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return
end

% Check that a bare minimum of 10 data are loaded - this is a bare minimum!
if handles.Nspec < 10
    MSG = [{'Not enough data are currently loaded.'},...
        {'At least 10 specimens are needed to try EMA, but 30 or more are recommended for robust results'}];
    warndlg(MSG, 'Not Enough Data', 'modal')
    return
end

% Load the fit options
Fit_Opt_Return = Fit_Options('Main_Window_Call', handles.AnalySize_MW, handles.Sel_EM_Data);

if Fit_Opt_Return.FitStatus == 1
    
    % Set the handle fit status
    handles.FitStatus = Fit_Opt_Return.FitStatus;
    handles.Plot_Fits_Flag = 1; % Set the plot fit flag
    
    % Process the fit data
    handles.All_Fit_EMs = [handles.All_Fit_EMs, {Fit_Opt_Return.EndMembers}];
    handles.All_Fit_Abunds = [handles.All_Fit_Abunds, {Fit_Opt_Return.Abundances}];
    
    handles.All_Fit_N = handles.All_Fit_N + 1; % Add 1 to the counter for the number of saved fits
    handles.Fit_Data_Ind = handles.All_Fit_N;% set the fit data index to move to the current fit
    
    handles.All_DataSet_QFit = [handles.All_DataSet_QFit, Fit_Opt_Return.Fit_Quality(1)];
    handles.All_Specimen_QFit = [handles.All_Specimen_QFit, Fit_Opt_Return.Fit_Quality(2)];
    
    handles.All_Fit_Types = [handles.All_Fit_Types, {char(Fit_Opt_Return.Fit_Type)}];
    
    
    if isfield(Fit_Opt_Return, 'Dist_Params')
        handles.All_Fit_Params = [handles.All_Fit_Params, {Fit_Opt_Return.Dist_Params}];
        
        % Save the data for the select EM plots
        switch char(Fit_Opt_Return.Fit_Type)
            case 'Lognormal'
                ind = 1;
            case 'Gen. Weibull'
                ind = 2;
            case 'Weibull'
                ind = 3;
            case 'SGG'
                ind = 4;
            case 'GEV'
                ind = 5;
        end
        
        OW_Flag = 1; % A flag to determine whether to overwrit or not
        
        if isstruct(handles.Sel_EM_Data{ind})
            % Some data already exist
            Fit_Type = char(Fit_Opt_Return.Fit_Type);
            Old_Data = handles.Sel_EM_Data{ind};
            New_Data = Fit_Opt_Return.SelectEM_Data;
            
            EM1o = Old_Data.EM_Min;
            EM2o = Old_Data.EM_Max;
            
            EM1n = New_Data.EM_Min;
            EM2n = New_Data.EM_Max;
            
            MSG = [ {['Variance for ', Fit_Type, ' fits with ', num2str(EM1o), ' to ', num2str(EM2o), ' end members is already saved.']},...
                {['The new ', Fit_Type, ' data haves ', num2str(EM1n), ' to ', num2str(EM2n), ' end members.']},...
                {'Do you wish to keep the existing data, overwrite it, or append the data sets (duplicates will be overwritten)?'} ];
            
            choice = questdlg(MSG, 'Overwrite end member variance data?', 'Keep Exisiting', 'Overwrite', 'Append', 'Append');
            
            switch choice
                case 'Append'
                    OW_Flag = 2;
                case 'Keep Exisiting'
                    OW_Flag = 3;
            end
            
            
        end
        
        if OW_Flag == 1 % Overwrite
            handles.Sel_EM_Data(ind) = {Fit_Opt_Return.SelectEM_Data};
        elseif OW_Flag == 2 % Append with overwriting duplicates
            handles.Sel_EM_Data(ind) = {Append_EM_Vars(handles.Sel_EM_Data{ind}, Fit_Opt_Return.SelectEM_Data)};
        end
        % else do nothing and keep the exisiting data
        
    else
        handles.All_Fit_Params = [handles.All_Fit_Params, {[]}];
    end
    
    
    % Set the current fit data
    func_handles = Set_Current_Fit(handles);
    handles = func_handles;
    
    % Get the 95th percentiles for R^2 and theta
    nData = handles.Nspec;
    R2_95 = GetPercentile([0,diff(0:nData-1)], sort(handles.Specimen_QFit(:,1), 'descend')', 95);
    Theta_95 = GetPercentile([0,diff(0:nData-1)], sort(handles.Specimen_QFit(:,2), 'descend')', 5);
    
    % Set the table data
    handles.Fit_Table_Data = [handles.Fit_Table_Data;...
        {handles.Current_Fit_Type}, {handles.nEnd}, {handles.DataSet_QFit(3)}, {handles.DataSet_QFit(1)}, {handles.DataSet_QFit(2)},...
        {R2_95}, {Theta_95}];
    
    set(handles.Fit_Table, 'Data', handles.Fit_Table_Data);
    
    guidata(hObject, handles);
    
end % else do nothing (keep the old plots and fit)

guidata(hObject, handles);


% --- Executes on button press in Save_Data_Plot.
function Save_Data_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Data_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    handles.All_Data;
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return;
end


[file,path] = uiputfile(strcat(handles.All_Names{handles.spec_ind}, '.eps'),'Save the specimen plot...');

if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end


tmpFig=figure('Visible', 'off', 'Units', 'Centimeters','PaperPositionMode','auto');
oldPos=get(tmpFig, 'Position');
set(tmpFig, 'Position', [oldPos(1), oldPos(2), 9, 7.5]); % make the figure bigger than needed (300x300)

% Copy and adjust the axes
newAxes=copyobj(handles.PDF_Axes, tmpFig);
set(newAxes, 'Units', 'Centimeters');
axis(newAxes, 'square');
set(newAxes, 'FontUnits', 'Points', 'FontSize', 9)
set(get(newAxes, 'XLabel'), 'FontUnits', 'Points', 'FontSize', 10)
set(get(newAxes, 'YLabel'), 'FontUnits', 'Points', 'FontSize', 10);
set(get(newAxes, 'Title'), 'FontUnits', 'Points', 'FontSize', 11);
set(get(newAxes, 'Title'), 'String', handles.All_Names{handles.spec_ind});

% Readjust the x-axis scale and tickmarks
set(newAxes, 'Xlim', get(handles.PDF_Axes, 'Xlim'))
set(newAxes, 'XTick', get(handles.PDF_Axes, 'XTick'))
set(newAxes, 'XTickLabel', get(handles.PDF_Axes, 'XTickLabel'))


% Do the legend
Legend_String = {'Data'};

if handles.FitStatus == 1
    % we have fits
    Legend_String{2} = 'Total Fit';
    
    nFits = handles.nEnd;
    
    % Add the appropriate parts to the legend string
    for ii = 1: nFits
        Legend_String{ii+2} = strcat('EM ', sprintf(' %d', ii) );
    end
    
end

% Do a MATLAB version check
if handles.Version <= 8.3 % 2014a and before
    % Set the legend and adjust it's properties
    hleg = legend(Legend_String, 'Location', 'NorthEastOutside', 'Box', 'off', 'FontUnits', 'Points', 'FontSize', 8);
    legend(hleg, 'boxon', 'XColor', 'white', 'YColor', 'white', 'color', 'white');
    
    LegLines = findobj(hleg, 'type','line');
    XD = get(LegLines(2),'XData');
    LineLen = (2/3) * (XD(2) - XD(1));
    MidPoint = (1/2) * (XD(2) - XD(1));
    
    set(LegLines(2:2:end),'XData', [XD(1), XD(1) + LineLen]);
    set(LegLines,'MarkerSize', 5);
    set(LegLines(1:2:end),'XData', MidPoint);
    
    LegText = findobj(hleg, 'type','text');
    try % if we have fits then a cell
        PosData = cell2mat(get(LegText, 'Position'));
    catch %#ok<CTCH> % otherwise an array
        PosData = get(LegText, 'Position');
    end
    
    Short = (XD(2) - XD(1)) - LineLen;
    for ii = 1:size(PosData,1)
        PD = PosData(ii,:);
        PD(1) = PD(1) - Short;
        set(LegText(ii), 'Position', PD);
    end
    
else % 2014b and later
    
    % Adjust the symbol for the plot - trys deals with the bug
%     Mk = get(newAxes.Children, 'Marker');
%     %     set(newAxes.Children(strcmpi(Mk, 'o')==1), 'MarkerSize', 20);
%     set(newAxes.Children(strcmpi(Mk, 'o')==1), 'Marker', 's');
    
    % Set the legend and adjust it's properties
    hleg1 = legend(Legend_String, 'Location', 'NorthEastOutside', 'Box', 'on', 'FontUnits', 'Points', 'FontSize', 8);
    set(hleg1, 'Color', 'white', 'EdgeColor', 'white');
    
end

% Reset to the desired size
NewPos = [1.5, 1.5, 4.5, 4.5];
set(newAxes, 'Position', NewPos, 'XColor', [1,1,1], 'YColor', [1,1,1], 'Box', 'off', 'TickDir', 'Out');

% Place a new set of axes on top to create the box
h0 = axes('Units', 'Centimeters', 'Position', NewPos);
set(h0, 'box', 'on', 'XTick', [], 'YTick', [], 'color', 'none');


print(tmpFig, '-depsc', strcat(path, file));
close(tmpFig);


% --- Executes on button press in Save_EM_Plot.
function Save_EM_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Save_EM_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.FitStatus == 0
    % No fits
    return;
else
    
    [file,path] = uiputfile(strcat('End_Members.eps'),'Save the end member plot...');
    
    if ~ischar(file) && file==0
        % User has cancelled
        % Do nothing and...
        return;
    end
    
    
    tmpFig=figure('Visible', 'off', 'Units', 'Centimeters','PaperPositionMode','auto');
    oldPos=get(tmpFig, 'Position');
    set(tmpFig, 'Position', [oldPos(1), oldPos(2), 9, 7.5]); % make the figure bigger than needed (300x300)
    
    % Copy and adjust the axes
    newAxes=copyobj(handles.EM_Axes, tmpFig);
    set(newAxes, 'Units', 'Centimeters');
    axis(newAxes, 'square');
    set(newAxes, 'FontUnits', 'Points', 'FontSize', 9)
    set(get(newAxes, 'XLabel'), 'FontUnits', 'Points', 'FontSize', 10)
    set(get(newAxes, 'YLabel'), 'FontUnits', 'Points', 'FontSize', 10);
    set(get(newAxes, 'Title'), 'FontUnits', 'Points', 'FontSize', 11);
    
    % Readjust the x-axis scale and tickmarks
    set(newAxes, 'Xlim', get(handles.PDF_Axes, 'Xlim'))
    set(newAxes, 'XTick', get(handles.PDF_Axes, 'XTick'))
    set(newAxes, 'XTickLabel', get(handles.PDF_Axes, 'XTickLabel'))
    
    
    % Reset the line widths
    C = get(newAxes, 'Children');
    for ii = 1: length(C);
        set(C(ii),'LineWidth',1);
    end
    
    
    % Do the legends
    nFits = handles.nEnd;
    
    % Add the appropriate parts to the legend string
    Legend_String = cell(1,nFits);
    for ii = 1: nFits
        Legend_String{ii} = strcat('EM ', sprintf(' %d', ii) );
    end
    
    % Do a MATLAB version check
    if handles.Version <= 8.3 % 2014a and before
        % Set the legend and adjust it's properties
        hleg = legend(Legend_String, 'Location', 'NorthEastOutside', 'FontUnits', 'Points', 'FontSize', 8);
        legend(hleg, 'boxon', 'XColor', 'white', 'YColor', 'white', 'color', 'white');
        
        LegLines = findobj(hleg, 'type','line');
        XD = get(LegLines(2),'XData');
        LineLen = (2/3) * (XD(2) - XD(1));
        MidPoint = (1/2) * (XD(2) - XD(1));
        
        set(LegLines(2:2:end),'XData', [XD(1), XD(1) + LineLen]);
        set(LegLines,'MarkerSize', 5);
        set(LegLines(1:2:end),'XData', MidPoint);
        
        LegText = findobj(hleg, 'type','text');
        PosData = cell2mat(get(LegText, 'Position'));
        Short = (XD(2) - XD(1)) - LineLen;
        for ii = 1:size(PosData,1)
            PD = PosData(ii,:);
            PD(1) = PD(1) - Short;
            set(LegText(ii), 'Position', PD);
        end
        
    else % 2014b and later
        % Set the legend and adjust it's properties
        hleg1 = legend(Legend_String, 'Location', 'NorthEastOutside', 'Box', 'on', 'FontUnits', 'Points', 'FontSize', 8);
        set(hleg1, 'Color', 'white', 'EdgeColor', 'white');
    end
    
    % Reset to the desired size
    NewPos = [1.5, 1.5, 4.5, 4.5];
    set(newAxes, 'Position', NewPos, 'XColor', [1,1,1], 'YColor', [1,1,1], 'Box', 'off', 'TickDir', 'Out');
    
    % Place a new set of axes on top to create the box
    h0 = axes('Units', 'Centimeters', 'Position', NewPos);
    set(h0, 'box', 'on', 'XTick', [], 'YTick', [], 'color', 'none');
    
    print(tmpFig, '-depsc', strcat(path, file));
    close(tmpFig);
    
end


% --- Executes on button press in Export_EM_Data.
function Export_EM_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Export_EM_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.FitStatus == 0
    % No fits
    return;
else
    
    % Do the EMA files
    [EM_file,EM_path] = uiputfile('End_Member_Densities.dat','Export the end member data...');
    [A_file,A_path] = uiputfile('End_Member_Abundances.dat','Export the abundance data...');
    
    D_file = 0;
    if ~strcmpi(handles.Current_Fit_Type, 'Non-Parametric')
        [D_file,D_path] = uiputfile('End_Member_Distribution_Params.dat','Export the parameter data...');
    end
    
    if ~ischar(EM_file) && EM_file==0
        % User has cancelled the EM file
        EM_Out = 0;
    else
        EM_Out = 1;
    end
    
    if ~ischar(A_file) && A_file==0
        % User has cancelled the EM file
        A_Out = 0;
    else
        A_Out = 1;
    end
    
    if ~ischar(D_file) && D_file==0
        % User has cancelled the EM file
        D_Out = 0;
    else
        D_Out = 1;
    end
    
    if EM_Out == 0 && A_Out == 0 && D_Out == 0
        % User has cancelled everything, so do nothing and return
        return;
    end
    
    % Write the endmember file
    if EM_Out == 1
        
        EM_out_file = fopen(strcat(EM_path, EM_file), 'wt');
        
        % The format string for printing the data
        fmt = '%2.5f\t%2.5f\t%2.5f';
        Data_Out = [handles.Current_GS, handles.Current_LGS, handles.Current_Phi];
        
        fprintf(EM_out_file, '%s\t%s\t%s', 'Grain size', 'ln(Grain size)', 'Phi');
        
        Header = [{'Grain size'}, {'ln(Grain size)'}, {'Phi'}];
        
        % Get the EM Fits
        EM_Fits = 100.*handles.Current_Fit_EMs;
        
        nFits = handles.nEnd;
        
        for ii = 1: nFits
            fmt = strcat(fmt, '\t%2.5f');
            Data_Out(:,end+1) = EM_Fits(ii,:)';
            fprintf(EM_out_file, '\t%s', strcat('EM', sprintf('% d', ii)));
            Header = [Header, {strcat('EM', sprintf('% d', ii))}];
        end
        
        fprintf(EM_out_file, handles.Line_End);
        
        fmt = strcat(fmt, handles.Line_End);
        
        fprintf(EM_out_file, fmt, Data_Out');
        
        fclose(EM_out_file);
        
    end
    
    % Write the abundace file
    if A_Out == 1
        
        A_out_file = fopen(strcat(A_path, A_file), 'wt');
        
        % The format string for printing the data
        fmt = '%s\t%2.5f\t%2.5f';
        Data_Out = [handles.All_Names, num2cell(handles.Specimen_QFit)];
        
        fprintf(A_out_file, '%s\t%s\t%s', 'Specimen', 'R^2', 'Theta');
        
        nFits = handles.nEnd;
        
        for ii = 1: nFits
            fmt = strcat(fmt, '\t%2.5f');
            Data_Out(:,end+1) = num2cell(100.*handles.Current_Fit_Abunds(:,ii)); %#ok<AGROW>
            fprintf(A_out_file, '\t%s', strcat('EM', sprintf('% d', ii)));
        end
        
        fprintf(A_out_file, handles.Line_End);
        
        fmt = strcat(fmt, handles.Line_End);
        
        Data_Out = Data_Out';
        
        fprintf(A_out_file, fmt, Data_Out{:});
        
        fclose(A_out_file);
        
    end
    
    % Write the distribution paramter file
    if D_Out == 1
        
        D_out_file = fopen(strcat(D_path, D_file), 'wt');
        
        Params = handles.Current_Fit_Params;
        [nFits, nParams] = size(Params);
        
        % Write the Header line
        fprintf(D_out_file, '%s', handles.Current_Fit_Type);
        for ii =1 :nParams
            fprintf(D_out_file, '\t%s', strcat('Param', sprintf('% d', ii)));
        end
        fprintf(D_out_file, handles.Line_End);
        
        Data_Out = cell(nFits, 1);
        fmt = '';
        for ii = 1:nFits
            Data_Out(ii) = {strcat('EM', sprintf('% d', ii) ) };
            fmt = strcat(fmt, '%s', repmat('\t%f', 1, nParams-1), strcat('\t%f', handles.Line_End) );
        end
        
        Data_Out = [Data_Out, num2cell(Params)];
        Data_Out = Data_Out';
        
        fprintf(D_out_file, fmt, Data_Out{:});
        
        fclose(D_out_file);
        
    end
    
end


% --- Executes on button press in Export_Plot_Data.
function Export_Plot_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Plot_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    Data_Out = [handles.Current_GS, handles.Current_LGS, handles.Current_Phi, 100.*handles.Current_Data'];
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return;
end

[file,path] = uiputfile(strcat(handles.All_Names{handles.spec_ind}, '_Data.dat'),'Save the plot data...');


if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end

fout = fopen(strcat(path, file), 'wt');

% The format string for printing the data
fmt = '%2.5f\t%2.5f\t%2.5f\t%2.5f';

fprintf(fout, '%s\t%s\t%s\t%s', 'Grain size', 'ln(Grain size)', 'Phi', 'Data');

if handles.FitStatus == 1
    
    % Get the EM Fits
    EM_Fits = 100.*handles.Current_Fit_EMs;
    
    % Add the total fit
    fmt = strcat(fmt, '\t%2.5f');
    Data_Out = [Data_Out, 100.*handles.Current_Fit_PDFs'];
    
    fprintf(fout, '\t%s', 'Total Fit');
    
    nFits = handles.nEnd;
    
    for ii = 1: nFits
        fmt = strcat(fmt, '\t%2.5f');
        Data_Out(:,end+1) = EM_Fits(ii,:)'; %#ok<AGROW>
        fprintf(fout, '\t%s', strcat('EM', sprintf('% d', ii)));
    end
    
end

fprintf(fout, handles.Line_End);

fmt = strcat(fmt, handles.Line_End);

fprintf(fout, fmt, Data_Out');

fclose(fout);


% --- Executes on button press in Export_All_Data.
function Export_All_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Export_All_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    Data = [handles.All_GS{1}, 100.*cell2mat(handles.All_Data)'];
    Header = [{'Grain Size'}, handles.All_Names'];
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return;
end

[file,path] = uiputfile('All_Data.dat','Save all data...');

if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end

Dfmt = [repmat('%f\t', 1, size(Data,2)-1), strcat('%f', handles.Line_End)];
Hfmt = [repmat('%s\t', 1, size(Data,2)-1), strcat('%s', handles.Line_End)];

FID = fopen(strcat(path, file), 'wt');

fprintf(FID, Hfmt, Header{:});
fprintf(FID, Dfmt, Data');

fclose(FID);


% --- Executes on button press in PB_debug.
function PB_debug_Callback(hObject, eventdata, handles)
% hObject    handle to PB_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% THIS IS NOT A PRIMARY FUNCTION AND IS DESIGNED FOR TESTING ONLY
% THIS SHOULD NOT BE ENABLED

disp('Entering debug mode. Type "return" to exit.')
keyboard


function func_handles = SetDefaultHandles(handles, StrIn)
% Reset the plots and flags to default behavior


switch StrIn
    
    case 'All'
        
        FUnits = 'Pixels';
        FontSize1 = 12; % 10pt font
        FontSize2 = 14; % 14pt font
        
        % Set the default plot axes and titles
        % PDF plot
        set(get(handles.PDF_Axes, 'XLabel'), 'String', 'Grain size [\mu{m}]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.PDF_Axes, 'YLabel'), 'String', 'Fractional abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.PDF_Axes, 'Title'), 'String', 'Specimen Density Plot', 'FontUnits', FUnits, 'FontSize', FontSize2);
        set(handles.PDF_Axes, 'ColorOrder', handles.Default_Plot_Colors);
        
        % EM plot
        set(get(handles.EM_Axes, 'XLabel'), 'String', 'Grain size [\mu{m}]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.EM_Axes, 'YLabel'), 'String', 'Fractional abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.EM_Axes, 'Title'), 'String', 'End Member Plot', 'FontUnits', FUnits, 'FontSize', FontSize2);
        set(handles.EM_Axes, 'ColorOrder', handles.Default_Plot_Colors);
        
        % Set the default flags
        handles.Data_Loaded = 0;
        handles.Table_Cols = {'Specimen', 'R^2', 'Theta'};
        
        handles.Plot_Fits_Flag = 0;
        handles.FitStatus = 0;
        
        handles.All_Fit_Types = [];
        handles.All_Fit_EMs = [];
        handles.All_Fit_Abunds = [];
        handles.All_Fit_Params = [];
        handles.Fit_Table_Data = [];
        handles.All_DataSet_QFit = [];
        handles.All_Specimen_QFit = [];
        handles.All_Fit_N = 0;
        handles.Fit_Data_Ind = 0;
        handles.Sel_EM_Data = cell(5,1);
        
        handles.Current_Fit_Type = [];
        handles.Current_Fit_EMs = [];
        handles.Current_Fit_Abunds = [];
        handles.Current_Fit_Params = [];
        handles.Current_Fit_PDFs = [];
        handles.Current_Specimen_Fit = [];
        handles.nEnd = [];
        handles.DataSet_QFit = [];
        handles.Specimen_QFit = [];
        
        % Reset the tables
        set(handles.Data_Table, 'Data', []);
        set(handles.Fit_Table, 'Data', []);
        
    case 'Fits'
        % Set the default flags
        handles.Table_Cols = {'Specimen', 'R^2', 'Theta'};
        
        handles.Plot_Fits_Flag = 0;
        handles.FitStatus = 0;
        
        handles.All_Fit_Types = [];
        handles.All_Fit_EMs = [];
        handles.All_Fit_Abunds = [];
        handles.All_Fit_Params = [];
        handles.Fit_Table_Data = [];
        handles.All_DataSet_QFit = [];
        handles.All_Specimen_QFit = [];
        handles.All_Fit_N = 0;
        handles.Fit_Data_Ind = 0;
        handles.Sel_EM_Data = cell(5,1);
        
        handles.Current_Fit_Type = [];
        handles.Current_Fit_EMs = [];
        handles.Current_Fit_Abunds = [];
        handles.Current_Fit_Params = [];
        handles.Current_Fit_PDFs = [];
        handles.Current_Specimen_Fit =[];
        handles.nEnd = [];
        handles.DataSet_QFit = [];
        handles.Specimen_QFit = [];
        
        % Reset the tables
        set(handles.Fit_Table, 'Data', []);
        set(handles.Data_Table, 'Data', handles.All_Names, 'ColumnName', handles.Table_Cols);
        
        
    otherwise
        % Do nothing, but maybe add an error in later versions
        disp('While setting defaults you should not be here!!')
        
end

func_handles = handles;


%% The Menu bar functions

% --------------------------------------------------------------------
function MB_Save_Session_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Save_Session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.Data_Loaded == 0
    % No data loaded so do nothing
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return;
end

SaveSession(handles);

% --------------------------------------------------------------------
function MB_Load_Session_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Load_Session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load the saved session

[file,path] = uigetfile('*.mat','Load a saved session...');

if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end


% try loading the file
load(strcat(path, file), 'Session_handles');

% Check to see if load threw any warning about missing variables
if strcmpi(lastwarn, 'Variable ''Session_handles'' not found.')
    % Warn about invalid mat files and return
    warndlg('This is not a valid session file. Please try another.', 'Invalid files');
    return;
end


handles = LoadSession(handles, Session_handles);


% Update the data, fits, and plots
handles = Set_Current_Data(handles);
handles = Set_Current_Fit(handles);

% Set the the specimen browser label
set(handles.Spec_Num, 'String', handles.All_Names{handles.spec_ind});

% Set the fit tables
set(handles.Fit_Table, 'Data', handles.Fit_Table_Data);

% save the updated handles
guidata(hObject, handles);


% --------------------------------------------------------------------
function MSpec_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to MSpec_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    Transfer.Data = cell2mat(handles.All_Data);
    Transfer.GS = handles.All_GS{1};
    Transfer.Phi = handles.All_Phi{1};
    Transfer.Names = handles.All_Names;
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return;
end

Spectra_Plot('DataTransfer', Transfer, handles.AnalySize_MW);


% --------------------------------------------------------------------
function Cum_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Cum_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


try
    Transfer.Data = cell2mat(handles.All_Data);
    Transfer.GS = handles.All_GS{1};
    Transfer.Phi = handles.All_Phi{1};
    Transfer.Names = handles.All_Names;
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return;
end

Cumulative_Plot('DataTransfer', Transfer, handles.AnalySize_MW);


% --------------------------------------------------------------------
function MB_Tern_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Tern_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    Transfer.Data = cell2mat(handles.All_Data);
    Transfer.Size = handles.All_GS{1};
    Transfer.Phi = handles.All_Phi{1};
    Transfer.Names = handles.All_Names;
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return;
end

Ternary_Plots('DataTransfer', Transfer, handles.AnalySize_MW);


% --------------------------------------------------------------------
function MB_DStats_Callback(hObject, eventdata, handles)
% hObject    handle to MB_DStats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    Transfer.Data = cell2mat(handles.All_Data);
    Transfer.GS = handles.All_GS{1};
    Transfer.Names = handles.All_Names;
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return;
end

Descriptive_Stats('DataTransfer', Transfer, handles.AnalySize_MW);


% --------------------------------------------------------------------
function MB_CM_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to MB_CM_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


try
    Transfer.Data = cell2mat(handles.All_Data);
    Transfer.GS = handles.All_GS{1};
    Transfer.Names = handles.All_Names;
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return;
end

CM_Plot('DataTransfer', Transfer, handles.AnalySize_MW);


% --------------------------------------------------------------------
function EM_Stats_Callback(hObject, eventdata, handles)
% hObject    handle to EM_Stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if handles.FitStatus ~=1
    warndlg('No end member fits currently loaded.', 'No EMs', 'modal')
    return;
end

try
    Transfer.Data = handles.Current_Fit_EMs;
    Transfer.GS = handles.All_GS{1};
    
    nFit = size(Transfer.Data, 1);
    
    Names = cell(nFit, 1);
    for ii = 1:nFit
        Names(ii) = {strcat('EM', sprintf('% d', ii))};
    end
    
    Transfer.Names = Names;
    
catch
    warndlg('Error finding end member fits.', 'No end members', 'modal')
    return;
end


Descriptive_Stats('DataTransfer', Transfer, handles.AnalySize_MW);


% --------------------------------------------------------------------
function MB_Set_EM_Colors_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Set_EM_Colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Return_Data = Set_EM_Colors(handles.Default_Plot_Colors, handles.AnalySize_MW);

if Return_Data.CancelFlag == 1
    return;
end

handles.Default_Plot_Colors = Return_Data.New_Colors;

if handles.FitStatus ~=0
    Update_Plots(handles);
end

guidata(hObject,handles);


% --------------------------------------------------------------------
function MB_Censor_Data_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Censor_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    Transfer.Data = handles.All_Data;
    Transfer.Size = handles.All_GS;
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return
end


Return_Data = Censor_Data('DataTransfer', Transfer, handles.AnalySize_MW);

if Return_Data.CancelFlag == 1
    % User canceled
    return;
end

% Set the new data to the handles
handles.All_Data = Return_Data.All_Data;
handles.All_GS = Return_Data.All_GS;
handles.All_LGS=  cellfun(@log, handles.All_GS, 'UniformOutput', 0);
handles.All_Phi = cellfun(@(x) -log2(x./1e3), handles.All_GS, 'Uniformoutput', 0);

handles.nVar = length(handles.All_Data{1}); % Get the number of variables


% Reset the fits
func_handles = SetDefaultHandles(handles, 'Fits');
handles = func_handles;

% Set and plot the current data
func_handles=Set_Current_Data(handles);
handles=func_handles;

guidata(hObject,handles);


% --------------------------------------------------------------------
function MB_Remove_Spec_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Remove_Spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    ind = handles.spec_ind;
    Name = handles.All_Names{ind};
catch
    warndlg('No data currently loaded.', 'No Data', 'modal')
    return
end

Msg = [ {['Are you sure you want to remove ', Name, '?']}, {'This may invalidate some fits.'}];

choice = questdlg(Msg, 'Remove Specimen?', 'Cancel', 'OK', 'Cancel');

if ~strcmp(choice, 'OK')
    % User canceled
    return;
end

% Remove the specimen data, grain sizes, and name
handles.All_Data(ind)=[];
handles.All_GS(ind) = [];
handles.All_Names(ind) = [];

% Remove specimen fit data
if handles.FitStatus == 1
    
    handles.Current_Fit_Abunds(ind,:) = [];
    handles.Specimen_QFit(ind,:) = [];
    
    % Remove data from the handles.All_Fit_* variables
    nFits = size(handles.All_Fit_Types,2);
    
    for ii = 1:nFits
        handles.All_Fit_Abunds{ii}(ind,:)=[];
        handles.All_Specimen_QFit{ii}(ind,:)=[];
    end
    
    % Check for SSU fits, which need to have
    SSU_Inds = find(cellfun(@(x) strcmp(x(1:3), 'SSU'), handles.All_Fit_Types)==1);
    nSSU = length(SSU_Inds);
    
    for ii = 1:nSSU
        handles.All_Fit_EMs{SSU_Inds(ii)}(ind,:)=[];
        handles.All_Fit_Params{SSU_Inds(ii)}(ind,:)=[];
    end
    
end


% Check the specimen index is still in range
handles.Nspec = length(handles.All_Data);
if ind > handles.Nspec
    handles.spec_ind = handles.Nspec;
    set(handles.Spec_Num, 'String', handles.All_Names{handles.spec_ind}); % set the index
end

% Update the other grain size handles
handles.All_LGS(ind) = [];
handles.All_Phi(ind) = [];

% Set and plot the current data
func_handles=Set_Current_Data(handles);
handles=func_handles;

% Set the data table info
set(handles.Data_Table, 'Data', handles.All_Names, 'ColumnName', handles.Table_Cols);

% save the updated handles
guidata(hObject, handles);


% --------------------------------------------------------------------
function MB_Open_Manual_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Open_Manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the current path of the main m-file
S = mfilename('fullpath');
name_len = length(mfilename());
MyPath = S(1:end-name_len);

file_name = strcat('AnalySize_Manual_v', handles.AnalySize_Version, '.pdf');
file_path = strcat(MyPath, 'Documents/', file_name);

try
    open(file_path);
catch
    warndlg([file_name, ' not found.'], 'Manual Not Found');
end

% --------------------------------------------------------------------
function MB_Open_Paper_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Open_Paper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the current path of the main m-file
S = mfilename('fullpath');
name_len = length(mfilename());
MyPath = S(1:end-name_len);

file_name = 'Paterson & Heslop, 2015, New methods for unmixing sediment grain size data.pdf';
file_path = strcat(MyPath, 'Documents/', file_name);

try
    open(file_path);
catch
    warndlg([file_name, ' not found.'], 'Paper Not Found');
end

% --------------------------------------------------------------------
function MB_About_AnalySize_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

About_AnalySize('Version', handles.AnalySize_Version, 'Date', handles.AnalySize_Date);


% --------------------------------------------------------------------
function MB_Set_Tern_Symbols_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Set_Tern_Symbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Defaults = getappdata(handles.AnalySize_MW, 'Defaults');

Transfer.Plot_Symbol = Defaults.TernSymbol;
Transfer.Symbol_Size = Defaults.TernSymbolSize;
Transfer.Symbol_Color = Defaults.Tern_Plot_Color;
Transfer.Face_Color = Defaults.TernFaceColor;

Return_Data = Tern_Set_Symbol('DataTransfer', Transfer, handles.AnalySize_MW, handles.AnalySize_MW);

if Return_Data.CancelFlag == 1
    return;
end

% Save the changes to session defaults
Defaults.TernSymbol = Return_Data.Plot_Symbol;
Defaults.TernSymbolSize = Return_Data.Symbol_Size;
Defaults.Tern_Plot_Color = Return_Data.Symbol_Color;

if strcmpi(Return_Data.Face_Color, 'none')
    Defaults.TernFaceColor = Return_Data.Face_Color;
else
    Defaults.TernFaceColor = 'filled';
end

setappdata(handles.AnalySize_MW, 'Defaults', Defaults);

guidata(hObject, handles);


% --------------------------------------------------------------------
function MB_Set_CM_Symbols_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Set_CM_Symbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Defaults = getappdata(handles.AnalySize_MW, 'Defaults');

Transfer.Plot_Symbol = Defaults.CMSymbol;
Transfer.Symbol_Size = Defaults.CMSymbolSize;
Transfer.Symbol_Color = Defaults.CM_Plot_Color;
Transfer.Face_Color = Defaults.CMFaceColor;

Return_Data = CM_Plot_Set_Symbols('DataTransfer', Transfer, handles.AnalySize_MW, handles.AnalySize_MW);

if Return_Data.CancelFlag == 1
    return;
end

% Save the changes to session defaults

Defaults.CMSymbol = Return_Data.Plot_Symbol;
Defaults.CMSymbolSize = Return_Data.Symbol_Size;
Defaults.CM_Plot_Color = Return_Data.Symbol_Color;

if strcmpi(Return_Data.Face_Color, 'none')
    Defaults.CMFaceColor = Return_Data.Face_Color;
else
    Defaults.CMFaceColor = 'filled';
end

setappdata(handles.AnalySize_MW, 'Defaults', Defaults);

guidata(hObject, handles);


% --------------------------------------------------------------------
function MB_Set_Data_Symbols_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Set_Data_Symbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Return_Data = Set_Data_Symbol(handles.AnalySize_MW);

if Return_Data.CancelFlag == 1
    return;
end

% Update the defaults
Defaults = Return_Data.Defaults;
setappdata(handles.AnalySize_MW, 'Defaults', Defaults);

% Get the defaults needed for the main window
handles.Default_Data_Color = Defaults.Data_Plot_Color;
handles.Default_Data_Symbol = Defaults.DataSymbol;
handles.Default_Data_Symbol_Size = Defaults.DataSymbolSize;

if strcmpi(Defaults.DataFaceColor, 'filled')
    handles.Default_Data_Symbol_Fill = handles.Default_Data_Color;
else
    handles.Default_Data_Symbol_Fill = 'none';
end

% Update the plots and save the handles
Update_Plots(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function MB_Set_Select_EM_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to MB_Set_Select_EM_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Return_Data = SelectEM_Plot_Set_Symbols(handles.AnalySize_MW, handles.AnalySize_MW);

if Return_Data.CancelFlag == 1
    return;
end

% keyboard

% Update the defaults
handles.Defaults = Return_Data.Defaults;
setappdata(handles.AnalySize_MW, 'Defaults', handles.Defaults);

guidata(hObject,handles);



% --- Executes on mouse press over axes background.
function PDF_Axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PDF_Axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PopOutFigure(handles.PDF_Axes, 'Grain Size Data')


% --- Executes on mouse press over axes background.
function EM_Axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to EM_Axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PopOutFigure(handles.EM_Axes, 'End Members')
