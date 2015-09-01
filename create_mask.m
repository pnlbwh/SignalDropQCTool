function return_handles = create_mask(handles)

if (handles.user_recreate_mask == false)
    return_handles = handles;
    return;
end

sz = handles.user_sz;
bval = zeros(sz(4), 1);
dwi = handles.user_dwi;

set(handles.text_mask, 'string', fullfile(handles.user_mask_path, handles.user_mask_name));



% % % 
% First, find all the B0s
% % % 

for i=1:length(dwi.gradients)
    bval(i) = dwi.bvalue * norm(dwi.gradients(i, :), 2)^2;
end


number_of_b0 = nnz(bval < 1);

if (number_of_b0 < 1)
   error('No B-0 gradient found in the dwi data') ;
end

mask_b0_data = bval<1;
mask_b0_data_reshaped = reshape(mask_b0_data, [1, 1, 1, length(mask_b0_data)]);
mask_b0_data = []; %#ok<NASGU>
mask_b0_data = repmat(mask_b0_data_reshaped, [sz(1:3), 1]);


b0_data = reshape(dwi.data(mask_b0_data), [sz(1:3), number_of_b0]);

% % % 
% Then take the median for each voxel
% % % 


b0_data = median(double(b0_data), 4);


% % % 
% Write the result to the disk
% % % 

B0_name = strrep(handles.user_volume_name, '.nhdr', '-B0_Estimate'); 
mat2nhdr(b0_data, fullfile(handles.user_data_path, B0_name), 'ushort', dwi.spacedirections, dwi.spaceorigin);

% Convert it to nifti for BET
B0_name = [B0_name '.nhdr'];
nii_b0_path = fullfile(handles.user_data_path, strrep(B0_name, '.nhdr', '.nii'));

command = ['ConvertBetweenFileFormats ' fullfile(handles.user_data_path, B0_name) ' ' nii_b0_path];
system(command);

% % % 
% Launch BET
% % % 

zipped_mask = strrep(handles.user_volume_name, '.nhdr', '.nii');
software = 'bet ';
command = [software nii_b0_path ' ' fullfile(handles.user_mask_path, zipped_mask) ' -m -n -f 0.25']; % 0.3
system(command);

% % % 
% Unzip the mask
% % % 

% Bet automatically append "_mask.nii.gz"
zipped_mask = strrep(handles.user_mask_name, '.nhdr', '_mask.nii.gz');
command = ['gunzip ' fullfile(handles.user_mask_path, zipped_mask)];
system(command);

% % % 
% Remove tmp files: 
% % % 
command = ['rm ' fullfile(handles.user_data_path, B0_name) ' ' nii_b0_path ' ' strrep(fullfile(handles.user_data_path, B0_name), '.nhdr', '.raw.gz')];
system(command);

return_handles = handles;
end