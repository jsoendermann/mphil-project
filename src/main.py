import numpy as np
import matplotlib.pyplot as plt
from data_handling.generate_data_for_config import generate_datum
from os.path import isfile, join
from os import remove
from time import sleep
from subprocess import call

VAR_DIR = '/Users/jan/Dropbox/mphil_project/repo/var/'
DATA_FILENAME = 'data.txt'
MODEL_AND_DECISION_FILENAME = 'model_and_decision.txt'

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

data = {'rnd_forest': [Datum(0.1, 1.1, 0.65), Datum(0.2, 2.2, 0.72), Datum(0.3, 3.3, 0.75)],
        'log_reg': [Datum(0.1, 0.3, 0.5), Datum(0.2, 0.4, 0.56)]}
#data = {'rnd_forest': [], 'log_reg': []}

write_data_to_file(data)

plt.ion()


#rnd_forest_time_prediction = Model(0, 1, [x/100.0 for x in range(101)], [0.2] * 101)

fig = plt.figure(1)

# Times
ax1 = plt.subplot(211)

ax1.set_xlabel('% of data used')
ax1.set_ylabel('Time')

plt.xlim(0, 1)
plt.ylim(0, None)


#print (rnd_forest_x)
#print (rnd_forest_time_y)
#print np.array(rnd_forest_time_prediction.x())
#print np.array(rnd_forest_time_prediction.mean)

#plt.plot(rnd_forest_x, rnd_forest_time_y, 'bo')
#plt.plot(rnd_forest_time_prediction.x(), np.array(rnd_forest_time_prediction.mean), 'k')
#plt.fill_between(rnd_forest_time_prediction.x(), rnd_forest_time_prediction.twice_std_dev_below(), rnd_forest_time_prediction.twice_std_dev_above(), facecolor='blue', alpha=0.1, interpolate=True)

# Scores
ax2 = plt.subplot(212)

ax2.set_xlabel('% of data used')
ax2.set_ylabel('Score')

plt.xlim(0, 1)
plt.ylim(0, 1)



##plt.plot(t2, np.cos(2*np.pi*t2), 'r--')

fig.subplots_adjust(hspace=0.25)
##plt.show()

plt.draw()

call_matlab_script()

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
