function QC_volume = create_QC_volume(dwi, decision, sz)

% We take the header from the dwi structure previously loaded
QC_volume = dwi;

% We clear the data / gradients part
QC_volume.data = [];
QC_volume.gradients = [];

number_of_good_gradients = nnz(decision(:));

if (number_of_good_gradients < 1)
    error('All the gradients are marked as bad');
end

if (number_of_good_gradients > sz(4))
   error('Error while processing the results'); 
end

QC_volume.data = uint16(zeros([sz(1:3), number_of_good_gradients]));
QC_volume.gradients = zeros(number_of_good_gradients, 1);
QC_volume.gradients = zeros(number_of_good_gradients, 3);

local_counter = 1;
for gradient_index=1:sz(4)
   
    if (decision(gradient_index) == 0)
        continue;
    end
    
    QC_volume.data(:, :, :, local_counter) = dwi.data(:, :, :, gradient_index);
    QC_volume.gradients(local_counter, :) = dwi.gradients(gradient_index, :);
    local_counter = local_counter + 1;
end

QC_volume.sizes = size(QC_volume.data);



end