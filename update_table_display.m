function return_handles = update_table_display(handles)
% 
% Update the table with the gradients and the associated decision
% 



% % % 
% If we are in a state where we do not need to display more information
% % % 

if (strcmp(handles.user_machine_state, 'INIT')) || (strcmp(handles.user_machine_state, 'READY'))
    handles = init_display(handles);
    return_handles = handles;
    return;
end

sz = handles.user_sz;

if strcmp(handles.user_machine_state, 'SIGNAL_DROP')
   handles.user_column_names = {'Gradient #', 'Keep', 'Suggestion', 'Confidence', 'Need review', 'Original gradient #'}; 
   set(handles.uitable_gradients_results, 'ColumnName', handles.user_column_names);
end

if strcmp(handles.user_machine_state, 'SLICE_MOTION')
    handles.user_column_names = {'Gradient #', 'Keep', 'Suggestion', 'Confidence', 'Need review', 'Original gradient #'}; 
    set(handles.uitable_gradients_results, 'ColumnName', handles.user_column_names);
end




% We initialize the cells of the table
handles.user_table_data = cell(sz(4), numel(handles.user_column_names));

% % % 
% If we study signal drop or slice motion
% % % 
    
    
for index=1:sz(4)
    handles.user_table_data{index, 1} = num2str(index-1); 
    handles.user_table_data{index, 2} = (handles.user_results(index, 6) == 1); 
%     handles.user_table_data{index, 6} = handles.user_results(index, 1);
%     handles.user_table_data{index, 7} = handles.user_results(index, 3);

    if (handles.user_results(index, 5) == 1)
       handles.user_table_data{index, 3} = 'Keep';
    else
       handles.user_table_data{index, 3} = 'Discard';
    end

    if (handles.user_results(index, 7) == 1)
       handles.user_table_data{index, 4} = 'Sure';
    else
       handles.user_table_data{index, 4} = 'Unsure';
    end

    handles.user_table_data{index, 5} = (handles.user_results(index, 8) == 1); 
    
    handles.user_table_data{index, 6} = handles.user_results(index, 9);

end




set(handles.uitable_gradients_results, 'Data', handles.user_table_data);



return_handles = handles;

end