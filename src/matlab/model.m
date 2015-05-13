VAR_DIR = '/Users/jan/Dropbox/mphil_project/repo/var/';
GPML_DIR = '/Users/jan/Dropbox/mphil_project/gpml-matlab-v3.5-2014-12-08/';
JSONLAB_DIR = '/Users/jan/Dropbox/mphil_project/repo/src/matlab/jsonlab/';
IN_FILENAME = 'scheduler_data.json';
OUT_FILENAME = 'models.json';

% GPML
run(strcat(GPML_DIR, 'startup.m'));

% JSONLAB
addpath(JSONLAB_DIR);

% utils
me = mfilename;                                            % what is my filename
mydir = which(me); 
mydir = mydir(1:end-2-numel(me));        % where am I located
addpath(mydir(1:end-1));
addpath([mydir,'util']);

% Load data
I = loadjson(strcat(VAR_DIR, IN_FILENAME));
x_percent_data = I.x_percent_data';
y_times = I.y_times';
y_scores = I.y_scores';

O = struct();

if false
    % Model using optimisation
    if isempty(x_percent_data)
        error('No data');
    else
        [~, time_m, time_sd] = gp_wrapper('linear', x_percent_data, y_times);
        [~, score_m, score_sd] = gp_wrapper('exp', x_percent_data, y_scores);
    end
    % TODO The {}'s are necessary for matlab to encode this object as a
    % list. Find a better solution to this
    O.time_models = {struct('m', time_m', 'sd', time_sd'), {}};
    O.score_models = {struct('m', score_m', 'sd', score_sd'), {}};
else
    % Model using sampling
    if isempty(x_percent_data)
        error('No data');
    else
        O.time_models = slice_sample_wrapper('linear', x_percent_data, y_times);
        O.score_models = slice_sample_wrapper('exp', x_percent_data, y_scores);
    end
end

% Write model to file
savejson('', O, strcat(VAR_DIR, OUT_FILENAME));