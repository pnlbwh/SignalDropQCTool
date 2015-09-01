function launch_QC_Tool(mode, path, sensitivity)
% launch_QC_Tool(mode, path, sensitivity)
% 
% Use this function to launch the QC Tool
% 
% launch_QC_Tool() will simply display the interface
% 
% There are three modes available: semi-automatic, automatic or batch
% processing
% 
% 1. 'semi-automatic' mode displays a User Interface, from which you have
% access to all the control buttons. path can be an empty string 
% (path = '') or a path to a NRRD file
% 
% 2. 'automatic' mode allows you to process one particular file without
% displaying the interface
% 
% 3. 'batch' mode allows you to process all the file with a given pattern in
% a folder. Ex: path = '/project/study/diffusion/*.nhdr'
% 
% Sensitivity should be 1 or 4
% 
% On an 8-cores machine, with 12GB of RAM, it usually takes 5 minutes to compute the KL divergence for 70
% gradients direction and 100*100*70 voxels par gradients

% % % 
% Check if we need to start matlabpool
% % % 
s = matlabpool('size');
if (s < 1)
    matlabpool open;
end

% % % 
% Check inputs
% % % 

if (nargin < 1)
   main_window(); 
   return;
end

if (nargin < 2)
   path = '';
   sensitivity = 1;
end

if (nargin < 3)
   sensitivity = 1;
end


if sensitivity ~= 1 && sensitivity ~= 4
   disp('Wrong sensitivity specified');
    return; 
end


argin.user_mode = mode;
argin.user_sensitivity = sensitivity;

if strcmpi(mode, 'semi-automatic')
    
    if ~exist(path, 'file') && ~strcmpi(path, '')
            error('Input file does not exist');
    end
    argin.user_arg_path = path;
    main_window(argin);
        
elseif strcmpi(mode, 'automatic')
    
    if ~exist(path, 'file')
            error('Input file does not exist');
    end
    argin.user_arg_path = path;
    main_window(argin);
    
elseif strcmpi(mode, 'batch')
    
    list = dir(path);
    i_path = cell(numel(list));
    folder = fileparts(path);
    
    for i=1:numel(list)
        i_path{i} = fullfile(folder, list(i).name);
        argin.user_arg_path = i_path{i};
        
        argin.user_mode = 'automatic';
        
        try 
            main_window(argin);
        catch ME
           disp(ME.identifier);
           disp(['Error while processing ' i_path{i}]);
           pause(1);
        end

        
    end
    
else
    disp('Wrong mode specified');
    return; 
end





end