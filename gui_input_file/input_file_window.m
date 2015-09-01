function varargout = input_file_window(varargin)
% INPUT_FILE_WINDOW MATLAB code for input_file_window.fig
%      INPUT_FILE_WINDOW, by itself, creates a new INPUT_FILE_WINDOW or raises the existing
%      singleton*.
%
%      H = INPUT_FILE_WINDOW returns the handle to a new INPUT_FILE_WINDOW or the handle to
%      the existing singleton*.
%
%      INPUT_FILE_WINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INPUT_FILE_WINDOW.M with the given input arguments.
%
%      INPUT_FILE_WINDOW('Property','Value',...) creates a new INPUT_FILE_WINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before input_file_window_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to input_file_window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help input_file_window

% Last Modified by GUIDE v2.5 23-Jun-2015 12:08:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @input_file_window_OpeningFcn, ...
                   'gui_OutputFcn',  @input_file_window_OutputFcn, ...
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


% --- Executes just before input_file_window is made visible.
function input_file_window_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to input_file_window (see VARARGIN)

% Choose default command line output for input_file_window
handles.output = hObject;

% Input arguments:
handles.user_data_path = varargin{1}.user_data_path;
handles.user_mask_path = varargin{1}.user_mask_path;
handles.user_divergence_path = varargin{1}.user_divergence_path;
handles.user_volume_name = varargin{1}.user_volume_name;
handles.user_header_reference = varargin{1}.user_header_reference;
handles.user_check_header = varargin{1}.user_check_header;
handles.user_suffix_divergence_matrix = varargin{1}.user_suffix_divergence_matrix;
handles.user_acquisition_dimension = varargin{1}.user_acquisition_dimension;

handles.user_parent_handle = varargin{1}.user_parent_handle;

handles.user_error = false;
handles.user_recompute_divergence = true;
handles.user_mask_name = '';
handles.user_divergence_name = '';
handles.user_isFromNifti = false;


set(handles.text_header_reference, 'string', handles.user_header_reference);
set(handles.checkbox_check_header, 'value', handles.user_check_header);

handles.user_recreate_mask = true;

set(handles.popupmenu_dimension, 'Value', 4 - handles.user_acquisition_dimension);
set(handles.figure1,'WindowStyle','modal');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes input_file_window wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = input_file_window_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

popupmenu_dimension_Callback(handles.popupmenu_dimension, [], handles);

argout.user_cancel = handles.user_cancel;
argout.user_data_path = handles.user_data_path;
argout.user_mask_path = handles.user_mask_path;
argout.user_divergence_path = handles.user_divergence_path;
argout.user_volume_name = handles.user_volume_name;
argout.user_header_reference = handles.user_header_reference;
argout.user_check_header = handles.user_check_header;
argout.user_recreate_mask = handles.user_recreate_mask;
argout.user_mask_name = handles.user_mask_name;
argout.user_recompute_divergence = handles.user_recompute_divergence;
argout.user_divergence_name = handles.user_divergence_name;
argout.user_acquisition_dimension = handles.user_acquisition_dimension;
argout.user_isFromNifti = handles.user_isFromNifti;


if isfield(handles, 'user_nii') && handles.user_isFromNifti
    argout.user_nii = handles.user_nii;
end

if isfield(handles, 'user_nifti_path') && handles.user_isFromNifti
   argout.user_nifti_path = handles.user_nifti_path; 
end

if isfield(handles, 'user_bval') && handles.user_isFromNifti
   argout.user_bval = handles.user_bval; 
end

if isfield(handles, 'user_bvec') && handles.user_isFromNifti
   argout.user_bvec = handles.user_bvec; 
end

if isfield(handles, 'user_dwi') && handles.user_isFromNifti
   argout.user_dwi = handles.user_dwi; 
end


varargout{1} = argout;

delete(handles.figure1);


% --- Executes on button press in pushbutton_input_file.
function pushbutton_input_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_input_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = select_nhdr_scan(handles);

if (handles.user_error == true)
    handles.user_error = false;
    return;
end

% Reset the mask and divergence path so that we search in the right folder

handles.user_divergence_path = handles.user_data_path;
handles.user_mask_path = handles.user_data_path;

% If it seems like the mask already exists, we ask the user

handles.user_mask_name = strrep(handles.user_volume_name, '.nhdr', '_mask.nii');
set(handles.text_mask, 'string', fullfile(handles.user_mask_path, handles.user_mask_name));

if exist(fullfile(handles.user_mask_path, handles.user_mask_name), 'file')
    message = sprintf(['The mask ' handles.user_mask_name ' already exists in \n' handles.user_mask_path ',\n would you like to use this one, or recreate one? (Note: recreate will overwrite ' handles.user_mask_name ')']);
    title = 'Mask already exsits';
    choice = questdlg(message, title, 'Recreate', 'Use this one', 'Use this one') ;
    
    if strcmpi(choice, 'Recreate')
        handles.user_recreate_mask = true;
    else
        handles.user_recreate_mask = false;
    end
end

% If it seems like divergence results already exists, we ask the user

handles.user_divergence_name = strrep(handles.user_volume_name, '.nhdr',handles.user_suffix_divergence_matrix);

if exist(fullfile(handles.user_divergence_path, handles.user_divergence_name), 'file')
    message = 'It seems that KL-divergence results exists for this scan, would yo like to load them?';
    title = 'Existing divergence results';
    choice = questdlg(message, title, 'Recompute', 'Use them', 'Use them');
    
    if strcmpi(choice, 'Recompute')
        handles.user_recompute_divergence = true;
    else
        handles.user_recompute_divergence = false;
        set(handles.text_divergence_results, 'string', fullfile(handles.user_divergence_path, handles.user_divergence_name));
    end
    
end

set(handles.pushbutton_ok, 'visible', 'on');

guidata(hObject, handles);

% --- Executes on button press in pushbutton_mask.
function pushbutton_mask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname, ~] = uigetfile({'*.nii','Nifti file'},...
          'Select mask (Nifti)',...
          handles.user_mask_path);
      
if isequal(filename,0)
    return;
end


handles.user_mask_name = filename;
handles.user_mask_path = pathname;
handles.user_recreate_mask = false;
set(handles.text_mask, 'string', fullfile(handles.user_mask_path, handles.user_mask_name));

guidata(hObject, handles);


% --- Executes on button press in pushbutton_check_header.
function pushbutton_check_header_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_check_header (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname, ~] = uigetfile({'*.nhdr','*.nhdr NHDR file'},...
          'Select reference file',...
          handles.user_header_reference);

if isequal(filename,0)
    return;
end

handles.user_header_reference = fullfile(pathname, filename);
set(handles.text_header_reference, 'string', handles.user_header_reference);

guidata(hObject, handles);


% --- Executes on selection change in popupmenu_dimension.
function popupmenu_dimension_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_dimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_dimension contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_dimension

contents = cellstr(get(hObject, 'String'));
value = contents{get(hObject, 'Value')};
handles.user_acquisition_dimension = str2num(strrep(value, 'Dim ', ''));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_dimension_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_dimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_check_header.
function checkbox_check_header_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_check_header (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_check_header

handles.user_check_header = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in pushbutton_ok.
function pushbutton_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.user_cancel = false;
guidata(hObject, handles);

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end




% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.user_cancel = true;
guidata(hObject, handles);

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
handles.user_cancel = true;
guidata(hObject, handles);

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on button press in pushbutton_load_divergence.
function pushbutton_load_divergence_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_divergence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname, ~] = uigetfile({'*.nhdr','*.nhdr NHDR file'},...
          'Select reference file',...
          handles.user_divergence_path);

if isequal(filename,0)
    return;
end

handles.user_divergence_name = filename;
handles.user_divergence_path = pathname;
handles.user_recompute_divergence = false;

set(handles.text_divergence_results, 'string', fullfile(pathname, filename));

guidata(hObject, handles);
