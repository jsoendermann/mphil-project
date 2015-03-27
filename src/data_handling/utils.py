from time import time

_timer = 0
def tic():
    global _timer
    _timer = time()

def toc():
    elapsed_time = round(time() - _timer, 3)
    return elapsed_time
