function varargout = default(varargin)
% DEFAULT MATLAB code for default.fig
%      DEFAULT, by itself, creates a new DEFAULT or raises the existing
%      singleton*.
%
%      H = DEFAULT returns the handle to a new DEFAULT or the handle to
%      the existing singleton*.
%
%      DEFAULT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEFAULT.M with the given input arguments.
%
%      DEFAULT('Property','Value',...) creates a new DEFAULT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before default_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to default_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help default

% Last Modified by GUIDE v2.5 03-Oct-2015 14:44:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @default_OpeningFcn, ...
                   'gui_OutputFcn',  @default_OutputFcn, ...
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


% --- Executes just before default is made visible.
function default_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to default (see VARARGIN)

% Choose default command line output for default
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(hObject,'Color','white');
LoadListBox(handles);

% UIWAIT makes default wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = default_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on selection change in listFiles.
function listFiles_Callback(hObject, eventdata, handles)
% hObject    handle to listFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listFiles


% --- Executes during object creation, after setting all properties.
function listFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = LoadListBox(handles)
try
	ListOfFilenames = {};
	dirListing = dir('../data/*.csv');
	for Index = 1:length(dirListing)
		baseFileName = dirListing(Index).name;
		ListOfFilenames = [ListOfFilenames baseFileName];
	end
	set(handles.listFiles, 'string', ListOfFilenames);  	
catch ME
	errorMessage = sprintf('Error in LoadListBox().\nThe error reported by MATLAB is:\n\n%s', ME.message);
	uiwait(warndlg(errorMessage));
end
return; % from LoadListBox


% --- Executes on button press in btnPlot.
function btnPlot_Callback(hObject, eventdata, handles)
% hObject    handle to btnPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Selected = handles.listFiles.Value;
Files = handles.listFiles.String;

if length(Selected) ~= 2
   return; 
end

plotAndSave(Files{Selected(1)}, Files{Selected(2)});
