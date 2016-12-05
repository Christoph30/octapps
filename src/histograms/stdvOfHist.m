## Copyright (C) 2015 Karl Wette
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

## Returns the standard deviation(s) of a histogram.
## Syntax:
##   stdv = stdvOfHist(hgrm, [k = 1])
## where:
##   hgrm = histogram class
##   k    = dimension to calculate standard deviation(s) over

function stdv = stdvOfHist(hgrm, k = 1)

  ## check input
  assert(isa(hgrm, "Hist"));
  dim = histDim(hgrm);
  assert(isscalar(k) && 1 <= k && k <= dim);

  ## calculate standard deviation(s)
  stdv = sqrt(varianceOfHist(hgrm, k));

endfunction


## test histogram mean/standard deviation with Gaussian/uniform histogram
%!shared hgrm
%!  hgrm = Hist(2, {"lin", "dbin", 0.01}, {"lin", "dbin", 0.1});
%!  hgrm = addDataToHist(hgrm, [normrnd(1.7, 4.3, 1e7, 1), rand(1e7, 1)]);
%!assert(abs(meanOfHist(hgrm) - 1.7) < 5e-2)
%!assert(abs(stdvOfHist(hgrm) - 4.3) < 5e-2)
%!assert(abs(stdvOfHist(hgrm) - sqrt(varianceOfHist(hgrm))) < 5e-2)
