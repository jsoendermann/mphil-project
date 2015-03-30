def percentages_with_total_number_of_steps(n_steps):
    return (round(x * 1.0/n_steps, 3) for x in range(1, n_steps + 1))

def exp_incl_float_range(start, steps, end, b):
    return (round(start + (b**i-1)/(float(b)**(steps-1)-1)*(end-start), 3) for i in range(steps))

def exp_incl_int_range(start, steps, end, b):
    return (int(round(v)) for v in exp_incl_float_range(start, steps, end, b))
