import numpy as np
import matplotlib.pyplot as plt
from data_handling.generate_data_for_config import generate_datum
from os.path import isfile, join
from os import remove
from time import sleep
from subprocess import call
from argparse import ArgumentParser
from data_handling.datasets import load_dataset, create_dataset
from data_handling.utils import name_to_classifier_object
import datetime

VAR_DIR = '/Users/jan/Dropbox/mphil_project/repo/var/'
FIG_DIR = '/Users/jan/Dropbox/mphil_project/repo/figs/'
DATA_FILENAME = 'data.txt'
# TODO change filename to models_and...
MODEL_AND_DECISION_FILENAME = 'model_and_decision.txt'
MATLAB_EXECUTABLE = '/Applications/MATLAB_R2014b.app/bin/matlab'
MATLAB_SCRIPT = '/Users/jan/Dropbox/mphil_project/repo/src/matlab/model_and_decide.m'

ALGORITHMS = {
           'rnd_forest': {'single_letter': 'r', 'full_name': 'red', 'params': {'n_estimators': 3}}, 
           'log_reg': {'single_letter': 'b', 'full_name': 'blue', 'params': {}}, 
           #'naive_bayes': {'single_letter': 'g', 'full_name': 'green', 'params': {}}
           }


class Datum:
    def __init__(self, x, time, score):
        if score < 0 or score > 1:
            raise ValueError('Score has to be bewtween 0 and 1 (is {})'.format(score))
        self.x = x
        self.time = time
        self.score = score

class Model:
    def __init__(self, min_x, max_x, mean, std_dev):
        if len(mean) != len(std_dev):
            raise ValueError('mean and std_dev must be of equal length')
        self.min_x = min_x
        self.max_x = max_x
        self.mean = np.array(mean)
        self.std_dev = np.array(std_dev)

    def x(self):
        return np.linspace(self.min_x, self.max_x, len(self.mean))

    def twice_std_dev_above(self):
        return self.mean + 2 * self.std_dev

    def twice_std_dev_below(self):
        return self.mean - 2 * self.std_dev

#def max_time_value(data):
    #time_max = 0.01
    #for _, datapoints in data.items():
        #for datum in datapoints:
            #time_max = max(time_max, datum.time)
    #return time_max

def max_score_value(data):
    score_max = 0
    for _, datapoints in data.items():
        for datum in datapoints:
            score_max = max(score_max, datum.score)
    return score_max

def write_data_to_file(data):
    filename = join(VAR_DIR, DATA_FILENAME)

    if isfile(filename):
        remove(filename)
    
    with open(filename, 'a') as f:
        #f.write('time_max\n')
        #f.write(str(max_time_value(data)))
        #f.write('\n\n')

        for name, datapoints in data.items():
            f.write(name + '\n')
            
            xs_str = [str(d.x) for d in datapoints]
            times_str = [str(d.time) for d in datapoints]
            scores_str = [str(d.score) for d in datapoints]

            
            f.write('[{}] % xs\n'.format(' '.join(xs_str)))
            f.write('[{}] % times\n'.format(' '.join(times_str)))
            f.write('[{}] % scores\n'.format(' '.join(scores_str)))

            f.write('\n')
            
def call_matlab_script():
    call([MATLAB_EXECUTABLE,
          "-nodisplay", 
          "-nosplash", 
          "-nodesktop", 
          "-r", 
          "run('{}'); exit();".format(MATLAB_SCRIPT)])

def read_model_and_decision_file(data):
    filename = join(VAR_DIR, MODEL_AND_DECISION_FILENAME)

    with open(filename) as f:
        lines = f.readlines()
        lines = map(lambda l: l.strip(), lines)

    new_models = {}

    i = 0
    while True:
        if lines[i] == 'next':
            name = lines[i + 1]
            if name == 'STOP':
                return (name, None)
            new_x = float(lines[i + 2])
            return (name, new_x)
        else:
            #print(lines[i])
            name = lines[i]
            time_m_raw = lines[i + 1]
            time_sd_raw = lines[i + 2]
            score_m_raw = lines[i + 3]
            score_sd_raw = lines[i + 4]
            #time_by_score_x_lower_raw = lines[i + 5]
            #time_by_score_x_upper_raw = lines[i + 6]
            #time_by_score_m_raw = lines[i + 5]
            #time_by_score_sd_raw = lines[i + 6]

            time_m_str = time_m_raw[len('time_m: '):]
            time_sd_str = time_sd_raw[len('time_sd: '):]
            score_m_str = score_m_raw[len('score_m: '):]
            score_sd_str = score_sd_raw[len('score_sd: '):]
            #time_by_score_x_lower_str = time_by_score_x_lower_raw[len('time_by_score_x_lower: '):]
            #time_by_score_x_upper_str = time_by_score_x_upper_raw[len('time_by_score_x_upper: '):]
            #time_by_score_m_str = time_by_score_m_raw[len('time_by_score_m: '):]
            #time_by_score_sd_str = time_by_score_sd_raw[len('time_by_score_sd: '):]
        

            time_m = map(lambda s: float(s), time_m_str.split())
            time_sd = map(lambda s: float(s), time_sd_str.split())
            score_m = map(lambda s: float(s), score_m_str.split())
            score_sd = map(lambda s: float(s), score_sd_str.split())
            #time_by_score_x_lower = float(time_by_score_x_lower_str)
            #time_by_score_x_upper = float(time_by_score_x_upper_str)
            #time_by_score_m = map(lambda s: float(s), time_by_score_m_str.split())
            #time_by_score_sd = map(lambda s: float(s), time_by_score_sd_str.split())

            #times = [d.time for d in data[name]]
            #if times:
                #times_lower = min(times) - 1
                #times_upper = max(times) + 1
            #else:
                #times_lower = 0
                #times_upper = 1
            models[name] = {'time': Model(0, 1, time_m, time_sd), 
                            'score': Model(0, 1, score_m, score_sd)}
                            #'time_by_score': Model(0, max_time_value(data) * 1.5, time_by_score_m, time_by_score_sd)}

            i += 6


def update_plot(data, models, cumulative_time, highest_scores, plt, ax_time, ax_score, ax_highest_score):
    ax_time.cla()
    ax_score.cla()
    ax_highest_score.cla()

    for name, datapoints in data.items():
        xs = [d.x for d in datapoints]
        times = [d.time for d in datapoints]
        scores = [d.score for d in datapoints]

        ax_time.plot(xs, times, ALGORITHMS[name]['single_letter']+'o')
        ax_score.plot(xs, scores, ALGORITHMS[name]['single_letter']+'o')

    for name, models in models.items():
        model_time = models['time']
        model_score = models['score']
        #model_time_by_score = models['time_by_score']

        if model_time:
            ax_time.plot(model_time.x(), model_time.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.1)
            ax_time.fill_between(model_time.x(), 
                             model_time.twice_std_dev_below(), 
                             model_time.twice_std_dev_above(), 
                             facecolor=ALGORITHMS[name]['full_name'], 
                             alpha=0.1, 
                             interpolate=True)
        if model_score:
            ax_score.plot(model_score.x(), model_score.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.1)
            ax_score.fill_between(model_score.x(), 
                             model_score.twice_std_dev_below(), 
                             model_score.twice_std_dev_above(), 
                             facecolor=ALGORITHMS[name]['full_name'], 
                             alpha=0.1, 
                             interpolate=True)

    ax_highest_score.plot(cumulative_time, highest_scores, 'k-')

    
    time_bounds = [10e5, 0]
    # TODO remove plural s
    scores_bounds = [10e5, 0]
    for _, datapoints in data.items():
        for datum in datapoints:
            time_bounds[0] = min(time_bounds[0], datum.time)
            time_bounds[1] = max(time_bounds[1], datum.time)
            scores_bounds[0] = min(scores_bounds[0], datum.score)
            scores_bounds[1] = max(scores_bounds[1], datum.score)
    if time_bounds[0] > 10e4:
        time_bounds = [0, 1]
    if scores_bounds[0] > 10e4:
        scores_bounds = [0, 1]

    time_d = time_bounds[1] - time_bounds[0]
    if time_d == 0:
        time_d = 0.1
    scores_d = scores_bounds[1] - scores_bounds[0]
    if scores_d == 0:
        scores_d = 0.1
    
    ZOOM = 0.5
    time_bounds[0] -= time_d * ZOOM
    time_bounds[1] += time_d * ZOOM
    scores_bounds[0] -= scores_d * ZOOM
    scores_bounds[1] += scores_d * ZOOM
    
    
    ax_time.set_xlabel('% of data used')
    ax_time.set_ylabel('Time')
    ax_time.set_ylim(time_bounds)
    
    ax_score.set_xlabel('% of data used')
    ax_score.set_ylabel('Score')
    ax_score.set_ylim(scores_bounds)

    #ax3.set_xlabel('Time')
    #ax3.set_ylabel('Score')
    #ax3.set_xlim(0, max_time_value(data) * 1.5)
    #ax3.set_ylim(scores_bounds)

    ax_highest_score.set_xlabel('Cumulative time')
    ax_highest_score.set_ylabel('Highest score')
    if cumulative_time:
        ax_highest_score.set_xlim(0, cumulative_time[len(cumulative_time)-1] * 1.1)
    else:
        ax_highest_score.set_xlim(0, 1)

    plt.draw()

    now = datetime.datetime.now()
    plt.savefig(FIG_DIR + 'fig_{}.pdf'.format(now.strftime('%Y-%m-%d-%H-%m-%S-%f')), format='pdf')



data = {}
models = {}
for name, _ in ALGORITHMS.items():
    data[name] = []
    models[name] = {'time': None, 'score': None}


#data = {'rnd_forest': [], 'log_reg': [], 'naive_bayes': []}
#models = {'rnd_forest': {'time': None, 'score': None}, 
          #'log_reg': {'time': None, 'score': None},
          #'naive_bayes': {'time': None, 'score': None}}

#params = {'rnd_forest': {}, 'log_reg': {}, 'naive_bayes': {}}


# Set up plot
plt.ion()
fig = plt.figure(1, figsize=(8, 12), dpi=80)

# Times
ax_time = plt.subplot(311)
plt.xlim(0, 1)
#plt.ylim(0, None)

# Scores
ax_score = plt.subplot(312)
plt.xlim(0, 1)
#plt.ylim(0, 1)

#ax3 = plt.subplot(413)
#plt.xlim(0, None)
#plt.ylim(0, 1)

ax_highest_score = plt.subplot(313)
plt.xlim(0, None)


fig.subplots_adjust(hspace=0.5)
plt.draw()

parser = ArgumentParser(description='Collect data')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('-s', '--synthetic', type=str, help='Create a synthetic dataset with the given parameters')
group.add_argument('-l', '--load-arff', type=str, help='Load dataset from arff file with the given name')
args = parser.parse_args()

if args.synthetic:
    dataset = create_dataset(eval(args.synthetic))
elif args.load_arff:
    dataset = load_dataset({'name': args.load_arff})

cumulative_time = [0]
highest_scores = [0]
while True:
    write_data_to_file(data)
    call_matlab_script()
    
    name, next_x = read_model_and_decision_file(data)

    
    update_plot(data, models, cumulative_time, highest_scores, plt, ax_time, ax_score, ax_highest_score)

    if name == 'STOP':
        raw_input("Press Enter to terminate...")

    print('Running {}...'.format(name))
    elapsed_time, avg_score = generate_datum(dataset, name_to_classifier_object(name), next_x, ALGORITHMS[name]['params'])
    data[name].append(Datum(next_x, elapsed_time, avg_score))
    
    highest_scores.append(max_score_value(data))
    cumulative_time.append(elapsed_time + cumulative_time[len(cumulative_time)-1])

   # update_plot(data, models, plt, ax_time, ax_score)

