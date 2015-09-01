function [moving_reg, tform] = my_imregister(varargin)
%IMREGISTER Register two 2-D or 3-D images using intensity metric optimization.
%
%   MOVING_REG = IMREGISTER(MOVING, FIXED, TRANSFORMTYPE, OPTIMIZER,
%   METRIC) transforms the moving image MOVING so that it is spatially
%   registered with the FIXED image. TRANSFORMTYPE is a string that defines
%   the type of transformation to perform. OPTIMIZER is an object that
%   describes the method for optimizing the metric. METRIC is an object
%   that defines the quantitative measure of similarity between the images
%   to optimize.  The output MOVING_REG is a transformed version of MOVING.
%
%   TRANSFORMTYPE is a string specifying one of the following geometric
%   transform types:
%
%      TRANSFORMTYPE         TYPES OF DISTORTION
%      -------------         -----------------------
%      'translation'         Translation
%      'rigid'               Translation, Rotation
%      'similarity'          Translation, Rotation, Scale
%      'affine'              Translation, Rotation, Scale, Shear
%
%   The 'similarity' and 'affine' transform types always involve
%   nonreflective transformations.
%
%   [...] = IMREGISTER(...,PARAM1,VALUE1,PARAM2,VALUE2,...) registers the
%   moving image using name-value pairs to control aspects of the
%   registration.
%
%   Parameters include:
%
%      'DisplayOptimization'   - A logical scalar specifying whether or
%                                not to display optimization information
%                                to the MATLAB command prompt. The default
%                                is false.
%                                
%      'PyramidLevels'         - The number of multi-level image pyramid
%                                levels to use. The default is 3.
%
%   Class Support
%   -------------
%   MOVING and FIXED are numeric matrices.  TRANSFORMTYPE is a string.
%   METRIC_CONFIG is an object from the registration.metric package.
%   OPTIMIZER_CONFIG is an object from the registration.optimizer package.
%
%   Notes
%   -------------
%   Getting good results from optimization-based image registration usually
%   requires modifying optimizer and/or metric settings for the pair of
%   images being registered.  The imregconfig function provides a default
%   configuration that should only be considered a starting point. See the
%   output of the imregconfig for more information on the different
%   parameters that can be modified.
%   
%   Example 
%   -------------
%   % Read in two slightly misaligned magnetic resonance images of a knee
%   % obtained using different protocols.
%   fixed  = dicomread('knee1.dcm');
%   moving = dicomread('knee2.dcm');
%
%   % View misaligned images
%   imshowpair(fixed, moving,'Scaling','joint');
%
%   % Get a configuration suitable for registering images from different
%   % sensors.
%   [optimizer, metric] = imregconfig('multimodal')
%
%   % Tune the properties of the optimizer to get the problem to converge
%   % on a global maxima and to allow for more iterations.
%   optimizer.InitialRadius = 0.009;
%   optimizer.Epsilon = 1.5e-4;
%   optimizer.GrowthFactor = 1.01;
%   optimizer.MaximumIterations = 300;
%
%   % Align the moving image with the fixed image
%   movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);
%
%   % View registered images
%   figure
%   imshowpair(fixed, movingRegistered,'Scaling','joint');
%   
%   See also IMREGCONFIG, IMSHOWPAIR, IMTRANSFORM,
%   registration.metric.MattesMutualInformation,
%   registration.metric.MeanSquares,
%   registration.optimizer.RegularStepGradientDescent
%   registration.optimizer.OnePlusOneEvolutionary

%   Copyright 2011-2012 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $ $Date: 2012/05/06 02:42:26 $

parsedInputs = parseInputs(varargin{:});

parsedInputs.InitialParams = [];

moving             = parsedInputs.MovingImage;
mref               = parsedInputs.MovingRef;
fixed              = parsedInputs.FixedImage; 
fref               = parsedInputs.FixedRef;
transformType      = parsedInputs.TransformType;
dispOptim          = parsedInputs.DisplayOptimization;
transformParams    = parsedInputs.InitialParams;
optimObj           = parsedInputs.OptimConfig;
metricConfig       = parsedInputs.MetricConfig;
pyramidLevels      = parsedInputs.PyramidLevels;

% Obtain the default optimization parameters and the corresponding scales
[defaultTransformParams, defaultOptimScales] = ...
    computeDefaultRegmexSettings(transformType,...
    mref,...
    fref);

% Use the defaults transform parameters as initial conditions for the
% optimizer if required.
if (isempty(transformParams))
  transformParams = defaultTransformParams;
else    
    numParamsExpected = numel(defaultTransformParams);
    numParamsGiven    = numel(transformParams);
    iptassert( numParamsGiven== numParamsExpected , ...
        'images:imregister:badInitialParams', ...
        numel(transformParams), ...
        numel(defaultTransformParams))
end

% Set the optimizer scales.
optimObj.Scales = defaultOptimScales;

% Extract required spatial info
if(isa(mref,'images.spatialref.internal.imref3d'))
    mspacing = [mref.DeltaY mref.DeltaX mref.DeltaZ];
    [mfirstx, mfirsty, mfirstz] = mref.intrinsicToWorld(1,1,1);
    mfirst   = [mfirsty mfirstx mfirstz];

    fspacing = [fref.DeltaY fref.DeltaX fref.DeltaZ];
    [ffirstx, ffirsty, ffirstz] = fref.intrinsicToWorld(1,1,1);
    ffirst   = [ffirsty ffirstx ffirstz];
else
% assume 2d

    mspacing = [mref.DeltaY mref.DeltaX];
    [mfirstx, mfirsty] = mref.intrinsicToWorld(1,1);
    mfirst   = [mfirsty mfirstx];

    fspacing = [fref.DeltaY fref.DeltaX];
    [ffirstx, ffirsty] = fref.intrinsicToWorld(1,1);
    ffirst   = [ffirsty ffirstx];

end


% Cast images to double before handing to regmex.
[rotationMatrix, translationVector] = ...
    regmex(...
    double(moving), ...
    mfirst,...
    mspacing,...
    double(fixed),...
    ffirst,...
    fspacing,...
    dispOptim,...
    transformType, ...
    transformParams, ...
    optimObj, ...
    metricConfig,...
    pyramidLevels);

% Convert the mex registration parameters to a tform struct
tform = convertWorldRegtoIntrinsic(...
    fref,...
    mref,...
    rotationMatrix,...
    translationVector);

% Register the moving image to the fixed image using the tform struct
moving_reg = transformMovingImage(moving, fixed, tform);

if dispOptim
    % Display final transform coefficients
    printTransformCoefficients(tform);
end
   
end


% Parse inputs
function parsedInputs = parseInputs(varargin)

parser = inputParser();

parser.addRequired('MovingImage',  @checkMovingImage);
parser.addRequired('FixedImage',   @checkFixedImage);
parser.addRequired('TransformType',@checkTransform);
parser.addRequired('OptimConfig',  @checkOptim);
parser.addRequired('MetricConfig', @checkMetric);

parser.addParamValue('DisplayOptimization', false, @checkDisplay);
parser.addParamValue('PyramidLevels',3,@checkPyramidLevels);

% Function scope for partial matching
parsedTransformString = '';

% Parse input, replacing partial name matches with the canonical form.
if (nargin > 5)
  varargin(6:end) = remapPartialParamNames({'DisplayOptimization', 'PyramidLevels'}, ...
                                           varargin{6:end});
end

parser.parse(varargin{:});

parsedInputs = parser.Results;

% Make sure that there are enough pixels in the fixed and moving images for
% the number of pyramid levels requested.
validatePyramidLevels(parsedInputs.FixedImage,parsedInputs.MovingImage, parsedInputs.PyramidLevels);

% ensure that the number of dimensions match.
if(ndims(parsedInputs.FixedImage) ~= ndims(parsedInputs.MovingImage))
    error(message('images:imregister:dimMismatch'));
end

% Allows us to be consistent with rest of toolbox in allowing scalar
% numeric values to be used interchangeably with logicals.
parsedInputs.DisplayOptimization = logical(parsedInputs.DisplayOptimization);


% Create default spatial reference objects
if(ndims(parsedInputs.MovingImage)==3)
    parsedInputs.MovingRef = images.spatialref.internal.imref3d(...
        size(parsedInputs.MovingImage),1,1,1,  .5,.5,.5);
    parsedInputs.FixedRef  = images.spatialref.internal.imref3d(...
        size(parsedInputs.FixedImage) ,1,1,1,  .5,.5,.5);
else
    % assume 2D
    parsedInputs.MovingRef = images.spatialref.internal.imref(...
        size(parsedInputs.MovingImage),1,1,  .5,.5);
    parsedInputs.FixedRef  = images.spatialref.internal.imref(...
        size(parsedInputs.FixedImage) ,1,1,  .5,.5);
end


parsedInputs.TransformType = parsedTransformString;


    function tf = checkPyramidLevels(levels)
        
        validateattributes(levels,{'numeric'},{'scalar','real','positive','nonnan'},'imregister','PyramidLevels');
        
        tf = true;
        
    end

    function tf = checkOptim(optimConfig)
       
        validOptimizer = isa(optimConfig,'registration.optimizer.RegularStepGradientDescent') ||...
                         isa(optimConfig,'registration.optimizer.GradientDescent') ||...
                         isa(optimConfig,'registration.optimizer.OnePlusOneEvolutionary');
                     
        if ~validOptimizer
           error(message('images:imregister:invalidOptimizerConfig'))
        end
        tf = true;
        
    end

    function tf = checkMetric(metricConfig)
       
        validMetric = isa(metricConfig,'registration.metric.MeanSquares') ||...
                      isa(metricConfig,'registration.metric.MutualInformation') ||...
                      isa(metricConfig,'registration.metric.MattesMutualInformation');
                  
        if ~validMetric
           error(message('images:imregister:invalidMetricConfig'))
        end
        tf = true;
        
    end

    function tf = checkFixedImage(img)
        
        validateattributes(img,{'numeric'},...
            {'real','nonempty','nonsparse','finite','nonnan'},'imregister','fixed',1);
                
        if(ndims(img)>3)
            error(message('images:imregister:fixedImageNot2or3D'));
        end
        tf = true;
        
    end

    function tf = checkMovingImage(img)
        
        validateattributes(img,{'numeric'},...
            {'real','nonempty','nonsparse','finite','nonnan'},'imregister','moving',2);

        if(ndims(img)>3)
            error(message('images:imregister:movingImageNot2or3D'));
        end
        
        
        if (any(size(img)<4))
             error(message('images:imregister:minMovingImageSize'));
        end
 
        tf = true;
        
    end

    function tf = checkTransform(tform)
        parsedTransformString = validatestring(lower(tform), {'affine','translation','rigid','similarity'}, ...
            'imregister', 'TransformType');
        
        tf = true;
        
    end
    
    function tf = checkDisplay(TF)
        
        validateattributes(TF,{'logical','numeric'},{'real','scalar'});
        
        tf = true;
        
    end

end


% Validate input pyramid levels against image sizes
function validatePyramidLevels(fixed,moving,numLevels)

requiredPixelsPerDim = 4.^(numLevels-1);

fixedTooSmallToPyramid  = any(size(fixed) < requiredPixelsPerDim);
movingTooSmallToPyramid = any(size(moving) < requiredPixelsPerDim);

if fixedTooSmallToPyramid || movingTooSmallToPyramid
    % Convert dims to strings, since they can be large enough to overflow
    % into a floating point type.
    error(message('images:imregister:tooSmallToPyramid', ...
                  sprintf('%d', requiredPixelsPerDim), ...                  
                  numLevels));
end

end


% Display final transform coefficients
function printTransformCoefficients(tform)


    % Transpose to make it easy to index into.
    T = tform.tdata.T';
    
    disp(' ');
    disp(sprintf(getString(message('images:imregister:tformStructHowTo','T','tform struct'))));
    
    disp(' ');
    if(size(T,1)==3)
        % 2D images
        disp(getString(message('images:imregister:useResultingStruct','tform struct','imtransform')));
    else
        % 3D images
        disp(getString(message('images:imregister:useResultingStruct','tform struct','tformarray')));
    end
    disp(' ');
    
    if(size(T,1)==3)
        disp(sprintf('t = [%-15e %-15e %e;...',T(1:3))); 
        disp(sprintf('     %-15e %-15e %e;...',T(4:6)));
        disp(sprintf('     %-15e %-15e %e];',T(7:9)));        
    else
        disp(sprintf('t = [%-15e %-15e %-15e %e;...',T(1:4)));
        disp(sprintf('     %-15e %-15e %-15e %e;...',T(5:8)));
        disp(sprintf('     %-15e %-15e %-15e %e;...',T(9:12)));
        disp(sprintf('     %-15e %-15e %-15e %e];',T(13:16)));                
    end
    disp(' ');
    disp('T = maketform(''affine'',t)');
    
    disp(' ');
                                   
end


% Register the moving image to the fixed image using the tform struct
function moving_reg = transformMovingImage(moving, fixed, tform)

if(length(size(fixed))==2)       
    [M, N] = size(fixed);    
    moving_reg = imtransform(moving, tform,...
        'XData', [1 N], 'YData', [1 M], ...
        'Size', [M N]);
else    
    nDims      = ndims(fixed);
    resampler  = makeresampler('linear','fill');
    fillValue  = 0;
    tdims_a    = 1:nDims;
    tdims_b    = 1:nDims;    
    outSize    = size(fixed);
    moving_reg = tformarray(moving,tform,resampler,...
        tdims_a, tdims_b,...
        outSize, [], fillValue);
end


end
