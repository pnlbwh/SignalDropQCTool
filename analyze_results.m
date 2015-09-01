function return_handles = analyze_results(handles)

sz = handles.user_sz;
factor = handles.user_factor;
skip = handles.user_skip;

% % % 
% Mask
% % % 

% We mask the values at the beggining and at the end of the gradients
mask_distance = zeros(sz(3)-1, 1);
mask_distance(skip+1:end-skip) = 1; 
mask_distance = logical(mask_distance);
mask_distance = reshape(mask_distance, [1, 1, length(mask_distance), 1]);
mask_distance_rep = repmat(mask_distance, [factor, factor, 1, sz(4)]);
mask_distance_rep = ~mask_distance_rep;

% We do not take into account these values, so we set them to -1
handles.user_absolute_distance_to_median(mask_distance_rep) = -1; 
handles.user_relative_distance_to_median(mask_distance_rep) = -1;
kl_divergence = handles.user_kl_divergence;
kl_divergence(mask_distance_rep) = -1;

% reminder SIZE(absolute_maximum_locations) = [factor, factor, number of gradients]
% [absolute_maximum_value, absolute_maximum_locations] = max(handles.user_absolute_distance_to_median, [], 3);
% [relative_maximum_value, relative_maximum_locations] = max(handles.user_relative_distance_to_median, [], 3);



% % % 
% Find the maximum, regardless of the region number
% % % 

absolute_distance_to_median = reshape(handles.user_absolute_distance_to_median, [handles.user_number_of_regions, size(handles.user_absolute_distance_to_median, 3), size(handles.user_absolute_distance_to_median, 4)]);
relative_distance_to_median = reshape(handles.user_relative_distance_to_median, [handles.user_number_of_regions, size(handles.user_relative_distance_to_median, 3), size(handles.user_relative_distance_to_median, 4)]);
maximum_divergence = reshape(kl_divergence, [handles.user_number_of_regions, size(handles.user_relative_distance_to_median, 3), size(handles.user_relative_distance_to_median, 4)]);

[absolute_maximum_distance, absolute_maximum_locations] = max(max(absolute_distance_to_median, [], 1), [], 2);
[relative_maximum_distance, relative_maximum_locations] = max(max(relative_distance_to_median, [], 1), [], 2);
[maximum_divergence_value, maximum_divergence_location] = max(max(maximum_divergence, [], 1), [], 2);

absolute_maximum_distance = squeeze(absolute_maximum_distance);
absolute_maximum_locations = squeeze(absolute_maximum_locations);
relative_maximum_distance = squeeze(relative_maximum_distance);
relative_maximum_locations = squeeze(relative_maximum_locations);
maximum_divergence_value = squeeze(maximum_divergence_value);
maximum_divergence_location = squeeze(maximum_divergence_location);

% absolute_distance_to_median_positive = absolute_distance_to_median;
% absolute_distance_to_median_positive(absolute_distance_to_median_positive<0) = 0;
% total_error = squeeze(sum(sum(absolute_distance_to_median_positive, 2, 'double'), 1, 'double'));

% % % 
% Compute the suggestion
% % % 

suggestion = ((absolute_maximum_distance<0.15)) & (relative_maximum_distance < 10); %(relative_maximum_distance < 6 ) | 
confidence = ~((((relative_maximum_distance < 20) & (absolute_maximum_distance < 0.3)) | ((relative_maximum_distance >= 20) & (absolute_maximum_distance < 0.1))) & (suggestion == 0)) & ...
                ~((suggestion == 1) & ((relative_maximum_distance > 2) & (absolute_maximum_distance > 0.1) | relative_maximum_distance > 6 | maximum_divergence_value > 0.1));
user_choice = suggestion; % At the begining, the user choice is the default suggestion

% Review level
switch(handles.user_review_level)
    case 1
        need_review = ~confidence;
    case 2
        need_review = true(length(confidence));
    otherwise
        need_review = false(length(confidence));
end

original_gradient_number = 0:1:sz(4)-1;

results = [absolute_maximum_distance, absolute_maximum_locations, relative_maximum_distance, relative_maximum_locations, suggestion, user_choice, confidence, need_review, original_gradient_number'];


% Update the first slice to see for gradient 0:
handles.user_gradient_selected = 0;
handles.user_slice_selected = relative_maximum_locations(1);

% % % 
% Save the results
% % % 

handles.user_absolute_maximum_locations = absolute_maximum_locations;
handles.user_absolute_maximum_value = absolute_maximum_distance;

handles.user_relative_maximum_locations = relative_maximum_locations;
handles.user_relative_maximum_value = relative_maximum_distance;

handles.user_maximum_divergence_value = maximum_divergence_value;
handles.user_maximum_divergence_location = maximum_divergence_location;

handles.user_results = results;

return_handles = handles;

end