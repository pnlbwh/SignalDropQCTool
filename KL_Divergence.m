function [result, err] = KL_Divergence(p, q)

err = false;
result = 0;

% Check input sizes
if (sum(abs(size(p) - size(q))) ~= 0)
    warning('Sizes of p and q are differents');
    err = true;
    return;
end

% Check zero values
zero_p = p<eps;
zero_q = q<eps;

if (nnz(zero_p) > 0)
   p = p+eps; 
end

if (nnz(zero_q) > 0)
   q = q+eps; 
end

% Normalize
p = p./sum(p);
q = q./sum(q);



result = p.*log(p./q);
result = sum(result, 2);


end

