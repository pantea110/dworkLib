
function out = proxL2Sq( v, t, b )
  % out = proxL2Sq( v )
  %
  % Evaluate the proximal operator of tf where f(x) = t/2 || x - b ||_2^2
  %
  % Inputs:
  % x - the argument of the proximal operator
  %     Note: could be a scalar or multi-dimensional array
  %
  % Optional Inputs:
  % t - scaling of the L2 norm squared function
  %     Either a scalar or the same size as x
  %
  % Output:
  % out - the result of the proximal operator
  %
  % Written by Nicholas Dwork, Copyright 2019
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  if nargin < 2, t = 1; end

  if nargin > 2
    out = ( v + t*b ) / ( 1 + t );
  else
    out = v ./ ( 1 + t );
  end

end