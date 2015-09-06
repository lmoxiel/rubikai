This project investigates different algorithms and heuristics to solve a Rubik's cube.  For example, this project uses the local search algorithm "Simulated Annealing" and tries to apply a good cooling schedule with a min-conflicts heuristic in order to solve the problem.  Other algorithms are also tested including Greedy search.  Beyond the algorithms, various heuristics are used to choose the next state or successor from the current state.  At least three successor functions are provided: random-successor, novice-successor, and smart-successor.

Further techniques are being incorporated which uses Genetic Algorithms to breed partial solutions which would be useful for comparison with conventional methods.

This project has two parts.  The first part is the AI code written in Lisp that actually performs the work and outputs the events to a log file.  The second part is a C++ GUI written using Qt libraries which is used to import this log file to play back the simulation of solving the Rubik's Cube.

All observations and experiments are recorded in RESEARCH.txt.  Feel free to join us and experiment with solving such an interesting problem.