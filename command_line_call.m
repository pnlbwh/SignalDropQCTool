function return_handles = command_line_call(hObject, handles)

if strcmpi(handles.user_mode, 'semi-automatic')
    
    if strcmpi(handles.user_arg_path, '')
       return_handles = handles;
       return;
    end
    
    display_message(true, handles, 'Loading please wait...');
    
    [path, file, ext] = fileparts(handles.user_arg_path);
    handles.user_data_path = path;
    handles.user_mask_path = path;
    handles.user_divergence_paht = path;
    handles.user_volume_name = [file ext];
    
    % % % 
    % Load the DWI file
    % % % 

    handles = load_input_files(handles, 'DWI');

    % Set the output volume name
    handles.user_output_volume = strrep(handles.user_volume_name, '.nhdr', [handles.user_suffix_QC_file '.nhdr']);
    set(handles.text_output_file, 'string', fullfile(handles.user_data_path, handles.user_output_volume));
    
    handles.user_mask_name = strrep(handles.user_volume_name, '.nhdr', '_mask.nii');
    handles = create_mask(handles);
    handles = load_input_files(handles, 'MASK');

    % % % 
    % Update display
    % % % 

    handles.user_machine_state = 'READY';
    handles = init_display(handles);
    set(handles.text_input_file, 'string', fullfile(handles.user_data_path, handles.user_volume_name));
    set(handles.text_mask, 'string', fullfile(handles.user_mask_path, handles.user_mask_name));
    
    display_message(false, handles, 'Loading please wait...');
    
    
end

if strcmpi(handles.user_mode, 'automatic')
   
    if ~exist(handles.user_arg_path, 'file')
        error('File does not exist');
    end
    
    % Hide the window
    display_message(true, handles, '= Automatic mode =');
    set(handles.QC_Tool, 'visible', 'off');
    drawnow;
    
    [path, file, ext] = fileparts(handles.user_arg_path);
    handles.user_data_path = path;
    handles.user_mask_path = path;
    handles.user_divergence_paht = path;
    handles.user_volume_name = [file ext];

    % % % 
    % Load the DWI file
    % % % 

    handles = load_input_files(handles, 'DWI');

    % Set the output volume name
    handles.user_output_volume = strrep(handles.user_volume_name, '.nhdr', [handles.user_suffix_QC_file '.nhdr']);
    set(handles.text_output_file, 'string', fullfile(handles.user_data_path, handles.user_output_volume));

    handles.user_mask_name = strrep(handles.user_volume_name, '.nhdr', '_mask.nii');
    handles = create_mask(handles);
    handles = load_input_files(handles, 'MASK');
    
    automode = true;
    handles = process_callBack(handles, hObject, automode);

    save_QC_results(handles, hObject, automode);
    
    disp([handles.user_arg_path ' => QC finished']);

    
end


return_handles = handles;

end