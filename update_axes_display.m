function return_handles = update_axes_display(handles, hObject)
% 
% This function update the display of the axes of the GUI


skip = handles.user_skip;
neck_skip = handles.user_neck_skip;
x = skip+1:1:handles.user_sz(3)-1-skip;
factor = handles.user_factor;
sz = handles.user_sz;

% % % 
% Plot the results from the divergence calculus
% % % 


if (strcmp(handles.user_machine_state, 'SIGNAL_DROP'))
    
    for i=1:factor
        for j=1:factor
            subplot(factor,factor,(j-1)*factor+i, 'Parent', handles.uipanel_display_divergence);
            cla('reset');
            divergence = squeeze(handles.user_kl_divergence(i, j, :, handles.user_gradient_selected +1));
            median = squeeze(handles.user_median_line(i, j, :, handles.user_gradient_selected +1));

            hold on
            set(gca,'XLim', [0 0.9]);
            plot(x, divergence(skip+1:end-skip), 'b');
            plot(x, median(skip+1:end-skip), 'r');


            % Plot the helpers
            plot(handles.user_slice_selected, handles.user_kl_divergence(i, j, handles.user_slice_selected, handles.user_gradient_selected +1), 'om')
            SP=handles.user_slice_selected; 
            line([SP, SP],get(gca,'YLim'),'Color','m', 'LineWidth', 1);        

            % Line at the boarder with the areas wich are not considered
            SP=handles.user_skip;
            line([SP, SP],get(gca,'YLim'),'Color',[0 0 0], 'LineWidth', 2);
            SP=sz(3)-handles.user_skip;
            line([SP, SP],get(gca,'YLim'),'Color',[0 0 0], 'LineWidth', 2);

            % Allow the user to select a slice from the plot
            set(allchild(gca),'ButtonDownFcn','main_window(''axes_divergence_ButtonDownFcn'',gca,[],guidata(gcbo))');

            % Manually set the limits
            xlim([1 sz(3)]);
            hold off

            title(['KL divergence for region ' num2str((i-1)*factor+j)], 'Color', 'w');
            xlabel('Slice number', 'Color', 'w');
            ylabel('Divergence value', 'Color', 'w');
            set(gca, 'YColor', [1 1 1]);
            set(gca, 'XColor', [1 1 1]);

        end
    end    
    
% % %     
% Plot the translation and sinus of the angle for the motion estimation
% % % 
    
elseif (strcmp(handles.user_machine_state, 'SLICE_MOTION'))
    
    % Clean the panel
    delete(findobj(handles.uipanel_display_divergence, 'type','axes'));

    x = neck_skip+1:1:handles.user_sz(3)-skip;
    
    %%%
    % Translation
    %%%
    
    subplot(2,1,1, 'Parent', handles.uipanel_display_divergence);
    
    cla('reset');
    y = handles.user_distance_translation(:, handles.user_gradient_selected +1);
    plot(x, y, 'b');
    
    % Plot the helpers
    hold on;
    
    if clip_data(handles.user_slice_selected - neck_skip -1, [1 length(y)]) == handles.user_slice_selected - neck_skip -1
        plot(handles.user_slice_selected-1, y(handles.user_slice_selected - neck_skip -1), 'om');
        SP=handles.user_slice_selected-1; 
        line([SP, SP],get(gca,'YLim'),'Color','m', 'LineWidth', 1);         
    end
    
    % Allow the user to select a slice from the plot
    set(allchild(gca),'ButtonDownFcn','main_window(''axes_divergence_ButtonDownFcn'',gca,[],guidata(gcbo))');
    hold off;
    
    % Set the title
    title(['Translation (in number of pixels) between slices ' num2str(handles.user_slice_selected-1) ' and ' num2str(handles.user_slice_selected)], 'Color', 'w');
    xlabel('Slice number', 'Color', 'w');
    ylabel('Translation', 'Color', 'w');
    set(gca, 'YColor', [1 1 1]);
    set(gca, 'XColor', [1 1 1]);
    
    %%%
    % Rotation
    %%%
    subplot(2,1,2, 'Parent', handles.uipanel_display_divergence);

    cla('reset');
    y = handles.user_sinus_theta(:, handles.user_gradient_selected +1);
    plot(x, y, 'r');
    
    % Plot the helpers
    hold on;
    
%     if (main_window('clip_data', handles.user_slice_selected - neck_skip -1, [1 length(y)]) == handles.user_slice_selected - neck_skip -1)
    if (clip_data(handles.user_slice_selected - neck_skip -1, [1 length(y)]) == handles.user_slice_selected - neck_skip -1)
        plot(handles.user_slice_selected-1, y(handles.user_slice_selected - neck_skip -1), 'om');
        SP=handles.user_slice_selected-1; 
        line([SP, SP],get(gca,'YLim'),'Color','m', 'LineWidth', 1);         
    end
    
    % Allow the user to select a slice from the plot
    set(allchild(gca),'ButtonDownFcn','main_window(''axes_divergence_ButtonDownFcn'',gca,[],guidata(gcbo))');
    hold off;
    
    % Set the title
    title(['Sinus of the angle (in radians) between slices ' num2str(handles.user_slice_selected-1) ' and ' num2str(handles.user_slice_selected)], 'Color', 'w');
    xlabel('Slice number', 'Color', 'w');
    ylabel('Sinus Theta', 'Color', 'w');
    set(gca, 'YColor', [1 1 1]);
    set(gca, 'XColor', [1 1 1]);


    
end



% % % 
% Plot the selected slices on the axes
% % % 



% *** check LPS, RAS, ...

if ((strcmp(handles.user_machine_state, 'SIGNAL_DROP')) || strcmp(handles.user_machine_state, 'SLICE_MOTION') ) 
    
    % Normal mode: 
    if (handles.user_zoom_active == false)
        selected_axes = {handles.axes_axial_before, handles.axes_axial_middle, handles.axes_axial_after};
        
    % Zoom mode
    else
        selected_axes = {handles.axes_zoom};
    end
    
    CLIM = [handles.user_CLIM, 0];
    for this_axe=-1:length(selected_axes)-2
        
        if isempty(selected_axes{this_axe+2})
           continue; 
        end
        
        axes(selected_axes{this_axe+2});

        % Bound the value for the slice selection
        if (clip_data(handles.user_slice_selected + this_axe +1, [1 sz(3)]) ~= handles.user_slice_selected + this_axe +1)
            imagesc(zeros(sz(1:2))');
        else
            % We want the 3 slices to have the same intensity scale
            slice = handles.user_dwi.data(:, :, handles.user_slice_selected + this_axe +1, handles.user_gradient_selected +1);
            if (CLIM(3) == 0) && (handles.user_intensity_lock == false)
                range = clip_data(handles.user_slice_selected + this_axe, [1 sz(3)]):1:clip_data(handles.user_slice_selected + this_axe +2, [1 sz(3)]);
                intensities = handles.user_dwi.data(:, :, range, handles.user_gradient_selected +1);
                CLIM(1) = min(intensities(:));
                CLIM(2) = max(intensities(:));
                CLIM(3) = 1;
                handles.user_CLIM = CLIM(1:2);
                
            end
            imagesc(slice', CLIM(1:2));
        end

        % Plot the circle which help seeing wich sagittal slice is selected
        hold on
        plot(handles.user_sagittal_selected, 2, 'ob');
        plot(handles.user_sagittal_selected, sz(2)-1, 'ob'); %*** sz(1|2)
        hold off

        set(allchild(gca),'ButtonDownFcn','main_window(''axes_axial_middle_ButtonDownFcn'',gca,[],guidata(gcbo))');

        colormap gray, axis image;
        set(gca,'xtick',[]);
        set(gca,'xticklabel',[]);
        set(gca,'yticklabel',[]);

        title(['Slice ' num2str(handles.user_slice_selected + this_axe +1)], 'Color', 'w');


        
    end
end


% % % 
% Plot one sagittal view
% % % 

axes(handles.axes_sagittal);
handles.user_sagittal_selected = clip_data(handles.user_sagittal_selected, [1 sz(1)-1]);
imagesc(rot90(squeeze(handles.user_dwi.data(handles.user_sagittal_selected+1, :, :, handles.user_gradient_selected +1))));

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

title(['Slice ' num2str(handles.user_sagittal_selected)], 'Color', 'w');






return_handles = handles;




end

