function return_handles = load_input_files(handles, which_file)
% 
% Load the dwi volume and the mask into memory
% return_handles = load_input_files(handles, which_file)
% which_file: 'DWI', 'MASK' or 'KL_DIV'
% 

if strcmpi(which_file, 'DWI')
    if (~exist(fullfile(handles.user_data_path, handles.user_volume_name), 'file')) && (handles.user_isFromNifti == false)
           error('Input file does not exist');
    end
    
    [pathname, filename, extension] = fileparts(fullfile(handles.user_data_path, handles.user_volume_name));
    
    filename = [filename extension];
    % If we have a .nrrd, we convert it to .nhdr so that we can load it easily
    if strcmpi(extension, '.NRRD')
        
        command = ['unu convert -t short -i ' fullfile(pathname, filename) ' -o ' fullfile(pathname, strrep(filename, '.nrrd', '.nhdr'))];
        system(command);
        filename = strrep(filename, '.nrrd', '.nhdr');
        handles.user_volume_name = filename;
    end
    
    if (handles.user_isFromNifti == false)
            handles.user_dwi = loadNrrdStructure(fullfile(handles.user_data_path, handles.user_volume_name));
    end
    handles.user_sz = size(handles.user_dwi.data);
    
    % Control the volume
    
    if (length(handles.user_sz) ~= 4)
        error('Error: input volume shoud be 4-D');
    end
    
    
    if ~strcmpi(handles.user_dwi.kinds{4}, 'list')
        
        handles = stack_gradients_along_fourth_axis(handles);
        
        warning('Warning: Gradients will be re-stacked along the 3th axis (4th dimensions)');        
    end
    
    if (handles.user_sz(4) < 1)
        error('No gradient found');
    end
    
    handles = permute_dimension(handles, which_file);
    
end

if strcmpi(which_file, 'MASK')
    
    if (~exist(fullfile(handles.user_mask_path, handles.user_mask_name), 'file'))
        error('Input file does not exist');
    end
    
    handles.user_mask = load_untouch_nii(fullfile(handles.user_mask_path, handles.user_mask_name));
    handles.user_mask.img = logical(handles.user_mask.img);
    
    handles = permute_dimension(handles, which_file);

end

if strcmpi(which_file, 'KL_DIV')
   
    file = fullfile(handles.user_divergence_path, handles.user_divergence_name);
    if ~exist(file, 'file')
        error('Input file does not exist');
    end
    
    a = load(file);
    
    if ~isfield(a, 'kl_divergence')
        error('The KL-divergence matrix set as input does not have a field named kl_divergence');
    end
    handles.user_kl_divergence = a.kl_divergence;
    
    if (ndims(handles.user_kl_divergence) ~= 4)
        error('The KL-divergence matrix does not have 4 dimensions');
    end
    
    handles.user_number_of_regions = size(handles.user_kl_divergence, 1);
    
end


return_handles = handles;
return;

end