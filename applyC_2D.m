
function out = applyC_2D( F, domTraj, rangeTraj, kCy, kCx, Cy, Cx )
  % out = applyC_2D( F, domTraj, N, kCy, kCx, Cy, Cx )
  % or
  % out = applyC_2D( F, N, rangeTraj, kCy, kCx, Cy, Cx )
  % or
  % out = applyC_2D( F, domTraj, rangeTraj, kCy, kCx, Cy, Cx )
  %
  % Applies a continuous circular convolution of a kernel as detailed in
  % http://nicholasdwork.com/tutorials/dworkGridding.pdf
  %
  % Inputs:
  %   F - An nTraj array representing the values of the function evaluated at each point in domTraj
  %   domTraj - An nTraj x 2 array specifying the ky / kx (first / second column) coordinates
  %             of the domain trajectory points
  %   rangeTraj - An nNew x 2 array specifying the ky / kx (first / second column) coordinates
  %             of the new points
  %             OR
  %             a two element array specifying the size of the grid in the Fourier domain
  %   kCy - array of convolution kernel domain values in y dimension
  %   kCx - array of convolution kernel domain values in x dimension
  %   Cy - array of convolution kernel values in y dimension
  %   Cx - array of convolution kernel values in x dimension
  %
  % Written by Nicholas Dwork - Copyright 2016
  %
  % https://github.com/ndwork/dworkLib.git
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  if numel( domTraj ) == 2 && max( mod( domTraj, 1 ) ) == 0 && min( abs( domTraj ) ) > 0
    % rangeTraj is a two element array specifying the size of the grid
    N = domTraj;
    domTraj = size2fftCoordinates( N );
    domTrajKy = domTraj{1};  domTrajKx = domTraj{2};
    domTrajIsGrid = true;
  else
    domTrajKy = rangeTraj(:,1);  domTrajKx = rangeTraj(:,2);
    domTrajIsGrid = false;
  end

  if numel( rangeTraj ) == 2 && max( mod( rangeTraj, 1 ) ) == 0 && min( abs( rangeTraj ) ) > 0
    % rangeTraj is a two element array specifying the size of the grid
    N = rangeTraj;
    rangeTraj = size2fftCoordinates( N );
    newKy = rangeTraj{1};  newKx = rangeTraj{2};
    rangeTrajIsGrid = true;
  else
    newKy = rangeTraj(:,1);  newKx = rangeTraj(:,2);
    rangeTrajIsGrid = false;
  end
  
  if domTrajIsGrid == true && rangeTrajIsGrid == true
    error( 'This feature is not yet implemented.' );
  end

  kyDistThresh = max( kCy );
  kxDistThresh = max( kCx );

	nTraj = size( domTraj, 1 );
  if rangeTrajIsGrid == true
    % rangeTraj is a grid and domTraj is not

    sOut = [ numel(newKy) numel(newKx) size(F,2) ];
    out = zeros( sOut );
    F = reshape( F, size(F,1), 1, size(F,2) );
    for domTrajIndx = 1 : nTraj

      kyDists = min( abs( domTraj(domTrajIndx,1)       - newKy ), ...
                     abs( domTraj(domTrajIndx,1) + 1.0 - newKy ) );
      kyDists = min( kyDists, ...
                     abs( domTraj(domTrajIndx,1) - 1.0 - newKy ) );

      kxDists = min( abs( domTraj(domTrajIndx,2)       - newKx ), ...
                     abs( domTraj(domTrajIndx,2) + 1.0 - newKx ) );
      kxDists = min( kxDists, ...
                     abs( domTraj(domTrajIndx,2) - 1.0 - newKx ) );

      shortIndxsY = find( kyDists < kyDistThresh );
      if numel( shortIndxsY ) == 0, continue; end

      shortIndxsX = find( kxDists < kxDistThresh );
      if numel( shortIndxsX ) == 0, continue; end

      CValsY = interp1( kCy, Cy, kyDists( shortIndxsY ), 'linear', 0 );
      CValsX = interp1( kCx, Cx, kxDists( shortIndxsX ), 'linear', 0 );
      CValsYX = CValsY * CValsX';

      outValues = bsxfun( @times, F(domTrajIndx,1,:), CValsYX );
      out( shortIndxsY, shortIndxsX, : ) = out( shortIndxsY, shortIndxsX, : ) + outValues;
    end

  elseif domTrajIsGrid == true
    % domTraj is a grid and rangeTraj is not

    nNew = size( rangeTraj, 1 );
    nFs = size( F, 3 );
    out = zeros( nNew, nFs );

    for rangeTrajIndx = 1 : nNew
      kyDists = min( abs( rangeTraj(rangeTrajIndx,1)       - domTrajKy ), ...
                     abs( rangeTraj(rangeTrajIndx,1) + 1.0 - domTrajKy ) );
      kyDists = min( kyDists, ...
                     abs( rangeTraj(rangeTrajIndx,1) - 1.0 - domTrajKy ) );

      kxDists = min( abs( rangeTraj(rangeTrajIndx,2)       - domTrajKx ), ...
                     abs( rangeTraj(rangeTrajIndx,2) + 1.0 - domTrajKx ) );
      kxDists = min( kxDists, ...
                     abs( rangeTraj(rangeTrajIndx,2) - 1.0 - domTrajKx ) );

      shortIndxsY = find( kyDists < kyDistThresh );
      if numel( shortIndxsY ) == 0, continue; end

      shortIndxsX = find( kxDists < kxDistThresh );
      if numel( shortIndxsX ) == 0, continue; end

      CValsY = interp1( kCy, Cy, kyDists( shortIndxsY ), 'linear', 0 );
      CValsX = interp1( kCx, Cx, kxDists( shortIndxsX ), 'linear', 0 );
      CValsYX = CValsY * CValsX';
      FCVals = bsxfun( @times, F( shortIndxsY, shortIndxsX, : ), CValsYX );

      out( rangeTrajIndx, : ) = sum( sum( FCVals, 1 ), 2 );
    end

  else
    % Neither domTraj nor rangeTraj are a grid

    nNew = size( rangeTraj, 1 );
    nFs = size( F, 2 );

    segLength = 2000;
    nSegs = ceil( nTraj / segLength );

    out = cell( 1, 1, nSegs );
    parfor segIndx = 1 : nSegs
      startIndx = ( segIndx - 1 ) * segLength + 1;
      endIndx = min( segIndx * segLength, nTraj );

      tmp = zeros( nNew, nFs );
      for domTrajIndx = startIndx : endIndx
        kyDists = min( abs( domTraj(domTrajIndx,1)       - newKy ), ...
                       abs( domTraj(domTrajIndx,1) + 1.0 - newKy ) );   %#ok<PFBNS>
        kyDists = min( kyDists, ...
                       abs( domTraj(domTrajIndx,1) - 1.0 - newKy ) );

        kxDists = min( abs( domTraj(domTrajIndx,2)       - newKx ), ...
                       abs( domTraj(domTrajIndx,2) + 1.0 - newKx ) );
        kxDists = min( kxDists, ...
                       abs( domTraj(domTrajIndx,2) - 1.0 - newKx ) );

        shortIndxs = find( kyDists < kyDistThresh & kxDists < kxDistThresh );
        if numel( shortIndxs ) == 0, continue; end

        CValsY = interp1( kCy, Cy, kyDists( shortIndxs ), 'linear', 0 );
        CValsX = interp1( kCx, Cx, kxDists( shortIndxs ), 'linear', 0 );
        FCVals = bsxfun( @times, F( domTrajIndx, : ), CValsY .* CValsX );   %#ok<PFBNS>

        tmp( shortIndxs, : ) = tmp( shortIndxs, : ) + FCVals;
      end
      out{ segIndx } = tmp;
    end
    out = sum( cell2mat( out ), 3 );

  end

end
