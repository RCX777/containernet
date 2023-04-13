from typing import Callable

class Algorithm:

    name = ""

    def __init__(self, model, data_loaders):
        self.train_loader = data_loaders[0]
        self.test_loader = data_loaders[1]
        self.model = model

    def setup(self, num_workers: int, use_gpu: bool, *args, **kwargs):
        raise NotImplementedError(
            "Implement this function for setting up the workers and initialize all that is needed.")

    def run(self, iterations: int, evaluate: Callable):
        raise NotImplementedError(
            "Implement this function for running the algorithm")
