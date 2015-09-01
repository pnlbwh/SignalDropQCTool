function tform = convertWorldRegtoIntrinsic(fref, mref, rotationMatrix, translationVector)
% Convert the regmex registration parameters to a tform struct


% The incoming rotation and translation information aligns the *fixed* to
% the *moving*.

if(isa(fref,'images.spatialref.internal.imref3d'))
    % 3D
    nDims = 3;
    rotCentOffset = [mean(fref.YLimitsWorld) mean(fref.XLimitsWorld) mean(fref.ZLimitsWorld)];
    
else
    % 2D
    nDims = 2;
    rotCentOffset = [mean(fref.YLimitsWorld) mean(fref.XLimitsWorld)];  
end

% Use a composite affine transform matrix to perform the conversion.
A1 = eye(nDims+1);
A2 = eye(nDims+1);
A3 = eye(nDims+1);
A4 = eye(nDims+1);

% Affine transform to move origin to center of fixed image.
A1(end,1:nDims)     = -rotCentOffset;
% Rotation about the center of the *fixed* image to register it to the *moving*.
A2(1:nDims,1:nDims) = rotationMatrix;
% Move origin back
A3(end,1:nDims)     = rotCentOffset;

% Compute the final rotation about the first pixel of the fixed image
finalTransform = A1*A2*A3;

% Include the computed registration translation. This moves the *fixed* to
% the *moving*.
A4(end, 1:nDims) = translationVector;
finalTransform   = finalTransform*A4;

% While optimizing, regmex works with a transform which moves the fixed image
% to the moving image space. Invert the transform to obtain coefficients to
% register the moving to the fixed.
%tWorld=inv(finalTransform);               % use / later instead of inv now


if(isa(fref,'images.spatialref.internal.imref3d'))

    % 3D       
    t1 = [ 1     0     0     0
           0     1     0     0
           0     0     1     0
          -0.5  -0.5  -0.5   1];
    t2 =[
        fref.DeltaY  0           0            0
        0            fref.DeltaX 0            0
        0            0           fref.DeltaZ  0
        0            0           0            1];
    t3 = [ 
        1                       0                       0                       0
        0                       1                       0                       0
        0                       0                       1                       0
        fref.FirstCornerY       fref.FirstCornerY       fref.FirstCornerZ       1];
    tFixedToWorld = t1*t2*t3;
    
    
    t1 = [ 1     0     0     0
           0     1     0     0
           0     0     1     0
          -0.5  -0.5  -0.5   1];
    t2 =[
        mref.DeltaY  0           0            0
        0            mref.DeltaX 0            0
        0            0           mref.DeltaZ  0
        0            0           0            1];
    t3 = [ 
        1                       0                       0                       0
        0                       1                       0                       0
        0                       0                       1                       0
        mref.FirstCornerY       mref.FirstCornerY       mref.FirstCornerZ       1];
    tMovingToWorld = t1*t2*t3;

    
    % Use / over inv(), the comments below are for the theory of operation.
    %t = tMovingToWorld * tWorld              * inv(tFixedToWorld);
    %t = tMovingToWorld * inv(finalTransform) /     tFixedToWorld;
    t = tMovingToWorld  /     finalTransform  /     tFixedToWorld;
    
    t(:,4) =[ 0; 0; 0; 1]; % Account for round-off in inversion.
    
else
    % 2D
    t1 = [   1       0     0
             0       1     0
          -0.5    -0.5     1];
    t2 =[
        fref.DeltaY  0           0
        0            fref.DeltaX 0
        0            0           1];
    t3 = [ 
        1                       0                       0
        0                       1                       0
        fref.FirstCornerY       fref.FirstCornerX   1];    
    tFixedToWorld = t1*t2*t3;
    
    
    t1 = [   1       0     0
             0       1     0
          -0.5    -0.5     1];
    t2 =[
        mref.DeltaY  0           0
        0            mref.DeltaX 0
        0            0           1];
    t3 = [ 
        1                       0                       0
        0                       1                       0
        mref.FirstCornerY       mref.FirstCornerX       1];    
    tMovingToWorld = t1*t2*t3;
       
    
    
    % Use / over inv(), the comments below are for theory of operation.
    %t = tMovingToWorld *     tWorld          * inv(tFixedToWorld);
    %t = tMovingToWorld * inv(finalTransform) /     tFixedToWorld;
    t =  tMovingToWorld /     finalTransform  /     tFixedToWorld;    
    t(:,3) =[ 0; 0; 1]; % Account for round-off in inversion.
     
end


if(nDims==2)
    % The 2D tform is intended for use with imtransform. imtransform treats
    % the first dimension as x and the second as y. To comply, We need to
    % flip the  order of the dimension in the affine transform here. See
    % internal tech ref for more details.
    t(1:2,1:2) = t(1:2,1:2)';
    % Flip the translation vector 
    t(end,1:2) = fliplr(t(end,1:2));
%else
%
%   nothing to do, we use tformarray.   
%
end


tform = maketform('affine',t);

end

