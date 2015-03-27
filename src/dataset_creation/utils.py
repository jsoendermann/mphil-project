from time import time

_timer = 0
def start_timer():
    global _timer
    _timer = time()

def stop_timer():
    elapsed_time = round(time() - _timer, 2)
    return elapsed_time
