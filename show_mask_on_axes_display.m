function show_mask_on_axes_display(handles, hObject)

mask = uint16(handles.user_mask.img); % ***
factor = handles.user_factor;
sz = handles.user_sz;

% % % 
% Plot the selected slices
% % % 

% Check ***
if (handles.user_slice_selected == 0) || (handles.user_slice_selected == handles.user_sz(3))
	error('Non supported');
end

selected_axes = {handles.axes_axial_before, handles.axes_axial_middle, handles.axes_axial_after};

% *** check LPS, RAS, ...
CLIM = [0 1 0];
for this_axe=-1:length(selected_axes)-2
    axes(selected_axes{this_axe+2});
    
    % Bound the value for the slice selection
    if (clip_data(handles.user_slice_selected + this_axe +1, [1 sz(3)]) ~= handles.user_slice_selected + this_axe +1)
        imagesc(zeros(sz(1:2))');
    else
        % We want the 3 slices to have the same high and low colors
        slice = uint16(handles.user_dwi.data(:, :, handles.user_slice_selected + this_axe +1, handles.user_gradient_selected +1));
        slice = slice .* mask(:, :, handles.user_slice_selected + this_axe +1) + max(slice(:))/2*mask(:, :, handles.user_slice_selected + this_axe +1);
        
        if (CLIM(3) == 0)
            CLIM(1) = min(slice(:));
            CLIM(2) = max(slice(:));
            CLIM(3) = 1;
        end
        imagesc(slice', CLIM(1:2));
    end
    
    colormap gray, axis image;
    set(gca,'xtick',[]);
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);

    % Plot the circle which help seeing wich sagittal slice is selected
    hold on
    plot(handles.user_sagittal_selected, 2, 'ob');
    plot(handles.user_sagittal_selected, sz(2)-1, 'ob');
    
    % Plot the regions if factor == 2
    if (factor == 2)
       SP = round(sz(1)/2);
       line([SP SP], get(gca,'YLim'), 'Color',[0.9 0.9 0.9], 'LineWidth', 2);
       
       SP = round(sz(2)/2);
       plot([0 sz(1)-1], [SP SP], 'Color',[0.9 0.9 0.9], 'LineWidth', 2);
    end
    hold off
    
    % Make the slices interactive  
    set(allchild(gca),'ButtonDownFcn','main_window(''axes_axial_middle_ButtonDownFcn'',gca,[],guidata(gcbo))');
    

    



end

% % % 
% Plot one sagittal view
% % % 

% *** orientation (LPS, RAS)
axes(handles.axes_sagittal);

sag_slice = handles.user_dwi.data(handles.user_sagittal_selected+1, :, :, handles.user_gradient_selected +1);
sag_slice = uint16(sag_slice);
sag_slice = sag_slice.* mask(handles.user_sagittal_selected+1, :, :) + max(sag_slice(:))/2*mask(handles.user_sagittal_selected+1, :, :);
imagesc(rot90(squeeze(sag_slice)));

% Plot the circle which help seeing wich axial slice is selected
hold on
    plot(2, sz(3) - handles.user_slice_selected, 'ob');
    plot(sz(2)-1, sz(3) -handles.user_slice_selected, 'ob');%*** sz(1|2)
hold off

set(allchild(gca),'ButtonDownFcn','main_window(''axes_sagittal_ButtonDownFcn'',gca,[],guidata(gcbo))');

colormap gray, axis image;
set(gca,'xtick',[]);
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);




end