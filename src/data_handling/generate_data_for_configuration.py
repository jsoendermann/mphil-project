from datasets import load_datasets
from csv import writer
from sklearn.cross_validation import KFold
from itertools import product
import numpy as np
from joblib import Parallel, delayed
from time import time
import sys

def _generate_data_for_config(dataset, classifier, param_names, param_values, percentage_data, kf, header):
    X, y = dataset['X'], dataset['y']

    scores = []

    t = time()
    
    for train_index, test_index in kf:
        train_index_subset = train_index[:len(train_index)*percentage_data]
        X_train, X_test = X[train_index_subset], X[test_index]
        y_train, y_test = y[train_index_subset], y[test_index]

        model = classifier(**dict(zip(param_names, param_values)))
        clf = model.fit(X_train, y_train)
        score = clf.score(X_test, y_test)

        scores.append(score)
        
    elapsed_time = time() - t
    avg_score = round(np.mean(scores), 3)

    output = [dataset['id']] + list(param_values) + [percentage_data, elapsed_time, avg_score]
    sys.stout.write(' '.join(['{0}: {1:7.2f};'.format(*t) for t in zip(header, output)]))
    sys.stdout.flush()
    
    return (param_values, percentage_data, elapsed_time, avg_score)


def generate_data(name, classifier, parameters, n_folds=10, datasets='small'):
    params_tuples = parameters.items()
    param_names = [t[0] for t in params_tuples]
    param_generators = [t[1] for t in params_tuples]

    datasets = load_datasets(datasets=datasets)

    for dataset in datasets:
        n_samples = dataset['n_samples']
        kf = KFold(n_samples, n_folds)

        csvfile = open('out/data_{0}_{1}.csv'.format(name, dataset['name']), 'wb')

        datawriter = writer(csvfile)
        header = ['dataset_id'] + param_names + ['percentage_data', 'time', 'score']
        datawriter.writerow(header)

        all_parameter_values = product(*param_generators)
        all_percentage_data_values = [x * 1.0 / n_folds for x in range(1, n_folds + 1)]
        all_configs = product(all_parameter_values, all_percentage_data_values)

        p = Parallel(n_jobs=-1)
        res = p(delayed(_generate_data_for_config)
                (dataset, classifier, param_names, param_values, percentage_data, kf, header) 
                for (param_values, percentage_data) in all_configs)

        for param_values, percentage_data, elapsed_time, avg_score in res:
            output = [dataset['id']] + list(param_values) + [percentage_data, elapsed_time, avg_score]
            datawriter.writerow(output)
                
        csvfile.close()
