function return_handles = select_nhdr_scan(handles)


[filename, pathname, ~] = uigetfile({'*.nhdr;*.nrrd','*.nhdr;*.nrrd NRRD file'; '*.nii','*.nii Nifti file'},...
          'Select NRRD/NII file for Quality Control',...
          handles.user_data_path);
      
if isequal(filename,0)
    handles.user_error = true;
    return_handles = handles;
    return;
end

handles.user_volume_name = filename;
handles.user_data_path = pathname;
[~, ~, extension] = fileparts(filename);

handles.user_isFromNifti = false;

if ~strcmpi(extension, '.NRRD') && ~strcmpi(extension, '.NHDR') && ~strcmpi(extension, '.NII')
   errdlg('Please select a NRRD or NHDR or NII file', 'File Error'); 
end

% If we have a .nrrd, we convert it to .nhdr so that we can load it easily
if strcmpi(extension, '.NRRD')
   

%     command = ['unu head ' fullfile(pathname, filename) ' > ' fullfile(pathname, strrep(filename, '.nrrd', '.nhdr'))];
%     system(command);
%     command = ['echo "data file:' strrep(filename, '.nrrd', '.raw.gz') '" >> ' fullfile(pathname, strrep(filename, '.nrrd', '.nhdr'))];
%     system(command);
%     
%     command = ['unu data ' fullfile(pathname, filename) ' > ' fullfile(pathname, strrep(filename, '.nrrd', '.raw.gz'))];
%     system(command);
    command = ['unu convert -t short -i ' fullfile(pathname, filename) ' -o ' fullfile(pathname, strrep(filename, '.nrrd', '.nhdr'))];
    system(command);
    filename = strrep(filename, '.nrrd', '.nhdr');
    handles.user_volume_name = filename;
    

end

% If we have a Nifti file, we convert it to .nhdr. To remember to output
% the result as Nifti, we set a flag to true.
if strcmpi(extension, '.NII')
    
    handles.user_nifti_path = fullfile(pathname, filename);
    
    [filename, pathname, ~] = uigetfile({'*.txt', 'Bvecs'}, ...
                                        'Select Bvecs file', ...
                                        handles.user_data_path);

    if isequal(filename,0)
        handles.user_error = true;
        return_handles = handles;
        return;
    end    
    
    handles.user_bvec = dlmread(fullfile(pathname, filename));
    
    [filename, pathname, ~] = uigetfile({'*.txt', 'Bvals'}, ...
                                        'Select Bvals file', ...
                                        handles.user_data_path);

    if isequal(filename,0)
        handles.user_error = true;
        return_handles = handles;
        return;
    end
    
    handles.user_bval = dlmread(fullfile(pathname, filename));
            
    handles = create_nhdr_from_nifti(handles, handles.user_bvec, handles.user_bval);
    handles.user_volume_name = strrep(handles.user_volume_name, '.nii', '.nhdr');
    handles.user_isFromNifti = true;
    
end


set(handles.text_input_file, 'string', fullfile(handles.user_data_path, handles.user_volume_name));

      
  
return_handles = handles;
      
end