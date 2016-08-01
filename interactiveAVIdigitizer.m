function interactiveAVIdigitizer
% %%%
% 
% Works for Lauder Lab standard format - uncompressed AVI videos.
%
% Calls Eric Tytell's parsevarargin and trackLine functions (c) 2011,
% 2016, respectively.  Available at <https://github.com/tytell/neuromech>
% 
% User inputs the avi video, save directory, and some scaling info. Then,
% goes frame by frame through the AVI and lets the user digitize.
%
% Currently, will need to import video clips starting where digitizing is
% desired.  For example, if the first 100 frames of the original video are
% not of interest, then a clip from the original video, starting at frame
% 101, needs to be used here.
%
% Adjustment option allows the user to modify the axes on the tracks so that
% the origin is in the same place in space as the origin set in PIV
% software like DaVis. (Ex: DaVis calibration places the origin at x = 173
% pix, y = 575 pix.  Adjust tracked values in Matlab to match this
% coordinate system.) Without adjustment, the origin will be placed in the
% LOWER LEFT corner of the image.
% 
% Copyright (c) 2016, Kelsey N Lucas
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
% notice, this list of conditions and the following disclaimer in the 
% documentation and/or other materials provided with the distribution.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 
%
% The above is a BSD 2-Clause License.  Details at
% <https://opensource.org/licenses/bsd-license.php>
% 
% 
% %%%

%Open dialog to get AVI file
[movname, movpath] = uigetfile('*.avi','Choose avi file');
%If no file is selected, end
if isempty(movpath)
    return;
end

%User inputs the number of the first frame (ex: video clip is frames
%494-680 of original video.  First frame number of clip = 494).
startfr = input('What is the first frame number? (default = 1)   ');
if isempty(startfr)
    startfr = 0;
else
    startfr = startfr - 1;
end

%Ask for user input of basename for saved tracks
basename = input('Choose basename for saved tracking files (no quotes)   ','s');
if isempty(basename)
    return;
end
%Ask for user input of output directory (where trackes will be saved)
outdir = uigetdir('', 'Choose output directory');


%Ask user for pixel scale factor - so saved tracks are in mm, not pixels
mmperpix = input('Enter pixel scale factor (mm/pix)   ');

%Ask user if this is a PIV video.  
adjust = input('Does origin need adjustment (ex: match a DaVis calibration)? 1 = Yes, 0 = No   ');

%Set location where adjusted origin will be
if adjust == 1
    x0 = input('Enter x0 position (ex: x0 value on DaVis calibration screen)   ');
    y0 = input('Enter y0 position (ex: x0 value on DaVis calibration screen)   ');
else
    x0 = 0;
    y0 = 0;
end

%Build path to AVI video
vid = [movpath, movname];

%Run trackLine to allow interactive tracking
trackLine(vid, [],[], 'savecallback',@saveoutline);

%Build subfunction for saving tracks
    function saveoutline(x,y, imname,imnum)
        
        %Build filename where current track will be saved
        outfilename = sprintf('%s-track-%05d.dat', basename, startfr+imnum);
        
        %Flip y axis (images = origin in upper left, want origin in lower
        %left)
        y = 1024 - y;
        %If origin needs to be moved, move y axis
        if adjust ==1
            y = y - (1024-y0);
        end
        %if origin needs to be moved (x0 is not equal to 0), move x axis
        x = x - x0;
        %Convert pixels to real units
        x = x*mmperpix;
        y = y*mmperpix;
        %Write the track to a comma-delimited dat file
        dlmwrite(fullfile(outdir,outfilename), [x' y'], ',');
        
    end

end
        