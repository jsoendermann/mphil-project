from datasets import load_datasets
from csv import writer
from sklearn.cross_validation import KFold
from itertools import product
from utils import tic, toc
import numpy as np

def generate_data(name, classifier, parameters, n_folds=10, datasets='small'):
    params_tuples = parameters.items()
    param_names = [t[0] for t in params_tuples]
    param_generators = [t[1] for t in params_tuples]

    datasets = load_datasets(datasets=datasets)

    for dataset in datasets:
        X, y, n_samples = dataset['X'], dataset['y'], dataset['n_samples']
        kf = KFold(n_samples, n_folds)

        csvfile = open('out/data_{0}_{1}.csv'.format(name, dataset['name']), 'wb')

        datawriter = writer(csvfile)
        header = ['dataset_id'] + param_names + ['percentage_data', 'time', 'score']
        datawriter.writerow(header)
        
        for param_values in product(*param_generators):
            for percentage_data in [x * 1.0 / n_folds for x in range(1, n_folds + 1)]:
                scores = []

                tic()
                
                for train_index, test_index in kf:
                    train_index_subset = train_index[:len(train_index)*percentage_data]
                    X_train, X_test = X[train_index_subset], X[test_index]
                    y_train, y_test = y[train_index_subset], y[test_index]

                    model = classifier(**dict(zip(param_names, param_values)))
                    clf = model.fit(X_train, y_train)
                    score = clf.score(X_test, y_test)

                    scores.append(score)
                    
                elapsed_time = toc()
                avg_score = round(np.mean(scores), 3)

                output = [dataset['id']] + list(param_values) + [percentage_data, elapsed_time, avg_score]
                datawriter.writerow(output)
                
                print(' '.join(['{0}: {1:7.2f};'.format(*t) for t in zip(header, output)]))
        csvfile.close()
