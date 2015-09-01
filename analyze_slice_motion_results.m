function return_handles = analyze_slice_motion_results(handles)

original_gradient_number = handles.user_results(:, 9);
handles.user_results = [];

sz = handles.user_sz;
tail_skip = handles.user_skip;
neck_skip = handles.user_neck_skip;


[max_translation_value, max_translation_location] = max(handles.user_distance_translation, [], 1);
[max_sinTheta_value, max_sinTheta_location] = max(handles.user_sinus_theta, [], 1);

max_translation_location = max_translation_location + neck_skip+1;
max_sinTheta_location = max_sinTheta_location + neck_skip+1;

suggestion = (max_translation_value < 1.5) & (max_sinTheta_value < 3e-2);
user_choice = suggestion;
confidence = suggestion;
need_review = ~confidence;

results = [max_translation_value', max_translation_location', max_sinTheta_value', max_sinTheta_location', suggestion', user_choice', confidence', need_review', original_gradient_number];

handles.user_results = [];
handles.user_results = results;
return_handles = handles;

end