% Remove derived files so library can be rebuilt
% Copyright 2022-2024 The MathWorks, Inc.

cd(fileparts(which(mfilename)))
ssc_clean('cylPackParChnlsLumped')
ssc_clean('cylPackParChnlsLumpedLumpingAdapters')

rmdir('+cylPackParChnlsLumped','s')
rmdir('+cylPackParChnlsLumpedLumpingAdapters','s')

delete('cylPackParChnlsLumped_param.m')
delete('cylPackParChnlsLumped.slx')
delete('cylPackParChnlsLumped.mat')
