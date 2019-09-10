
function out = proxL1Complex( in, thresh, weights )
  % out = proxL1Complex( in, thresh, weights )
  %
  % Returns the proximal operator of f(x) = thresh * L1( x ), where
  %   x is a complex vector.
  %
  % Inputs:
  % in - an array of complex values
  % thresh - the thresholding value
  %
  % Written by Nicholas Dwork - Copyright 2019
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  if nargin > 2, thresh = thresh .* weights; end

  magIn = abs( in );

  scalingFactors = thresh ./ magIn;
  scalingFactors( magIn <= thresh ) = 1;

  projsOntoL2Ball = in .* scalingFactors;

  out = in - projsOntoL2Ball;
end

