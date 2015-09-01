function return_handles = init_display(handles)


% % % 
% Initialize table
% % % 

if strcmpi(handles.user_machine_state, 'INIT') || strcmpi(handles.user_machine_state, 'READY')

   handles.user_column_names = {'Gradient #', 'Keep', 'Suggestion', 'Confidence', 'Need review', 'Original gradient #'}; 
    handles.user_column_format = {'numeric','logical',{'Keep', 'Discard'}, {'Sure', 'Unsure'}, 'logical', 'numeric'};
    handles.user_column_editable = [false, true, false, false, false, false, false];

    set(handles.uitable_gradients_results, 'Data', []);
    set(handles.uitable_gradients_results, 'ColumnName', handles.user_column_names);
    set(handles.uitable_gradients_results, 'ColumnFormat', handles.user_column_format);
    set(handles.uitable_gradients_results, 'ColumnEditable', handles.user_column_editable);
    set(handles.uitable_gradients_results, 'RowName', []);

    

end

% % % 
% Initialize axes
% % % 

    
selected_axes = {handles.axes_axial_before, handles.axes_axial_middle, handles.axes_axial_after, handles.axes_sagittal};
for i=1:length(selected_axes)
    axes(selected_axes{i}) ;
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    imagesc(zeros(5)), colormap gray, axis image;
end



if strcmpi(handles.user_machine_state, 'READY')

    sz = handles.user_sz;
    slice = floor(sz(3)/2);
    
    axes(handles.axes_axial_middle);
    slice = handles.user_dwi.data(:, :, slice, 1);
    imagesc(slice');
    colormap gray, axis image;
    set(gca,'xtick',[]);
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
    
    delete(findobj(handles.uipanel_display_divergence, 'type','axes'));
    
    % % % 
    % Allow "process", "mask" and "output file" buttons to be accessed
    % % % 
    
    set_visible = {handles.pushbutton_mask, handles.pushbutton_output_file, handles.text_mask, handles.text_output_file, handles.pushbutton_process};
    for i=1:length(set_visible)
       set(set_visible{i}, 'visible', 'on') ;
    end
    
end





return_handles = handles;


end