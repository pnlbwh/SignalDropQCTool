function save_QC_results(handles, hObject, automode)
% 
% This function save the results of the QC: only the good gradients 
% are kept in the NRRD file, the other ones are discarded
% A matrix with the results is also written as a text file
% And the divergence values are also written as a .mat file
% 

nhdr_file_name = handles.user_output_volume;
nhdr_file_name = strrep(nhdr_file_name, '.nhdr', '');


% Create a waitbar so that the user knows what's happening
display_message(true, handles, 'Saving, please wait a few seconds...');

if exist(fullfile(handles.user_data_path, [nhdr_file_name '.nhdr']), 'file') && (automode == false)
   message = sprintf(['Output volume ' nhdr_file_name  '.nhdr already exists in \n' handles.user_data_path '.\n Do you want to overwrite it?']); 
   title = 'Output file already exists';
   choice = questdlg(message, title, 'Change output file','No, stop', 'Overwrite', 'Overwrite') ;
   
   if strcmpi(choice, 'No, stop')
       handles.user_error = true;
       display_message(false, handles, '');
      return;
   end
   
   if strcmpi(choice, 'Change output file')
       main_window('pushbutton_output_file_Callback', hObject, [], handles);
   end
   
end

if ~isfield(handles, {'user_results', 'user_sz'})
    disp('No results available, output file not written');
    return;
end

QC_volume = create_QC_volume(handles.user_dwi, handles.user_results(:, 6), handles.user_sz);

% Now let's write the structure to the disk, in the NHDR format:
display_message(true, handles, 'Writting data on the disk...');
mat2DWInhdr(nhdr_file_name, handles.user_data_path, QC_volume, 'uint16');

% If we are in signal drop detection mode, we also write the QC matrix and
% the KL divergence results

if strcmpi(handles.user_machine_state, 'SIGNAL_DROP')
    % Let's write the QC matrix

    QC_matrix_name = strrep(handles.user_volume_name, '.nhdr',handles.user_suffix_QC_matrix);
    KL_matrix_name = strrep(handles.user_volume_name, '.nhdr',handles.user_suffix_divergence_matrix);

    results = handles.user_results(:, 6);
    dlmwrite(fullfile(handles.user_data_path, QC_matrix_name), results);
    % and the KL divergence results
    kl_divergence = handles.user_kl_divergence;
    save(fullfile(handles.user_data_path, KL_matrix_name), 'kl_divergence');
end

% If we loaded a Nifti file, we also write the Nifti version

if (handles.user_isFromNifti == true) && isfield(handles, 'user_nii') && isfield(handles, 'user_nifti_path') && isfield(handles, 'user_bval') && isfield(handles, 'user_bvec')
    % Save the Nifti file
    handles.user_nii.img = [];
    handles.user_nii.img = uint16(handles.user_dwi.data);
    save_untouch_nii(handles.user_nii, strrep(handles.user_nifti_path, '.nii', '-QC.nii'));
    
    % Save the Bvecs and Bval
    bval = handles.user_bval(logical(handles.user_results(:, 6)));
    bvec = handles.user_bvec(logical(repmat(handles.user_results(:, 6), [1 3])));
    dlmwrite(fullfile(handles.user_data_path, 'bvecs.txt'), bvec);
    dlmwrite(fullfile(handles.user_data_path, 'bvals.txt'), bval);
    
end


display_message(false, handles, '');




end