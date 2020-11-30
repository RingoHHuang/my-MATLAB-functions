# My MATLAB Functions

This repository contains custom convenience functions that I frequently use for my projects. 

Mostly, I'm tired of rewriting the same code because I lacked an organized system of saving my convenience functions.

## resample_with_nans
Convenience function of resample (Signal Processing Toolbox) that preserves NaNs (instead of interpolating over them). Also automatically adds padding to the start and end of the timeseries to avoid edge artifacts. 

Usage:

<code>[Y, Ty] = resample_with_nans(X, Tx, Fs)</code>
* From resample documentation: uses interpolation and an anti-aliasing filter to resample the signal at a uniform sample rate, Fs, expressed in hertz (Hz)
* Optional argument pad_length (default is 20) is the number of samples for forward and rear padding before applying resample

