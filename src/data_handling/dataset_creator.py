from scipy.io.arff import loadarff
from datasets import create_dataset
from utils import exp_incl_float_range, name_to_classifier_object
from generate_data_for_config import generate_datum
from datetime import datetime
import matplotlib.pyplot as plt

FIG_DIR = '/Users/jan/Dropbox/mphil_project/repo/figs/'


dataset = create_dataset({'n_samples': 7500, 'n_features': 120, 'n_classes': 6, 'n_informative': 40})

algorithms = [
        {'name': 'rnd_forest', 'parameters': {'n_estimators': 50}, 'time': [], 'score': []},
        {'name': 'log_reg', 'parameters': {}, 'time': [], 'score': []}
        ]

data_range = exp_incl_float_range(0.1, 10, 1, 1.5)

def draw(ax, plt):
    ax.cla()
    ax.plot(data_range[:len(algorithms[0]['score'])], algorithms[0]['score'], 'r-')
    ax.plot(data_range[:len(algorithms[1]['score'])], algorithms[1]['score'], 'b-')
    ax.set_xlabel('% data')
    ax.set_ylabel('Score')
    plt.draw()

plt.ion()
fig, ax = plt.subplots(1,1)
for percentage_data in data_range:
    for algorithm_data in algorithms:
        print '{}; {}'.format(algorithm_data['name'], str(percentage_data))

        cl = name_to_classifier_object(algorithm_data['name'])
        time, score = generate_datum(dataset, cl, percentage_data, algorithm_data['parameters'])
        algorithm_data['time'].append(time)
        algorithm_data['score'].append(score)
        draw(ax, plt)

plt.show()
plt.savefig(FIG_DIR + 'fig_{}.pdf'.format(datetime.now().strftime('%Y-%m-%d_%H-%M-%S-%f')), format='pdf')
