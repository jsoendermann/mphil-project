from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.naive_bayes import GaussianNB

def percentages_with_total_number_of_steps(n_steps):
    return [round(x * 1.0/n_steps, 3) for x in range(1, n_steps + 1)]

def exp_incl_float_range(start, steps, end, b):
    return [round(start + (b**i-1)/(float(b)**(steps-1)-1)*(end-start), 6) for i in range(steps)]

def exp_incl_int_range(start, steps, end, b):
    return [int(round(v)) for v in exp_incl_float_range(start, steps, end, b)]

def convert_range_string(s):
    t = s.split(':')
    start = float(t[1])
    steps = int(t[2])
    if steps == 1:
        return [start]
    end = float(t[3])
    if t[0] == 'a':
        return [round(start + (end-start)*i/(steps-1), 3) for i in range(steps)]
    elif t[0] == 'g':
        growth_param = float(t[4])
        return exp_incl_float_range(start, steps, end, growth_param)

def name_to_classifier_object(name):
    classifier = None
    if name == 'rnd_forest':
        classifier = RandomForestClassifier
    elif name == 'log_reg':
        classifier = LogisticRegression
    elif name == 'svm':
        classifier = SVC
    elif name == 'naive_bayes':
        classifier = GaussianNB
    return classifier
