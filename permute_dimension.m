function return_handles = permute_dimension(handles, mode)


% Read the orientation and permute dimensions so that we have the
% corresponding acquisition plane dimension is along the 3rd axis

% plane = {'sagittal', 'coronal', 'axial'};
% designation = {'right', 'anterior', 'superior', 'left', 'posterior', 'inferior'};
% space = handles.user_dwi.space;
% 
if (handles.user_acquisition_dimension == 3)
    return_handles = handles;
    return;    
end

handles.user_recompute_divergence = true;


% First find the cyclique permutation
cycle = [3 1 2]';

handles.user_acquisition_dimension = clip_data(handles.user_acquisition_dimension, [1 3]);
while (cycle(3) ~= handles.user_acquisition_dimension)
    cycle = circshift(cycle, 1);
end

cycle = cycle';

if strcmpi(mode, 'DWI')

    terms = strsplit(handles.user_dwi.space, '-');
    if (numel(terms) ~= 3)
        error('Error while reading the space orientation');
    end
    
    handles.user_dwi.data = permute(handles.user_dwi.data, [cycle, 4]);
    handles.user_dwi.sizes = permute(handles.user_dwi.sizes, [cycle, 4]);
    handles.user_dwi.thicknesses = permute(handles.user_dwi.thicknesses, [cycle, 4]);
    handles.user_dwi.space = [terms{cycle(1)} '-' terms{cycle(2)} '-' terms{cycle(3)}];
    
end

if strcmpi(mode, 'MASK')
   
    handles.user_mask.img = permute(handles.user_mask.img, [cycle, 4]);
end

return_handles = handles;

end