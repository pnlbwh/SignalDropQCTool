function return_handles = estimate_slice_movement(handles)

% % % 
% We first define the optimizer and the metric
% Optimizer: gradient descent
% Metric: Least Square
% % % 

[optimizer, metric]  = imregconfig('monomodal');

sz = handles.user_sz;
sinus_theta = zeros(sz(3) - handles.user_skip - handles.user_neck_skip, sz(4));
distance_translation = zeros(sz(3) - handles.user_skip - handles.user_neck_skip, sz(4));

% We then process each gradient

parfor gradient_index = 1:sz(4)

    data = handles.user_dwi.data(:, :, :, gradient_index);
    
    % Apply mask
    data(~logical(handles.user_mask.img)) = 0; % *** img
    
    distance_translation_local = zeros(sz(3) - handles.user_skip - handles.user_neck_skip, 1);
    sinus_theta_local = zeros(sz(3) - handles.user_skip - handles.user_neck_skip, 1);
    
    for slice_index=handles.user_neck_skip:sz(3)-1-handles.user_skip
        fixed = data(:, :, slice_index);
        moving = data(:, :, slice_index+1);
        [~, tform] = my_imregister(moving,fixed,'rigid',optimizer,metric);

        sinT_local = tform.tdata.T(1, 2);

        xt = tform.tdata.T(3, 1);
        yt = tform.tdata.T(3, 2);

        distanceT_local = sqrt(xt^2 + yt^2);

        distance_translation_local(slice_index-handles.user_neck_skip+1) = distanceT_local;
        sinus_theta_local(slice_index-handles.user_neck_skip+1) = abs(sinT_local);

    end
    distance_translation(:, gradient_index) = distance_translation_local;
    sinus_theta(:, gradient_index) = sinus_theta_local;
end


handles.user_distance_translation = distance_translation;
handles.user_sinus_theta = sinus_theta;


return_handles = handles;

end