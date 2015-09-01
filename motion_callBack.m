function return_handles = motion_callBack(handles, hObject)

handles.user_machine_state = 'SLICE_MOTION';



% We first apply changes
display_message(true, handles, 'Applying changes');
% handles.user_dwi = create_QC_volume(handles.user_dwi, handles.user_results(:, 6), handles.user_sz);
% handles.user_sz = size(handles.user_dwi.data);

% Then we estimate the interslice motion
display_message(true, handles, 'Estimating inter-slice motion');
handles = estimate_slice_movement(handles);

% Finally we analyze the results
display_message(true, handles, 'Analysing results');
handles = analyze_slice_motion_results(handles);

display_message(false, handles, '');

% And we display the results
handles = init_display(handles);
handles.user_gradient_selected = 0;
handles = update_slice_selection(handles);
handles = update_table_display(handles);
handles = update_textboxes(handles);


handles = update_axes_display(handles, hObject);

return_handles = handles;

end