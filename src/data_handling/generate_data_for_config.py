import numpy as np
from time import time
import sys
from sklearn.metrics import roc_auc_score
from sklearn.cross_validation import KFold

# Wrapper around generate_data_for_config
def generate_datum(dataset, classifier, percentage_data, params):
    print('generate_datum; percentage_data: {}, params: {}'.format(percentage_data, str(params)))
    param_items = params.items()
    param_names = [p[0] for p in param_items]
    param_values = [p[1] for p in param_items]

    kf = KFold(dataset['n_samples'], 10, shuffle=True, random_state=42)

    param_values, percentage_data, elapsed_time, avg_score = generate_data_for_config(dataset, classifier, param_names, param_values, percentage_data, kf)

    return (elapsed_time, avg_score)

def generate_data_for_config(dataset, classifier, param_names, param_values, percentage_data, kf):
    X, y = dataset['X'], dataset['y']

    scores = []
    elapsed_time = 0
    
    # Loop over folds
    for train_index, test_index in kf:
        train_index_subset = train_index[:round(len(train_index) * percentage_data)]
        X_train, X_test = X[train_index_subset], X[test_index]
        y_train, y_test = y[train_index_subset], y[test_index]

        # Construct classifier
        model = classifier(**dict(zip(param_names, param_values)))

        # Stop training time
        t = time()
        clf = model.fit(X_train, y_train)
        elapsed_time += time() - t

        # Score using the appropriate metric
        if dataset['binary']:
            y_predict = clf.predict(X_test)
            score = roc_auc_score(y_test, y_predict)
        else:
            score = clf.score(X_test, y_test)
        scores.append(score)
        
    avg_score = round(np.mean(scores), 3)
    return (param_values, percentage_data, elapsed_time, avg_score)
