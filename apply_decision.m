function return_handles = apply_decision(handles, decision)


handles.user_results(handles.user_gradient_selected +1, 6) = logical(decision);
handles.user_results(handles.user_gradient_selected +1, 8) = false;

% if (handles.user_gradient_selected + 2 > handles.user_sz(4))
%     handles.user_end_review = true;
% else
%    handles.user_gradient_selected = handles.user_gradient_selected +1;
% end
% 
% handles = update_slice_selection(handles);


return_handles = handles;

end