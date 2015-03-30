from generate_data_for_configuration import generate_data
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LinearRegression
from sys import argv
from datasets import load_datasets, create_dataset
from utils import percentages_with_total_number_of_steps, exp_incl_float_range, exp_incl_int_range


datasets = [
        create_dataset({'n_samples': 500, 'n_features': 5000, 'n_classes': 2}),
        create_dataset({'n_samples': 2500, 'n_features': 2500, 'n_classes': 2}),
        create_dataset({'n_samples': 5000, 'n_features': 500, 'n_classes': 2}),
        create_dataset({'n_samples': 5000, 'n_features': 500, 'n_classes': 20, 'n_informative': 6}),
        create_dataset({'n_samples': 5000, 'n_features': 500, 'n_classes': 2, 'n_informative': 100}),
        create_dataset({'n_samples': 5000, 'n_features': 500, 'n_classes': 2, 'n_redundant': 450}),
        create_dataset({'n_samples': 5000, 'n_features': 500, 'n_classes': 2, 'n_clusters_per_class': 100, 'n_informative': 100}),
        create_dataset({'n_samples': 5000, 'n_features': 500, 'n_classes': 2, 'flip_y': 0.2}),
    ]

generate_data('rnd_forest', RandomForestClassifier, datasets,
        exp_incl_float_range(0.01, 10, 1.0, 1.1),
        {'n_estimators':   exp_incl_int_range(10, 10, 512, 1.1), 
         'max_leaf_nodes': exp_incl_int_range(1024, 10, 8196, 1.1)})
