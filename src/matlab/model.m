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
O = struct();

% Model using optimisation
x_percent_data = I.x_percent_data';
y_times = I.y_times';
y_scores = I.y_scores';

if isempty(x_percent_data)
    error('No data');
else
    [~, time_m, time_sd] = gp_wrapper('linear', x_percent_data, y_times);
    [~, score_m, score_sd] = gp_wrapper('exp', x_percent_data, y_scores);
end
O.time_models = {struct('m', time_m', 'sd', time_sd'),{}};
O.score_models = {struct('m', score_m', 'sd', score_sd'),{}};


% Write model to file
savejson('', O, strcat(VAR_DIR, OUT_FILENAME));