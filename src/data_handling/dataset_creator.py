from scipy.io.arff import loadarff
from datasets import create_dataset
from utils import exp_incl_float_range, name_to_classifier_object
from generate_data_for_config import generate_datum
import matplotlib.pyplot as plt


dataset = create_dataset({'n_samples': 5000, 'n_features': 80, 'n_classes': 5, 'n_informative': 40})

algorithms = [
        {'name': 'rnd_forest', 'parameters': {'n_estimators': 50}, 'time': [], 'score': []},
        {'name': 'log_reg', 'parameters': {}, 'time': [], 'score': []}
        ]

data_range = exp_incl_float_range(0.1, 10, 1, 1.5)

for percentage_data in data_range:
    for algorithm_data in algorithms:
        print '{}; {}'.format(algorithm_data['name'], str(percentage_data))

        cl = name_to_classifier_object(algorithm_data['name'])
        time, score = generate_datum(dataset, cl, percentage_data, algorithm_data['parameters'])
        algorithm_data['time'].append(time)
        algorithm_data['score'].append(score)


fig, ax = plt.subplots(1,1)
ax.plot(data_range, algorithms[0]['score'], 'r-')
ax.plot(data_range, algorithms[1]['score'], 'b-')
plt.show()
