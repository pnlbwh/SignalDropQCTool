function return_handles = update_slice_selection(handles)

if strcmp(handles.user_machine_state, 'SIGNAL_DROP')
    handles.user_slice_selected = handles.user_results(handles.user_gradient_selected+1, 4);
elseif strcmp(handles.user_machine_state, 'SLICE_MOTION')
    handles.user_slice_selected = handles.user_results(handles.user_gradient_selected+1, 2);
end


return_handles = handles;

end