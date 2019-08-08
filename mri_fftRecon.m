
function recons = mri_fftRecon( kData )
  % Performs an inverse FFT of each coil
  %
  % Inputs:
  % kData is an array of size (Ny,Nx,nSlices,...,nCoils)
  %
  % Output:
  % recons is the reconstructed image, an array of the same size as the input
  %
  % Written by Nicholas Dwork - Copyright 2018
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  recons = fftshift( ifftc( ...
      fftshift( ifftc( kData, [], 1 ), 1 ), ...
    [], 2 ), 2 );

  if ~ismatrix( kData )
    recons = fftshift( ifftc( recons, [], 3 ), 3 );
  end

end
