
function [xStar,objectiveValues] = fista( x, g, gGrad, proxth, varargin )
  % [xStar,optValue] = fista( x, g, gGrad, proxth [, ...
  %   'h', h, 'N', N, 'r', r, 's', s, 'verbose', verbose ] )
  %
  % This function implements the FISTA optimization algorithm with line
  % search as described in "Fraction-variant beam orientation optimization
  % for non-coplanar IMRT" by O'Connor et al. (2017)
  % FISTA finds the x that minimizes functions of form g(x) + h(x) where
  % g is differentiable and h has a simple proximal operator.
  %
  % Inputs:
  % x - the starting point
  % g - a function handle representing the g function; accepts a vector x
  %     as input and returns a scalar.
  % gGrad - a function handle representing the gradient function of g;
  %     input: the point to evaluation, output: the gradient vector
  % proxth - the proximal operator of the h function (with parameter t);
  %     two inputs: the vector and the scalar value of the parameter t
  %
  % Optional Inputs:
  % h - a handle to the h function.  This is needed to calculate the
  %     objective values.
  % N - the number of iterations that FISTA will perform
  % r - the backtracking line search parameter; must be between 0 and 1
  %     (default is 0.5)
  % s - the scaling parameter each FISTA iteration; must be greater than 1
  %     (default is 1.25)
  % verbose - if set then prints fista iteration
  %
  % Outputs:
  % xStar - the optimal point
  %
  % Written by Nicholas Dwork - Copyright 2017
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  p = inputParser;
  p.addParameter( 'h', [] );
  p.addParameter( 'N', 100, @isnumeric );
  p.addParameter( 'r', 0.5, @isnumeric );
  p.addParameter( 's', 1.25, @isnumeric );
  p.addParameter( 'verbose', 0, @isnumeric );
  p.parse( varargin{:} );
  h = p.Results.h;
  N = p.Results.N;  % total number of iterations
  r = p.Results.r;  % r must be between 0 and 1
  s = p.Results.s;  % s must be greater than 1
  verbose = p.Results.verbose;

  calculateObjectiveValues = 0;
  if nargout > 1
    if numel(h) == 0
      warning('fista.m - Cannot calculate objective values without h function handle');
    else
      objectiveValues = zeros(N,1);
      calculateObjectiveValues = 1;
    end
  end


  t = 1;
  v = x;
  theta = 1;


  for k=1:N
    if verbose, disp([ 'FISTA Iteration: ', num2str(k) ]); end;
    if numel(calculateObjectiveValues) > 0, objectiveValues(k) = g(x) + h(x); end

    lastX = x;
    lastT = t;
    t = s * lastT;
    lastTheta = theta;

    while true
      if k==1
        theta = 1;
      else
        a = lastT;  b = t*lastTheta*lastTheta;  c = -b;
        %[r1,r2] = rootsOfQuadratic( a, b, c );  theta = max( r1, r2 );
        theta = ( -b + sqrt( b*b - 4*a*c ) ) / ( 2*a );
        if( theta < 0 ), error('theta must be positive'); end;
      end
      y = (1-theta) * lastX + theta * v;
      Dgy = gGrad( y );
      x = proxth( y - t * Dgy, t );
      breakThresh = g(y) + dotP(Dgy,x-y) + (1/(2*t))*norm(x(:)-y(:),2)^2;
      if g(x) <= breakThresh, break; end;
      t = r*t;
    end

    v = x + (1/theta) * ( x - lastX );
  end

  xStar = x;
end

