function return_handles = update_textboxes(handles)

% % % 
% Initialization
% % % 

if strcmpi(handles.user_machine_state, 'READY') || strcmpi(handles.user_machine_state, 'INIT')
    set(handles.text_slices, 'String', 'Slices:');
    set(handles.text_gradient, 'String', 'Gradient: ');
    
    color = 'w';
    set(handles.text_gradient_stats, 'String', '');
    set(handles.text_gradient_stats, 'BackgroundColor', color);
    
    set(handles.text_suggestion, 'String', '');
    set(handles.text_suggestion, 'BackgroundColor', color);
    
    set(handles.text_confidence, 'String', '');
    set(handles.text_confidence, 'BackgroundColor', color);
    
    set(handles.text_user_decision, 'String', '');
    set(handles.text_user_decision, 'BackgroundColor', color);
    
    return_handles = handles;
    return;
end



% % % 
% Set the text in the text boxes
% % % 

% % % 
% Slice number
% % % 
text = sprintf(['Axial slices: ' num2str(handles.user_slice_selected-1) ', ' num2str(handles.user_slice_selected) ', ' num2str(handles.user_slice_selected+1) ' -   Sagittal slice: ' num2str(handles.user_sagittal_selected)]);
set(handles.text_slices, 'String', text);

% % % 
% Gradient number
% % % 

text = sprintf(['Gradient: ' num2str(handles.user_gradient_selected)]); 
set(handles.text_gradient, 'String', text);

% % % 
% Intensity lock
% % % 

text = 'Intensity unlocked';
button = 'Lock';
color = 'g';

if (handles.user_intensity_lock == true)
    text = 'Intensity locked';
    color = [1 130/255 0];
    button = 'Unlock';
end

set(handles.text_intensity_lock, 'String', text);
set(handles.text_intensity_lock, 'BackgroundColor', color);

% % % 
% Review stats
% % % 

text = sprintf([num2str(nnz(handles.user_results(:, 6))) ' Good gradients -' num2str(nnz(1-handles.user_results(:, 6))) ' Bad gradients  - ' num2str(nnz(handles.user_results(:, 8))) ' gradients review left']);
color = 'w';

if (nnz(handles.user_results(:, 8)) < 1)
    color = 'g';
end

set(handles.text_gradient_stats, 'String', text);
set(handles.text_gradient_stats, 'BackgroundColor', color);

% % % 
% Suggestion: Keep or Discard
% % % 


suggestion = 'Suggestion: Discard';
color = 'r';
if (handles.user_results(handles.user_gradient_selected+1, 5) == 1)
    suggestion = 'Suggestion: Keep';
    color = 'g';        
end
    


set(handles.text_suggestion, 'String', suggestion);
set(handles.text_suggestion, 'BackgroundColor', color);


% % % 
% If we are looking at signal drop
% % % 

if (strcmp(handles.user_machine_state, 'SIGNAL_DROP'))
    
    % % % 
    % Confidence: Sure or Unsure
    % % % 

    confidence = 'Confidence: Unsure';
    color = [1 130/255 0];

    if (handles.user_results(handles.user_gradient_selected+1, 7) == 1)
            confidence = 'Confidence: Sure';
            color = 'g';        
    end

    set(handles.text_confidence, 'String', confidence);
    set(handles.text_confidence, 'BackgroundColor', color);

    % % % 
    % User choice
    % % % 

    user_decision = 'User choice: Discard';
    color = 'r';
    if (handles.user_results(handles.user_gradient_selected+1, 6) == 1)
            user_decision = 'User choice: Keep';
            color = 'g';        
    end

    if (handles.user_results(handles.user_gradient_selected+1, 8) == 1)
         user_decision = 'User choice: ?'  ; 
         color = 'w';
    end

    set(handles.text_user_decision, 'String', user_decision);
    set(handles.text_user_decision, 'BackgroundColor', color);
    
elseif (strcmp(handles.user_machine_state, 'SLICE_MOTION'))
    
    % We hide the confidence text box
    
    confidence = '';
    color = 'w';
    set(handles.text_confidence, 'String', confidence);
    set(handles.text_confidence, 'BackgroundColor', color);
    
    % We set the user choice
    user_decision = 'User choice: Discard';
    color = 'r';
    if (handles.user_results(handles.user_gradient_selected+1, 6) == 1)
            user_decision = 'User choice: Keep';
            color = 'g';        
    end

    set(handles.text_user_decision, 'String', user_decision);
    set(handles.text_user_decision, 'BackgroundColor', color);
end

return_handles = handles;


end