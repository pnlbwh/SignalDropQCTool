function return_handles = stack_gradients_along_fourth_axis(handles)

cycle = [4 1 2 3];



while ~strcmpi(handles.user_dwi.kinds{4}, 'list')
    handles.user_dwi.data = permute(handles.user_dwi.data, cycle);
    handles.user_dwi.kinds = {handles.user_dwi.kinds{4}, handles.user_dwi.kinds{1:3}};
    
end

handles.user_sz = size(handles.user_dwi.data);
return_handles = handles;

end