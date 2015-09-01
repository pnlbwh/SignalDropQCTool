function return_handles = process_scan(handles)


% % % 
% Preparing local variables
% % % 

% Assumptions:
% 1. 4D stacked along 3rd axis (0, 1, 2, 3)
% 2. Number of region is properly fixed
% 3. Matlab pool started

number_of_regions = handles.user_number_of_regions;
factor = round(sqrt(number_of_regions));
disp(['Using ' num2str(number_of_regions) ' regions']);

sz = size(handles.user_dwi.data);

% % % 
% Check that sizes are consistent
% % % 

if (nnz(sz(1:3)- size(handles.user_mask.img)) ~= 0)
    display_message(true, handles, 'Error, size of mask and size of diffusion volumes should be identical');
    error('Error, size of mask and size of diffusion volumes should be identical'); 
end

kl_divergence = zeros(factor, factor, sz(3)-1, sz(4));
bval = zeros(sz(4), 1);

data = double(handles.user_dwi.data);
bvalue = handles.user_dwi.bvalue;
gradients = handles.user_dwi.gradients;

% *** img in processing later...
mask = handles.user_mask.img;

% % % 
% Process each gradient in parallel
% % % 



if (handles.user_recompute_divergence == true)
    
    parfor gradient_index=1:sz(4)

        bval(gradient_index) = bvalue * norm(gradients(gradient_index, :), 2)^2;

        volume = data(:, :, :, gradient_index);
        slice_kl_divergence = zeros(factor, factor, sz(3)-1);

        slice_a = volume(:, :, 1);
        mask_a = mask(:, :, 1);

        % We skip the last slice
        for slice_index = 1:sz(3)-1
            slice_b = volume(:, :, slice_index+1);
            mask_b = mask(:, :, slice_index+1);

            results = ImageToKLDivergenceMask(slice_a, slice_b, mask_a, mask_b, number_of_regions, handles.user_threshold_empty_region);

            slice_kl_divergence(:, :, slice_index) = results;
            slice_a = slice_b;
            mask_a = mask_b;
        end


        kl_divergence(:, :, :, gradient_index) = slice_kl_divergence(:, :, :);

    end
   
else
    handles = load_input_files(handles, 'KL_DIV');
    kl_divergence = handles.user_kl_divergence;
    
    if (size(kl_divergence,4) ~= size(handles.user_dwi.data, 4))
        display_message(true, handles, 'Error, the KL divergence matrix loaded has not the same number of gradients as the diffusion data');
        error('Error, the KL divergence matrix loaded has not the same number of gradients as the diffusion data'); 
    end
end
    


% % % 
% Compute the median measures
% % % 

epsilon = 0.2;
group_range = [50, 800];
BSHELL = extract_Bshells(bval, epsilon, group_range);


absolute_distance_to_median = -1*ones(factor, factor, sz(3)-1, sz(4));
relative_distance_to_median = -1*ones(factor, factor, sz(3)-1, sz(4));
median_line = zeros(factor, factor, sz(3)-1, sz(4));


% For each B-Value
for bval_request=[BSHELL, -1]
    
    % Create the masks
    if (bval_request == -1)
        mask_bval = (bval > group_range(1)) & (bval < group_range(2));
    else
        mask_bval = (bval <= bval_request * (1+ epsilon)) & (bval >= bval_request * (1- epsilon));
    end
    
    mask_bval_reshaped = reshape(mask_bval, [1,1,length(mask_bval)]);
    mask_bval_rep = repmat(mask_bval_reshaped, [factor, factor, 1]);
    
    % ***Optimize this (no for loop, line 2D)
    % Compute the median value for this B-Shell, for each slice
    local_median_line = zeros(factor, factor, sz(3)-1);
    for slice_index=1:sz(3)-1
        slices = squeeze(kl_divergence(:, :, slice_index, :));
        slices_at_given_b_value = slices(mask_bval_rep);
        slices_at_given_b_value = reshape(slices_at_given_b_value, [factor, factor, round(length(slices_at_given_b_value)/number_of_regions)]);

        local_median_line(:, :, slice_index) = median(slices_at_given_b_value, 3);

    end    
    
    
    
    % Optimize this
    for i=1:length(bval)
                
       if (mask_bval(i) == 0)
          continue;
       end
       
       if (nnz(mask_bval) < 2)
           local_median_line(:, :, :) = 0.01;
       end
       
       median_line(:, :, :, i) = local_median_line;
       

      for region_index=1:number_of_regions

          [x, y] = ind2sub([factor, factor], region_index) ;
          local_kl_divergence = squeeze(kl_divergence(x, y, :, :));
          local_line = squeeze(local_median_line(x, y, :));

          absolute_distance_to_median(x, y, :,i) = local_kl_divergence(:, i) - local_line(:);
          
          local_line(local_line == 0) = eps; % make sure we don't divide by zero.
          relative_distance_to_median(x, y, :,i) = (local_kl_divergence(:, i) - local_line(:)) ./ local_line(:); 

      end             
       
    end
    
    
end



% % % 
% Update variables
% % % 

handles.user_kl_divergence = kl_divergence;
handles.user_bval = bval;
handles.user_factor = factor;
handles.user_sz = sz;
handles.user_median_line = median_line;
handles.user_absolute_distance_to_median = absolute_distance_to_median;
handles.user_relative_distance_to_median = relative_distance_to_median;

return_handles = handles;

end