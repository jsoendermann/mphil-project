from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.cross_validation import KFold
from sklearn import cross_validation
from utils import start_timer, stop_timer
from datasets import load_datasets
import csv
import numpy as np

MIN_TREES = 1
MAX_TREES = 15
TREES_STEP = 2

MIN_MAX_FEATURES = 0.1
MAX_MAX_FEATURES = 0.5
MAX_FEATURES_STEP = 0.1

N_FOLDS = 10


datasets = load_datasets()



for dataset in datasets:
    csvfile = open('data_rnd_forest_{}.csv'.format(dataset['name']), 'wb')
    datawriter = csv.writer(csvfile)
    datawriter.writerow(['dataset_id', 'n_trees', 'max_features', 'percent_data', 'time', 'score'])

    for max_features in np.arange(MIN_MAX_FEATURES, MAX_MAX_FEATURES+MAX_FEATURES_STEP, MAX_FEATURES_STEP):
        for n_trees in range(MIN_TREES, MAX_TREES + TREES_STEP, TREES_STEP):

            X, y = dataset['X'], dataset['y']
            
            n_samples = len(X)
            kf = KFold(n_samples, N_FOLDS)

            STEPS = 10 


            for data_used in [x * 1.0 / STEPS for x in range(1, STEPS + 1)]:
                score_sum = 0
                score_count = 0
                
                start_timer()

                for train_index, test_index in kf:
                    train_index_subset = train_index[:len(train_index)*data_used]
                    X_train, X_test = X[train_index_subset], X[test_index]
                    y_train, y_test = y[train_index_subset], y[test_index]

                    model = RandomForestClassifier(n_estimators=n_trees, max_features=float(max_features))

                    clf = model.fit(X_train, y_train)
                    score = clf.score(X_test, y_test)

                    score_sum += score
                    score_count += 1

                elapsed_time = stop_timer()

                avg_score = score_sum/score_count


                output = [str(dataset['id']), n_trees, round(max_features, 2), data_used, elapsed_time, round(avg_score, 3)]

                print 'dataset: {}; n_trees: {}; max_features: {}; data_used: {}; elapsed_time: {}; avg_score: {}'.format(str(dataset['id']), n_trees, round(max_features, 2), data_used, elapsed_time, round(avg_score, 3))
                #print ', '.join(map(lambda x: str(x), output))
                datawriter.writerow(output)
    csvfile.flush()
    csvfile.close()


