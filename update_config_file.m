function update_config_file(handles)


handles.user_ini.SetValues('data', 'data_path', handles.user_data_path);
handles.user_ini.SetValues('data', 'mask_path', handles.user_mask_path);
handles.user_ini.SetValues('data', 'divergence_path', handles.user_divergence_path);
handles.user_ini.SetValues('data', 'review_level', handles.user_review_level);
handles.user_ini.SetValues('data', 'header_reference', handles.user_header_reference);
handles.user_ini.SetValues('data', 'check_header', handles.user_check_header);
handles.user_ini.SetValues('data', 'acquisition_dimension', handles.user_acquisition_dimension);



handles.user_ini.WriteFile('config.ini');


end