function return_handles = init_main_window(handles)

% % % 
% Check if we need to start matlabpool
% % % 

check_matlab_pool();

% % % 
% Init with config file
% % % 

[path, ~, ~] = fileparts(mfilename('fullpath'));
handles.user_QC_file_path = path;


addpath(fullfile(path, '/imageToolBoxPrivateFunctions/'));
addpath(fullfile(path, '/niftiFunctions/'));
addpath(fullfile(path, '/configurationFunctions/'));
addpath(fullfile(path, '/gui_input_file/'));
addpath(fullfile(path, '/nrrdFunctions/'));

handles.user_machine_state = 'INIT';

ini = IniConfig();
ini.ReadFile('config.ini');
[~, count] = ini.GetSections();

sections = {'program', 'data'};

if (count < numel(sections))
   error('Wrong config file format'); 
end

handles.user_data_path = ini.GetValues(sections{2}, 'data_path');
handles.user_mask_path = ini.GetValues(sections{2}, 'mask_path');
handles.user_divergence_path = ini.GetValues(sections{2}, 'divergence_path');
handles.user_review_level = ini.GetValues(sections{2}, 'review_level');
handles.user_header_reference = ini.GetValues(sections{2}, 'header_reference');
handles.user_check_header = ini.GetValues(sections{2}, 'check_header');
handles.user_number_of_regions = ini.GetValues(sections{2}, 'number_of_regions');
handles.user_acquisition_dimension = ini.GetValues(sections{2}, 'acquisition_dimension');

if (handles.user_review_level > 2) || (handles.user_review_level < 0)
    handles.user_review_level = 1;
end

handles.user_acquisition_dimension = clip_data(handles.user_acquisition_dimension, [1 3]);

handles.user_volume_name = '';
handles.user_mask_name = '';



handles.user_skip = ini.GetValues(sections{1}, 'skip');
handles.user_neck_skip = ini.GetValues(sections{1}, 'neck_skip');
handles.user_threshold_empty_region = ini.GetValues(sections{1}, 'threshold_empty_region');
handles.user_suffix_QC_file = ini.GetValues(sections{1}, 'suffix_QC_file');
handles.user_suffix_QC_matrix = ini.GetValues(sections{1}, 'suffix_QC_matrix');
handles.user_suffix_divergence_matrix = ini.GetValues(sections{1}, 'suffix_divergence_matrix');

handles.user_recompute_divergence = true;
handles.user_error = false;
handles.user_isSaved = true;
handles.user_output_volume ='';
handles.user_intensity_lock = false;
handles.user_zoom_active = false;
handles.user_CLIM = [0 1];
handles.user_recreate_mask = true;
handles.user_mode = 'manual';
handles.user_isFromNifti = false;

handles.user_gradient_selected = 1;
handles.user_slice_selected = 1;
handles.user_sagittal_selected = 45;

handles.user_ini = ini;



return_handles = handles;

end