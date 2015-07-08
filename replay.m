% Regenerate stimulus frames for an experiment
%
% (c) 2015 Niru Maheswaranathan
%
% 04 May 2015 - initial version
addpath('jsonlab/')
addpath('utils/')
addpath('functions/')

% load experiment
today = datestr(now, 'yy-mm-dd');
basedir = fullfile('logs/', today);
if exist(fullfile(cd, basedir, 'expt.json'), 'file') == 2
  expt = loadjson(fullfile(cd, basedir, 'expt.json'));
else
  error('Could not find expt.json file for today!')
end

% filename for the hdf5 file
fname = 'stimulus.h5' %fullfile(expanduser('~/Desktop/'), datestr(now, 'mmddyy'), 'stimulus.h5');

% replay experiments
for stimidx = 1:length(expt.stim)

  % pull out the function and parameters
  stim = expt.stim{stimidx};
  me = stim.params;
  me.disp = expt.disp;
  fields = fieldnames(me);

  % group name
  group = ['/expt' num2str(stimidx)];

  % store the stimulus pixel values
  h5create(fname, [group '/stim'], [me.ndims, stim.numframes], 'Datatype', 'uint8');
  stim.filename = fullfile('/Volumes/data/Lane/2015-07-02/stimulus/', 'stimulus.h5'); %fname;
  stim.group = group;
  stim.disp = expt.disp;
  eval(['ex = ' stim.function '(stim, true);']);
  
  % store the timestamps
  h5create(fname, [group '/timestamps'], stim.numframes);
  h5write(fname, [group '/timestamps'], stim.timestamps - stim.timestamps(1));

  % store metadata
  h5writeatt(fname, group, 'function', stim.function);
  h5writeatt(fname, group, 'framerate', stim.framerate);
  for idx = 1:length(fields)
    h5writeatt(fname, group, fields{idx}, getfield(me, fields{idx}));
  end
    
end