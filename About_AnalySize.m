function varargout = About_AnalySize(varargin)
% ABOUT_ANALYSIZE MATLAB code for About_AnalySize.fig
%      ABOUT_ANALYSIZE, by itself, creates a new ABOUT_ANALYSIZE or raises the existing
%      singleton*.
%
%      H = ABOUT_ANALYSIZE returns the handle to a new ABOUT_ANALYSIZE or the handle to
%      the existing singleton*.
%
%      ABOUT_ANALYSIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ABOUT_ANALYSIZE.M with the given input arguments.
%
%      ABOUT_ANALYSIZE('Property','Value',...) creates a new ABOUT_ANALYSIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before About_AnalySize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to About_AnalySize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help About_AnalySize

% Last Modified by GUIDE v2.5 26-May-2015 13:43:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @About_AnalySize_OpeningFcn, ...
                   'gui_OutputFcn',  @About_AnalySize_OutputFcn, ...
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


% --- Executes just before About_AnalySize is made visible.
function About_AnalySize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to About_AnalySize (see VARARGIN)

% Choose default command line output for About_AnalySize
handles.output = hObject;


Logo = imread('Logo.png');
image(Logo,'Parent',handles.Logo_Axes)
axis(handles.Logo_Axes, 'off');

% Set the text
set(handles.txt_Title, 'string', 'AnalySize v0.9');
set(handles.txt_Date, 'string', '28/07/2015');
set(handles.txt_MSG, 'string',...
    'Thank you for using AnalySize. If you found it useful and you use it in your work,  we would be very grateful if you cited the following reference: ');
set(handles.txt_Ref, 'string', 'Paterson, G. A., and D. Heslop, Title (2015), Journal Name, Vol., Pages, doi:....');
set(handles.txt_URL, 'string', [{'The latest version of AnalySize is avaiable at:'}, {'https://github.com/greigpaterson/AnalySize'}]);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes About_AnalySize wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = About_AnalySize_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
