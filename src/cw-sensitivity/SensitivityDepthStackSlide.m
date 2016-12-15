## Copyright (C) 2016 Christoph Dreissigacker
## Copyright (C) 2012 Reinhard Prix
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with with program; see the file COPYING. If not, write to the
## Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
## MA  02111-1307  USA

## Estimate StackSlide sensitivity depth, defined as
##
## sensDepth = sqrt(Sdata)/h0,
##
## where 'Sdata' is an estimate of the noise PSD over all the data used
## (which should be computed as the harmonic mean over all the SFTs from
## all detectors), and 'h0' is the smallest detectable GW amplitude at the
## given false-alarm (pFA) and false-dismissal probability (pFD)
##
## Usage:
##   sensDepth = SensitivityDepthStackSlide("opt", val, ...)
## Options are:
##   "Nseg":            number of StackSlide segments
##   "Tdata":           total amount of data used, in seconds
##                      (Note: Tdata = Nsft * Tsft, where 'Nsft' is the total number of
##                      SFTs of length 'Tsft' used in the search, from all detectors)
##   "misHist":         mismatch histogram, produced using Hist()
##   "pFD":             false-dismissal probability = 1 - pDet = 1 - 'confidence'
##   "pFA":             false-alarm probability (-ies) *per template* (can be a vector)
##   "avg2Fth"		ALTERNATIVE to pFA: specify average-2F threshold directly
##   "detectors":       CSV list of detectors to use ("H1"=Hanford, "L1"=Livingston, "V1"=Virgo, ...)
##   "detweights":      detector weights on S_h to use (default: uniform weights)
##   "alpha":           source right ascension in radians (default: all-sky)
##   "delta":           source declination (default: all-sky)

function sensDepth = SensitivityDepthStackSlide ( varargin )

  ## parse options
  uvar = parseOptions ( varargin,
                       {"Nseg", "integer,strictpos,column", 1 },
                       {"Tdata", "real,strictpos,column" },
                       {"misHist", "a:Hist" },
                       {"pFD", "real,strictpos,column", 0.1},
                       {"pFA", "real,strictpos,column", []},
                       {"avg2Fth", "real,strictpos,column", []},
                       {"detectors", "char", "H1,L1" },
                       {"detweights", "real,strictpos,vector", []},
                       {"alpha", "real,vector", [0, 2*pi]},
                       {"delta", "real,vector", [-pi/2, pi/2]},
                       []);
  ## check input
  assert ( ! ( isempty ( uvar.pFA ) && isempty ( uvar.avg2Fth ) ), "Need at least one of 'pFA' or 'avg2Fth' to determine false-alarm probability!\n" );
  assert ( isempty ( uvar.pFA ) || isempty ( uvar.avg2Fth ), "Must specify exactly one of 'pFA' or 'avg2Fth' to determine false-alarm probability!\n" );
  assert ( isscalar(uvar.Tdata), "Calculation for multiple Tdata not supported yet.\n");

  ## compute sensitivity SNR
  Rsqr = SqrSNRGeometricFactorHist("detectors", uvar.detectors, "detweights", uvar.detweights, "alpha", uvar.alpha, "sdelta", sin(uvar.delta) );

  ## two different ways to specify false-alarm / threshold
  if ( !isempty ( uvar.pFA ) )
    FAarg = { "paNt", uvar.pFA };
  else
    FAarg = { "sa", uvar.Nseg * uvar.avg2Fth };
  endif

  [rho, pd_rho] = SensitivitySNR ( "pd", uvar.pFD, "Ns", uvar.Nseg, "Rsqr", Rsqr,"misHist",uvar.misHist, "stat", {"ChiSqr", FAarg{:}} );

  ## convert to sensitivity depth
  rhoSC = sqrt ( uvar.Nseg )  .* rho;
  sensDepth = 2 / 5 * sqrt ( uvar.Tdata ) ./ rhoSC;

endfunction


## a basic example to test functionality (all with mismatch average)
%!test
%!  Nseg = 20;
%!  Tdata = 60*3600*Nseg;
%!  misHist = createDeltaHist(0.1);
%!  pFD = 0.1;
%!  pFA = [1e-14; 1e-12; 1e-10];
%!  sum2Fth = invFalseAlarm_chi2 ( pFA, 4 * Nseg );
%!  avg2Fth = sum2Fth / Nseg;
%!  dets = "H1,L1";
%!  depth = SensitivityDepthStackSlide("Nseg", Nseg, "Tdata", Tdata, "misHist", misHist, "pFD", pFD, "avg2Fth", avg2Fth, "detectors", dets);
%!  assert(max(abs(depth - [38.671; 40.780; 43.379])) < 0.05);
%!test
%!  Nseg = 20;
%!  Tdata = 60*3600*Nseg;
%!  misHist = createDeltaHist(0.1);
%!  pFD = 0.1;
%!  pFA = [1e-14; 1e-12; 1e-10];
%!  dets = "H1,L1";
%!  depth = SensitivityDepthStackSlide("Nseg", Nseg, "Tdata", Tdata, "misHist", misHist, "pFD", pFD, "pFA", pFA, "detectors", dets);
%!  assert(max(abs(depth - [38.671; 40.780; 43.379])) < 0.05);
