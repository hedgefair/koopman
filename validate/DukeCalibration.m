function DukeCalibration(isNoisy )
%DUKECALIBRATION Compute Koopman modes using several techniques on
%synthetic data.
%
% This function implements the data set similar to
% Duke, Daniel, Julio Soria, and Damon Honnery. 2012. “An Error Analysis of
% the Dynamic Mode Decomposition.” Experiments in Fluids 52 (2):
% 529–42. doi:10.1007/s00348-011-1235-7.

% DUKECALIBRATION(ISNOISY)
% Data set contains an exponential spatial and temporal shape, with added
% noise (SNR=100) (unless FALSE) is passed as the argument
%
% It then computes Koopman modes using exact, Duke, and DFT algorithms and
% plots them.
%
% This function should be interpreted as a "sanity" check for Koopman mode
% techniques.
%

% Copyright 2015 under BSD license (see LICENSE file).

import koopman.*

%% Generate Duke Synthetic Data set
[U, t, x] = DukeSynthetic('TimeComplexFrequency', 20i, ...
                          'SpaceComplexFrequency', 1+5i);

% compute time and space step sizes
dt = t(2)-t(1);
dx = x(2)-x(1);

%%
% If requested, add multiplicative noise
if nargin == 1 && ~isNoisy
  disp('Noiseless')
else
  disp('Adding noise')
  NSR = 10/100; % noise to signal ratio
  Noise = (2*rand(size(U)) - 1) * NSR;
  U = U .* (1 + Noise);
end

%%
% Plot the time-space false color plot of data
%figure('Name','Synthetic data set (Duke)');
subplot(2,2,1);
pcolor( t, x, U );
xlabel('Time t');
ylabel('Space x');
shading interp
title('Synthetic Duke data set')
c = colorbar('South');
c.Position(4) = c.Position(4)/4;

%figure('Name','Space/time FFT')
subplot(2,2,3)
getspectrum( U(end,:), dt );
title('Time FFT')

subplot(2,2,4)
getspectrum( U(:,end), dx );
title('Space FFT')

%figure('Name','Modes')
subplot(2,2,2)
Nmd = 5;

[U, Mean] = removemean(U);

fprintf('Removed data mean (ranged in interval [%f, %f])\n', ...
        min(Mean), max(Mean) );

tic
[lambda_u1, Phi_u1, Amp_u1] = DMD( U, dt, true );
toc
tic
[lambda_u2, Phi_u2, Amp_u2] = DMD_Duke( U, dt, 20 );
toc
tic
[lambda_u3, Phi_u3, Amp_u3] = KDFT( U, dt  );
toc

x = x.';

h = plot(x,U(:,1),'LineWidth',3 );
h.DisplayName = 'Data';
hold all;
axis manual; % fix axis according to data

plotMode( x, Amp_u1(1)*Phi_u1(:,1), 'Exact DMD' );
plotMode( x, Amp_u2(1)*Phi_u2(:,1), 'Duke DMD' );
plotMode( x, Amp_u3(1)*Phi_u3(:,1), 'KDFT' );

legend('Location','Best');

disp('Exact DMD:')
Amp_u1(1:Nmd).'
lambda_u1(1:Nmd)

disp('Duke DMD:')
Amp_u2(1:Nmd).'
lambda_u2(1:Nmd)

disp('KDFT:')
Amp_u3(1:Nmd).'
lambda_u3(1:Nmd)

end

function h = plotMode( x, z, name )
%PLOTMODE Plot the complex mode.

  validateattributes(x, {'numeric'},{'column','finite','nonnan'});
  validateattributes(z, {'numeric'},{'column','finite',...
                      'nonnan','numel',numel(x)});

  % multiply by 2 to compensate for the conjugate mode
  h = plot( x, 2*real(z) );
  h.DisplayName = name;

end
