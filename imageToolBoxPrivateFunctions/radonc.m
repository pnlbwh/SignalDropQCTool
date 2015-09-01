function varargout = radonc(varargin)
%RADONC Helper function for RADON.
%   [P,R] = RADONC(I,THETA) returns P, the Radon transform of I
%   evaluated for the angles in THETA, and R, a vector containing
%   radial coordinates corresponding to the columns of P.
%
%   See also RADON.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.12.4.4 $  $Date: 2011/07/19 23:55:17 $

%#mex

error('images:radonc:missingMEXFile', 'Missing MEX-file: %s', mfilename);

