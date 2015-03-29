from generate_data_for_configuration import generate_data
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LinearRegression

generate_data('rnd_forest', RandomForestClassifier, 
        {'n_estimators': [2**x for x in range(4, 10)], 
            'max_depth': [2**x for x in range(6, 14)]}, n_folds=6, datasets=['abalone', 'germancredit'])
