function return_handles = create_nhdr_from_nifti(handles, bvec, bval)

% Assumption: volumes stacked along the 4th axis for the nifti file

nii = load_untouch_nii(handles.user_nifti_path);

if ndims(nii.img) ~= 4
   error('Error while reading nifti file: nifti data should have 4 dimensions');
end

if size(nii.img, 4) ~= length(bval) || length(bval) ~= size(bvec, 1) || size(bvec, 2) ~= 3
   error('Error, Bvec, Bval and Nifti file size do not match'); 
end

dwi.data = uint16(nii.img);
dwi.type = 'short';
dwi.dimension = 4;
dwi.space = 'left-posterior-superior';
dwi.sizes = size(dwi.data);
dwi.endian = 'little';
dwi.encoding = 'raw';
dwi.spaceorigin = [0 0 0];
dwi.kinds = {'space'  'space'  'space'  'list'};
dwi.spacedirections = [2 0 0; 0 2 0; 0 0 2];
dwi.modality = 'DWMRI';
dwi.bvalue = max(bval);
dwi.gradients = bvec;


% mat2DWInhdr(handles.user_volume_name, handles.user_data_path, dwi, 'uint16');
nii.img = [];
handles.user_nii = nii;
handles.user_dwi = dwi;

return_handles = handles;


end