function return_handles = check_header(handles)

handles.user_header_error = ''; 

if ~exist(handles.user_header_reference, 'file')
   disp(['Reference: ' handles.user_header_reference]);
   error('Input reference file doesn''t exists.') ;
end


% % % 
% Load the header of the reference file
% % % 

reference = loadNrrdStructure(handles.user_header_reference);

% Dimension
if (reference.dimension ~= dwi.dimension) || (dwi.dimension ~= 4)
   handles.user_header_error = 'The number of dimensions is not 4 either in the reference volume or the input volume'; 
   return_handles = handles;
   return;
end

if (dwi.space ~= reference.space)
    handles.user_header_error = 'Not the same space'; 
    return_handles = handles;
    return;
end

if (dwi.size(4) ~= reference.size(4))
        handles.user_header_error = 'Not the same number of gradients'; 
    return_handles = handles;
    return;
end

if (dwi.endian ~= reference.endian)
    handles.user_header_error = 'Not the endianness'; 
    return_handles = handles;
    return;
end

if (nnz(dwi.spaceorigin - reference.spaceorigin) > 0)
    handles.user_header_error = 'Not the space origin'; 
    return_handles = handles;
    return; 
end

if (nnz(dwi.measurementframe - reference.measurementframe) > 0)
    handles.user_header_error = 'Not the space measurement frame'; 
    return_handles = handles;
    return; 
end

if (dwi.bvalue ~= reference.bvalue)
    handles.user_header_error = 'Not the same B-Value'; 
    return_handles = handles;
    return;
end

a = dwi.gradients - reference.gradients;
a(a < 0.001) = 0;

if (nnz(a) > 0)
    handles.user_header_error = 'Not the same gradient directions'; 
    return_handles = handles;
    return;
end


return_handles = handles;


end
