function result = ImageToKLDivergenceMask(image_a, image_b, mask_a, mask_b, number_of_regions, threshold_empty_region)

% % % 
% Check the input parameters
% % % 

if (nnz(size(image_a) - size(image_b) + size(mask_a) - size(mask_b) + size(mask_a) - size(image_b)) ~= 0)
   error('Images dimension mismatch'); 
end

if (length(size(image_a)) > 2)
   error('2D images only') ;
end


factor = sqrt(number_of_regions);

if (abs(round(factor) - factor) > 0.001)
    error('Sqrt of the number of region is not an integer');
end

factor = round(factor);

sz = size(image_a);

if (abs(round(sz(1)/factor)) -sz(1)/factor > 0.001) || (abs(round(sz(1)/factor) -sz(1)/factor) > 0.001)
   error('Image size is not divisible into this number of regions, non integer result') ;
end

% If the mask is empty
if (nnz(mask_a) < 1) || (nnz(mask_b) < 1)
    result = zeros(factor, factor);
    return;
end





result = zeros(factor, factor);

for i=1:factor
    
    for j=1:factor
        
        a = round(sz(1)/factor*(i-1)+1);
        b = round(sz(1)/factor*(i));
        c = round(sz(2)/factor*(j-1)+1);
        d = round(sz(2)/factor*(j));
        
        area_a = image_a(a:b, c:d);
        area_b = image_b(a:b, c:d);
        
        % If the region is empty
        if (nnz(mask_a(a:b, c:d)) < 1) || (nnz(mask_b(a:b, c:d)) < 1)
            result(i, j) = 0;
            continue;
        end
       
        % % % 
        % When we use multiple regions, it could be a good idea to count the number
        % of pixels. If this number is too low, maybe we should ignore the related
        % KL-Divergence value.
        % % % 

        if (nnz(mask_a(a:b, c:d)) < threshold_empty_region) || (nnz(mask_b(a:b, c:d)) < threshold_empty_region)
            result(i, j) = 0;
            continue;
        end
        
        region_a = area_a(logical(mask_a(a:b, c:d)));
        region_b = area_b(logical(mask_b(a:b, c:d)));


        if (max(region_a(:)) < max(region_b(:)))
            [p, xi, bw] = ksdensity(region_b(:), 'npoints', 1000);
            q = ksdensity(region_a(:), xi, 'width', bw, 'npoints', 1000);
        else
           [p, xi, bw] = ksdensity(region_a(:), 'npoints', 1000);
            q = ksdensity(region_b(:), xi, 'width', bw, 'npoints', 1000); 
        end

        kl_ab = 0.5 * (KL_Divergence(p, q) + KL_Divergence(q, p));
        result(i, j) = kl_ab;
    end
end

end