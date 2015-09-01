function [transformParams, optimConfig] = computeDefaultRegmexSettings(...
    transformType,...
    mref,...
    fref)
% Compute initial transformation parameters.
%   Copyright 2012 The MathWorks, Inc.

nDims = length(mref.ImageSize);

% Currently this corresponds to an  attempt to align the images via pure
% translation along with the assumption that any (potential) rotation is
% around the center of the image, and that there's no rotation or shear.
initTranslation = [...
    mean(mref.YLimitsWorld)-mean(fref.YLimitsWorld),...
    mean(mref.XLimitsWorld)-mean(fref.XLimitsWorld),... 
    ];
if(nDims==3)
    initTranslation(3) = mean(mref.ZLimitsWorld)-mean(fref.ZLimitsWorld);
end

initScale  = 1;
initAngle  = 0;
initVersor = 0;

otherScale  = 1;
angleScale  = 1;
scaleScale  = 1;
versorScale = 1;

% Use the diagonal of the two largest extents as the scale factor for
% translation in each dimension.
fixedSize        = [fref.ImageHeightInWorld fref.ImageWidthInWorld];
if(nDims==3)
fixedSize(3)     = fref.ImageDepthInWorld;    
end

sortedSize       = sort(fixedSize);
maxTranslation   = hypot(sortedSize(1),sortedSize(2));
translationScale = otherScale/maxTranslation;
translationScale = repmat(translationScale, size(initTranslation));


switch (transformType)
    case 'affine'        
        % Affine transform matrix in row-major order followed by
        % translation vector.
        
        if(nDims==2)
            transformParams = [...
                1, 0,...
                0, 1, ...
                initTranslation];
            optimConfig = [...
                otherScale, otherScale,...
                otherScale, otherScale,...
                translationScale];
            
        else            
            transformParams = [...
                1, 0, 0,...
                0, 1, 0, ...
                0, 0, 1, ...
                initTranslation];
            optimConfig = [...
                otherScale, otherScale, otherScale, ...
                otherScale, otherScale, otherScale, ...
                otherScale, otherScale, otherScale, ...
                translationScale];
            
        end
        
    case 'similarity'        
        if(nDims==2)
            transformParams = [initScale, initAngle, initTranslation];
            optimConfig = [scaleScale, angleScale, translationScale];

        else            
            transformParams = [initVersor, initVersor, initVersor,...
                initTranslation,...
                initScale];
            optimConfig = [versorScale, versorScale, versorScale,...
                translationScale, ...                
                scaleScale];
        end
        
    case 'rigid'        
        if(nDims==2)
            transformParams = [initAngle, initTranslation];
            optimConfig = [angleScale, translationScale];            
        else
            % Euler rotation angles about x, y and z axes.
            transformParams = [initAngle, initAngle, initAngle,...
                initTranslation];
            optimConfig = [angleScale, angleScale, angleScale,...
                translationScale];
            
        end        
        
    case 'translation'        
        transformParams = initTranslation;
        optimConfig     = translationScale;
        
    otherwise        
        iptassert(false, ...
                  'images:imregister:badTransformType', transformType)
        
end

end