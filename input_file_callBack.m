function return_handles = input_file_callBack(handles, hObject)

% % % 
% Check if the user wants to save the results before closing
% % % 

if (handles.user_isSaved == false)
    message = 'The results have not been saved, would you like to save them?';
    title = 'Save results';
    choice = questdlg(message, title, 'Yes', 'No', 'Cancel', 'Yes');
    
    if strcmpi(choice, 'Yes')
        main_window('pushbutton_save_Callback', hObject, [], handles);
    end
    
    if strcmpi(choice, 'Cancel')
        return_handles = handles;
        return; 
    end
end

% % % 
% Launch a small window to ask for information
% % % 

% Input arguments
argin.user_data_path = handles.user_data_path;
argin.user_mask_path = handles.user_mask_path;
argin.user_divergence_path = handles.user_divergence_path;
argin.user_volume_name = handles.user_volume_name;
argin.user_header_reference = handles.user_header_reference;
argin.user_check_header = handles.user_check_header;
argin.user_parent_handle = handles.QC_Tool;
argin.user_suffix_divergence_matrix = handles.user_suffix_divergence_matrix;
argin.user_acquisition_dimension = handles.user_acquisition_dimension;

% Call the popup window
argout = input_file_window(argin);

if (argout.user_cancel == true)
    return_handles = handles;
   return; 
end

% Output arguments
handles.user_data_path = argout.user_data_path;
handles.user_mask_path = argout.user_mask_path;
handles.user_divergence_path = argout.user_divergence_path;
handles.user_volume_name = argout.user_volume_name;
handles.user_header_reference = argout.user_header_reference;
handles.user_check_header = argout.user_check_header;
handles.user_recreate_mask = argout.user_recreate_mask;
handles.user_mask_name = argout.user_mask_name;
handles.user_divergence_name = argout.user_divergence_name;
handles.user_recompute_divergence = argout.user_recompute_divergence;
handles.user_acquisition_dimension = argout.user_acquisition_dimension;
handles.user_isFromNifti = argout.user_isFromNifti;

% Clear the nifti data if it exists
if isfield(handles, 'user_nii')
    handles.user_nii.img = [];
end

if isfield(argout, 'user_nii')
    handles.user_nii = argout.user_nii;
end

if isfield(argout, 'user_nifti_path')
    handles.user_nifti_path = argout.user_nifti_path; 
end

if isfield(argout, 'user_bval')
    handles.user_bval = argout.user_bval; 
end

if isfield(argout, 'user_bvec')
    handles.user_bvec = argout.user_bvec; 
end

if isfield(argout, 'user_dwi')
    handles.user_dwi = argout.user_dwi; 
end

% Update the config file
update_config_file(handles);




% % % 
% Re-initialize the interface
% % % 

handles.user_machine_state = 'INIT';
display_message(true, handles, 'Loading file');
set(handles.uipanel_process, 'visible', 'off');
set(handles.uipanel_display_divergence, 'visible', 'off');
handles = init_display(handles);
handles = update_textboxes(handles);

handles.user_isSaved = false;

% % % 
% Load the DWI file
% % % 


handles = load_input_files(handles, 'DWI');

% Set the output volume name
handles.user_output_volume = strrep(handles.user_volume_name, '.nhdr', [handles.user_suffix_QC_file '.nhdr']);
set(handles.text_output_file, 'string', fullfile(handles.user_data_path, handles.user_output_volume));

% % % 
% Header checking
% % % 

if (handles.user_check_header == true)
    handles = check_header(handles);
    
    if ~strcmpi(handles.user_header_error, '')
        choice = questdlg(sprintf([handles.user_header_error '\n Continue anyway?']), 'Different header', 'Yes', 'No', 'No'); 
        
        if strcmpi(choice, 'No')
           return_handles =  handles;
           return;
        end
    end
end

% % % 
% Create and load the mask
% % % 

display_message(true, handles, 'Creating mask');

if ~exist(fullfile(handles.user_mask_path, handles.user_mask_name), 'file')
    handles.user_recreate_mask = true;    
end

handles = create_mask(handles);
handles = load_input_files(handles, 'MASK');

% % % 
% Update display
% % % 

handles.user_machine_state = 'READY';
handles = init_display(handles);
set(handles.text_input_file, 'string', fullfile(handles.user_data_path, handles.user_volume_name));
set(handles.text_mask, 'string', fullfile(handles.user_mask_path, handles.user_mask_name));

if (handles.user_recompute_divergence == true)
   set(handles.pushbutton_process, 'string', 'Process'); 
else
   set(handles.pushbutton_process, 'string', 'Load results'); 
end

set(handles.pushbutton_process, 'visible', 'on');

return_handles = handles;

end