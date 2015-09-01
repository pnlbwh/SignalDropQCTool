function varargout = main_window(varargin)
% MAIN_WINDOW MATLAB code for main_window.fig
%      MAIN_WINDOW, by itself, creates a new MAIN_WINDOW or raises the existing
%      singleton*.
%
%      H = MAIN_WINDOW returns the handle to a new MAIN_WINDOW or the handle to
%      the existing singleton*.
%
%      MAIN_WINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_WINDOW.M with the given input arguments.
%
%      MAIN_WINDOW('Property','Value',...) creates a new MAIN_WINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_window_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_window

% Last Modified by GUIDE v2.5 17-Jun-2015 11:07:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_window_OpeningFcn, ...
                   'gui_OutputFcn',  @main_window_OutputFcn, ...
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


% --- Executes just before main_window is made visible.
function main_window_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_window (see VARARGIN)

% Choose default command line output for main_window
handles.output = hObject;

% Initialize variables
handles = init_main_window(handles);

% If we call from the function launch_QC_Tool(mode, path)
if (nargin > 3)
   handles.user_mode = varargin{1}.user_mode;
   handles.user_arg_path = varargin{1}.user_arg_path;
   handles.user_number_of_regions = varargin{1}.user_sensitivity;
   guidata(hObject, handles);
   
   
   handles = command_line_call(hObject, handles);
   
end

if strcmpi(handles.user_mode, 'automatic')
    return; 
end

% % % 
% Initialize display
% % % 

handles = init_display(handles);

guidata(hObject, handles);




% UIWAIT makes main_window wait for user response (see UIRESUME)
% uiwait(handles.QC_Tool);


% --- Outputs from this function are returned to the command line.
function varargout = main_window_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% delete(hObject);


% --- Executes on button press in pushbutton_process.
function pushbutton_process_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = process_callBack(handles, hObject, false);
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in uitable_gradients_results.
function uitable_gradients_results_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable_gradients_results (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% % % 
% Update the view when a user changes the gradient selection
% % % 

if (numel(eventdata.Indices) < 2)
   return; 
end

if (~strcmp(handles.user_machine_state, 'SIGNAL_DROP')) && (~strcmp(handles.user_machine_state, 'SLICE_MOTION'))
   return; 
end

handles.user_gradient_selected = eventdata.Indices(1)-1;

% If we are not currently editting the table, we update the display. Otherwise, there is a conflict with the function below, which tries to update the handles at the same time.
if (eventdata.Indices(2) ~= 2) 
    handles = update_slice_selection(handles);
    handles = update_table_display(handles);
    handles = update_textboxes(handles);
    handles = update_axes_display(handles, hObject);
end

guidata(hObject, handles);




% --- Executes when entered data in editable cell(s) in uitable_gradients_results.
function uitable_gradients_results_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable_gradients_results (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% % % 
% Update the results with the user choice
% % % 

if (length(eventdata.Indices) < 1)
   return; 
end

handles.user_results(eventdata.Indices(1), 6) = logical(eventdata.NewData);
handles.user_gradient_selected = eventdata.Indices(1)-1;

handles = update_slice_selection(handles);
handles = update_table_display(handles);
handles = update_textboxes(handles);
handles = update_axes_display(handles, hObject);

guidata(hObject, handles);






% --- Executes on mouse press over axes background.
function axes_sagittal_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_sagittal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pt=get(gca,'currentpoint');

sz = handles.user_sz;

handles.user_slice_selected = clip_data(sz(3) - round(pt(1, 2)), [1, sz(3)]); 
handles = update_textboxes(handles);
handles = update_axes_display(handles, hObject);
guidata(hObject, handles);



% --- Executes on mouse press over axes background.
function axes_divergence_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_sagittal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pt=get(gca,'currentpoint');

sz = handles.user_sz;

if strcmp(handles.user_machine_state, 'SLICE_MOTION')
    pt(1, 1) = pt(1, 1)+1;
end

handles.user_slice_selected = clip_data(round(pt(1, 1)), [1, sz(3)]); 
handles = update_textboxes(handles);
update_axes_display(handles, hObject);
guidata(hObject, handles);



% --- Executes on mouse press over axes background.
function axes_axial_middle_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_axial_middle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % % 
% Get the current position of the cursor, and update the display
% % % 


pt=get(gca,'currentpoint');

sz = handles.user_sz;
% *** sz(1)-pt(1,1)?
handles.user_sagittal_selected = clip_data(round(pt(1, 1)), [1, sz(1)]); 
handles = update_textboxes(handles);
update_axes_display(handles, hObject);
guidata(hObject, handles);



% function rdata = clip_data(data, boundaries)
% 
% rdata = data;
% 
% if (size(boundaries, 2) ~= 2)
%    error('Error using clip_data function') ;
% end
% 
% if (data < boundaries(1))
%    rdata = boundaries(1);
%    return;
% end
% 
% if (data > boundaries(2))
%    rdata = boundaries(2);
%    return;
% end


% --- Executes on selection change in listbox_review_level.
function listbox_review_level_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_review_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_review_level contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_review_level

index = get(hObject,'Value');
switch(index)
    case 1
        handles.user_review_level = 1;
    case 2
        handles.user_review_level = 2;
    case 3
        handles.user_review_level = 0;
        if (isfield(handles, 'user_results')) && (length(handles.user_results) >= 8)
            handles.user_results(:, 8) = false;
        end
    otherwise
        handles.user_review_level = 1;
end

handles = update_table_display(handles);
handles = update_textboxes(handles);
update_config_file(handles);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function listbox_review_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_review_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_keep.
function pushbutton_keep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_keep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isfield(handles, 'user_gradient_selected')) || (~isfield(handles, 'user_results'))
   return; 
end

if (size(handles.user_results, 1) < handles.user_gradient_selected +1)
   return; 
end

handles = apply_decision(handles, true);
handles = update_table_display(handles);
handles = update_textboxes(handles);
update_axes_display(handles, hObject);
guidata(hObject, handles);


pause(0.5);
pushbutton_review_Callback(hObject, eventdata, handles);



% --- Executes on button press in pushbutton_discard.
function pushbutton_discard_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_discard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isfield(handles, 'user_gradient_selected')) || (~isfield(handles, 'user_results'))
   return; 
end

if (size(handles.user_results, 1) < handles.user_gradient_selected +1)
   return; 
end

handles = apply_decision(handles, false);
handles = update_table_display(handles);
handles = update_textboxes(handles);
update_axes_display(handles, hObject);
guidata(hObject, handles);


pause(0.5);
pushbutton_review_Callback(hObject, eventdata, handles)


% --- Executes on key release with focus on QC_Tool and none of its controls.
function QC_Tool_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to QC_Tool (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)

switch(eventdata.Character)
    case 'k' % keep
        pushbutton_keep_Callback(hObject, [], handles);
    case 'd' % discard
        pushbutton_discard_Callback(hObject, [], handles);
    case 'n' % next
        pushbutton_review_Callback(hObject, [], handles);
    case 's' % save
        pushbutton_save_Callback(hObject, [], handles);
    case 'q' % exit zoom
        pushbutton_exit_zoom_Callback(hObject, [], handles);
    case 'z' % zoom
        pushbutton_lock_Callback(hObject, [], handles);
    otherwise
        
end


% --- Executes on key press with focus on pushbutton_process and none of its controls.
function pushbutton_process_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_process (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

QC_Tool_KeyReleaseFcn(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_input_file.
function pushbutton_input_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_input_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = input_file_callBack(handles, hObject);



% Save and clean
update_config_file(handles);
guidata(hObject, handles);

display_message(false, handles, '');


% --- Executes on button press in pushbutton_output_file.
function pushbutton_output_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_output_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname, ~] = uiputfile({'*.nhdr','NHDR file'},...
          'Save as',...
          fullfile(handles.user_data_path, handles.user_output_volume));
      
if isequal(filename,0) || isequal(pathname,0)
    return;
end

if ~strcmp(pathname, handles.user_data_path)
   errordlg('Error: the mask should be in the same directory than the diffusion volume', 'Error') ;
   return;
end

handles.user_output_volume = filename;
set(handles.text_output_file, 'string', fullfile(handles.user_data_path, handles.user_output_volume));

% Save and clean
guidata(hObject, handles);


% --- Executes on button press in pushbutton_input_mask.
function pushbutton_input_mask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_input_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save_QC_results(handles, hObject, false);

if (handles.user_error == true)
    handles.user_error = false;
    return;
end

handles.user_isSaved = true;
guidata(hObject, handles);


% --- Executes on button press in pushbutton_review.
function pushbutton_review_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_review (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isfield(handles, 'user_results')) || (length(handles.user_results) < 8)
   return;
end

if (nnz(handles.user_results(:, 8)) < 1)
   return; 
end

[~, location] = max(handles.user_results(:, 8));

handles.user_gradient_selected = location(1)-1;
handles = update_slice_selection(handles);
handles = update_textboxes(handles);
update_axes_display(handles, hObject);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_show_mask.
function pushbutton_show_mask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_show_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


show_mask_on_axes_display(handles, hObject);


% --- Executes on button press in pushbutton_show_slices.
function pushbutton_show_slices_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_show_slices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_axes_display(handles, hObject);


% --- Executes during object creation, after setting all properties.
function uipanel_control_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel_control (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_motion.
function pushbutton_motion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_motion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_apply_Callback(handles.pushbutton_apply, eventdata, handles);
handles = motion_callBack(handles, hObject);

guidata(hObject, handles);


% --- Executes on button press in pushbutton_mask.
function pushbutton_mask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[filename, pathname, ~] = uigetfile({'*.nii','Nifti file'},...
          'Select mask (Nifti)',...
          handles.user_data_path);
      
if isequal(filename,0)
    return;
end

if ~strcmp(pathname, handles.user_data_path)
   errordlg('Error: the mask should be in the same directory than the diffusion volume', 'Error') ;
   return;
end

handles.user_mask_name = filename;
set(handles.text_mask, 'string', fullfile(handles.user_mask_path, handles.user_mask_name));

load_input_files(handles, 'Mask');

guidata(hObject, handles);


% --- Executes on button press in pushbutton_apply.
function pushbutton_apply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update volume
handles.user_dwi = create_QC_volume(handles.user_dwi, handles.user_results(:, 6), handles.user_sz);
handles.user_sz = size(handles.user_dwi.data);

% Update results
tmp_res = handles.user_results;
handles.user_results = [];
mask = (tmp_res(:, 6) == true);
handles.user_results = tmp_res(repmat(mask, [1, size(tmp_res, 2)]));
handles.user_results = reshape(handles.user_results, [round(length(handles.user_results)/size(tmp_res, 2)), size(tmp_res, 2)]);

% Update kl_divergence
mask = reshape(mask, [1, 1, 1, length(mask)]);
factor = handles.user_factor;
kl_divergence = handles.user_kl_divergence;
handles.user_kl_divergence = [];
handles.user_kl_divergence = kl_divergence(repmat(mask, [factor, factor, size(kl_divergence, 3)]));
handles.user_kl_divergence = reshape(handles.user_kl_divergence, [factor, factor, size(kl_divergence, 3), round(length(handles.user_kl_divergence)/size(kl_divergence, 3))]);

absolute_distance_to_median = handles.user_absolute_distance_to_median;
handles.absolute_distance_to_median = [];
handles.absolute_distance_to_median = absolute_distance_to_median(repmat(mask, [factor, factor, size(absolute_distance_to_median, 3)]));
handles.absolute_distance_to_median = reshape(handles.absolute_distance_to_median, [factor, factor, size(absolute_distance_to_median, 3), round(length(handles.absolute_distance_to_median)/size(absolute_distance_to_median, 3))]);

relative_distance_to_median = handles.user_relative_distance_to_median;
handles.relative_distance_to_median = [];
handles.relative_distance_to_median = absolute_distance_to_median(repmat(mask, [factor, factor, size(absolute_distance_to_median, 3)]));
handles.relative_distance_to_median = reshape(handles.relative_distance_to_median, [factor, factor, size(relative_distance_to_median, 3), round(length(handles.relative_distance_to_median)/size(relative_distance_to_median, 3))]);

handles = init_display(handles);
handles.user_gradient_selected = 0;
handles = update_slice_selection(handles);
handles = update_table_display(handles);
handles = update_textboxes(handles);
handles = update_axes_display(handles, hObject);

% Hide the 'process button'
set(handles.pushbutton_process, 'visible', 'off');

guidata(hObject, handles);


% --- Executes on selection change in popupmenu_sensitivity.
function popupmenu_sensitivity_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sensitivity contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sensitivity

contents = cellstr(get(hObject,'String'));
choice = contents{get(hObject,'Value')};

if str2num(choice(1)) == 1
    handles.user_number_of_regions = 1;
else
    handles.user_number_of_regions = 4;
end

update_config_file(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_sensitivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_up.
function pushbutton_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sz = handles.user_sz;
handles.user_slice_selected = clip_data(handles.user_slice_selected+1, [1, sz(3)]);

handles = update_textboxes(handles);
handles = update_axes_display(handles, hObject);

guidata(hObject, handles);


% --- Executes on button press in pushbutton_down.
function pushbutton_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sz = handles.user_sz;
handles.user_slice_selected = clip_data(handles.user_slice_selected-1, [1, sz(3)]);

handles = update_textboxes(handles);
handles = update_axes_display(handles, hObject);

guidata(hObject, handles);

% --- Executes on scroll wheel click while the figure is in focus.
function QC_Tool_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to QC_Tool (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(handles.user_machine_state, 'SIGNAL_DROP') || strcmpi(handles.user_machine_state, 'SLICE_MOTION')

    if eventdata.VerticalScrollCount < 0
        pushbutton_up_Callback(hObject, [], handles);
    else
        pushbutton_down_Callback(hObject, [], handles);
    end

end



% --- Executes on button press in pushbutton_lock.
function pushbutton_lock_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_lock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.user_intensity_lock = true;
handles = update_textboxes(handles);
handles.user_zoom_active = true;
handles = update_axes_display(handles);

handles_to_hide = {handles.uipanel_status, handles.uipanel_control, handles.uipanel_process, handles.uipanel_display_divergence, handles.uipanel_axes};
for i=1:numel(handles_to_hide)
        set(handles_to_hide{i}, 'Visible', 'off');
end
set(handles.uipanel_zoom, 'Visible', 'on');

guidata(hObject, handles);


% --- Executes on button press in pushbutton_exit_zoom.
function pushbutton_exit_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exit_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.user_intensity_lock = false;
handles = update_textboxes(handles);
handles.user_zoom_active = false;
handles = update_axes_display(handles);

handles_to_show = {handles.uipanel_status, handles.uipanel_control, handles.uipanel_process, handles.uipanel_display_divergence, handles.uipanel_axes};
for i=1:numel(handles_to_show)
        set(handles_to_show{i}, 'Visible', 'on');
end
set(handles.uipanel_zoom, 'Visible', 'off');

guidata(hObject, handles);
