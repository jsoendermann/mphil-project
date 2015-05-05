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

VAR_DIR = '/Users/jan/Dropbox/mphil_project/repo/var/'
DATA_FILENAME = 'data.txt'
# TODO change filename to models_and...
MODEL_AND_DECISION_FILENAME = 'model_and_decision.txt'
COLOURS = {'rnd_forest': {'single_letter': 'r', 'full_name': 'red'}, 'log_reg': {'single_letter': 'b', 'full_name': 'blue'}}

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


def write_data_to_file(data):
    filename = join(VAR_DIR, DATA_FILENAME)

    if isfile(filename):
        remove(filename)
    
    with open(filename, 'a') as f:
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
    # TODO move dir names to constants
    call(["/Applications/MATLAB_R2014b.app/bin/matlab",
          "-nodisplay", 
          "-nosplash", 
          "-nodesktop", 
          "-r", 
          "run('/Users/jan/Dropbox/mphil_project/repo/src/matlab/model_and_decide.m'); exit();"])

def read_model_and_decision_file():
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
            name = lines[i]
            time_m_raw = lines[i + 1]
            time_sd_raw = lines[i + 2]
            score_m_raw = lines[i + 3]
            score_sd_raw = lines[i + 4]

            time_m_str = time_m_raw[len('time_m: '):]
            time_sd_str = time_sd_raw[len('time_sd: '):]
            score_m_str = score_m_raw[len('score_m: '):]
            score_sd_str = score_sd_raw[len('score_sd: '):]

            time_m = map(lambda s: float(s), time_m_str.split())
            time_sd = map(lambda s: float(s), time_sd_str.split())
            score_m = map(lambda s: float(s), score_m_str.split())
            score_sd = map(lambda s: float(s), score_sd_str.split())

            models[name] = {'time': Model(0, 1, time_m, time_sd), 'score': Model(0, 1, score_m, score_sd)}

            i += 6

def update_plot(data, models, plt, ax1, ax2):
    ax1.cla()
    ax2.cla()

    for name, datapoints in data.items():
        xs = [d.x for d in datapoints]
        times = [d.time for d in datapoints]
        scores = [d.score for d in datapoints]

        ax1.plot(xs, times, COLOURS[name]['single_letter']+'o')
        ax2.plot(xs, scores, COLOURS[name]['single_letter']+'o')

    for name, models in models.items():
        model_time = models['time']
        model_score = models['score']

        if model_time:
            ax1.fill_between(model_time.x(), 
                             model_time.twice_std_dev_below(), 
                             model_time.twice_std_dev_above(), 
                             facecolor=COLOURS[name]['full_name'], 
                             alpha=0.1, 
                             interpolate=True)
        if model_score:
            print(model_score.mean)
            print(model_score.std_dev)
            print(model_score.x())
            print(model_score.twice_std_dev_below())

            ax2.fill_between(model_score.x(), 
                             model_score.twice_std_dev_below(), 
                             model_score.twice_std_dev_above(), 
                             facecolor=COLOURS[name]['full_name'], 
                             alpha=0.1, 
                             interpolate=True)


    ax1.set_xlabel('% of data used')
    ax1.set_ylabel('Time')
    
    ax2.set_xlabel('% of data used')
    ax2.set_ylabel('Score')

    #ax1.xlim(0, 1)
    #ax1.ylim(0, None)
    #ax2.xlim(0, 1)
    #ax2.ylim(0, 1)

    plt.draw()




    

#data = {'rnd_forest': [Datum(0.1, 1.1, 0.65), Datum(0.2, 2.2, 0.72), Datum(0.3, 3.3, 0.75)],
#        'log_reg': [Datum(0.1, 0.3, 0.5), Datum(0.2, 0.4, 0.56)]}
data = {'rnd_forest': [], 'log_reg': []}
models = {'rnd_forest': {'time': None, 'score': None}, 'log_reg': {'time': None, 'score': None}}

params = {'rnd_forest': {}, 'log_reg': {}}


# Set up plot
plt.ion()
fig = plt.figure(1)

# Times
ax1 = plt.subplot(211)
plt.xlim(0, 1)
#plt.ylim(0, None)

# Scores
ax2 = plt.subplot(212)
plt.xlim(0, 1)
#plt.ylim(0, 1)

fig.subplots_adjust(hspace=0.25)
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

while True:
    write_data_to_file(data)
    call_matlab_script()
    update_plot(data, models, plt, ax1, ax2)
    name, next_x = read_model_and_decision_file()
    if name == 'STOP':
        while True:
            sleep(1)
    
    elapsed_time, avg_score = generate_datum(dataset, name_to_classifier_object(name), next_x, params[name])
    data[name].append(Datum(next_x, elapsed_time, avg_score))
    
    update_plot(data, models, plt, ax1, ax2)


#call_matlab_script()
#update_plot(data, models, plt, ax1, ax2)
#print('data')
#sleep(2)
#read_model_and_decision_file()
#update_plot(data, models, plt, ax1, ax2)
#print('with models')
#sleep(100)

#ax1.cla()

##plt.plot(t2, np.cos(2*np.pi*t2), 'r--')

##plt.show()


##

#print (rnd_forest_x)
#print (rnd_forest_time_y)
#print np.array(rnd_forest_time_prediction.x())
#print np.array(rnd_forest_time_prediction.mean)

#plt.plot(rnd_forest_x, rnd_forest_time_y, 'bo')
#plt.plot(rnd_forest_time_prediction.x(), np.array(rnd_forest_time_prediction.mean), 'k')
#plt.fill_between(rnd_forest_time_prediction.x(), rnd_forest_time_prediction.twice_std_dev_below(), rnd_forest_time_prediction.twice_std_dev_above(), facecolor='blue', alpha=0.1, interpolate=True)


#sleep(0.05)
#while True:
    #pass

#/Applications/MATLAB_R2014b.app/bin/matlab -nodisplay -nosplash -nodesktop -r "run('/Users/jan/Dropbox/mphil_project/repo/src/matlab/model_and_decide.m'); exit();"

# 

#f, (ax1, ax2) = plt.subplots(2, sharex=True, sharey=True)
#ax1.plot(rnd_forest_x, rnd_forest_score_y, 'bo', rnd_forest_x, rnd_forest_score_y, 'k')
#ax1.set_title('Random forest')

#ax1.set_ylabel('Score')
#ax2.set_ylabel('Time')
#ax2.set_xlabel('% of data used')

##ax2.scatter(x, y)
##ax3.scatter(x, 2 * y ** 2 - 1, color='r')
## Fine-tune figure; make subplots close to each other and hide x ticks for
## all but bottom plot.
#f.subplots_adjust(hspace=0)
#plt.setp([a.get_xticklabels() for a in f.axes[:-1]], visible=False)


##fig, (ax1, ax2) = plt.subplots(2, sharex=True, sharey=True)



###ax1 = plt.subplot(211)

#plt.xlim(0, 1)
#plt.ylim(0, 1)

###ax1.plot(X, Y, 'bo', X, Y, 'k')

###ax1.set_xlabel('% of data used')
###ax1.set_ylabel('Score')

###ax2 = plt.subplot(212)

#####ax2.set_ylabel('Time')

###plt.plot(t2, np.cos(2*np.pi*t2), 'r--')
#plt.show()
