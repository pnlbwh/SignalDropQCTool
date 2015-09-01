function return_handles = process_callBack(handles, hObject, automode)


% % % 
% Go into SIGNAL DROP detection mode
% % % 

if ~automode
    display_message(true, handles, 'Processing data, please wait');
end

handles.user_machine_state = 'SIGNAL_DROP';


% % % 
% Process the 4D volume
% % % 

% Process function
handles = process_scan(handles);

% % % 
% Analyse results
% % % 
if ~automode
    display_message(true, handles, 'Processing results');
end

handles = analyze_results(handles);

if ~automode
    % Simulate a call on the "uncertainty option panel"
    main_window('listbox_review_level_Callback', hObject, [], handles);
    display_message(false, handles, '');


    % % % 
    % Activate process panel and divergence panel
    % % % 

    set(handles.uipanel_process, 'Visible', 'on');
    set(handles.uipanel_display_divergence, 'Visible', 'on');

    % % % 
    % Update Display
    % % % 

    handles = update_axes_display(handles, hObject);
    handles = update_table_display(handles);
    handles = update_textboxes(handles);
end

return_handles = handles;

end