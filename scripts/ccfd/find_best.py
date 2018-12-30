import os
import random
import subprocess

import yaml

FLAGS = {
    "batch_size": [4096],
    "epochs": list(range(10, 100)),
    "second_layer_units": list(range(1, 20)),
    "encoder_activation": ["relu", "sigmoid", "tanh"],
    "decoder_activation": ["relu", "sigmoid", "tanh"],
    "data_dir": ["./data/ccfd/discretized", "./data/ccfd/normalized_l2", "./data/ccfd/normalized_min_max",
                 "./data/ccfd/raw", "./data/ccfd/scaled"],
    "metric": ["mae", "mse"]
}

WORKING_DIR = "./models/ccfd/find_best"
POP_SIZE = 10
DNA_SIZE = len(FLAGS.items())
GENERATIONS = 10
INDIVIDUALS_COUNTER = 0


def random_population():
    population = []
    for _ in range(POP_SIZE):
        population.append(random_individual())
    return population


def random_individual():
    global INDIVIDUALS_COUNTER
    dna = {}
    for k, v in FLAGS.items():
        dna[k] = random.choice(v)
    INDIVIDUALS_COUNTER += 1
    return (INDIVIDUALS_COUNTER, dna)


def weighted_choice(items):
    weight_total = sum((item[1] for item in items))
    n = random.uniform(0, weight_total)
    for item, weight in items:
        if n < weight:
            return item
        n = n - weight


def model_dir(individual):
    return WORKING_DIR + "/" + str(individual[0])


def prepare_model(individual):
    os.makedirs(model_dir(individual), exist_ok=True)
    with open(model_dir(individual) + "/flags.yml", "w") as file:
        yaml.dump(individual[1], file, default_flow_style=False)


def train_and_evaluate(individual):
    commands = [
        "Rscript ./scripts/ccfd/train_3_layers.R {model_dir} | tee {model_dir}/train.log".format(
            model_dir=model_dir(individual)),
        "Rscript ./scripts/ccfd/evaluate.R {model_dir} | tee {model_dir}/evaluate.log".format(
            model_dir=model_dir(individual)),
    ]
    for command in commands:
        subprocess.call(command, shell=True)


def fitness(individual):
    with open(model_dir(individual) + "/evaluate.log") as file:
        for line in file:
            key = "Area under the curve:"
            if key in line:
                return float(line.split(':')[1].strip())


def mutate(dna):
    dna_out = {}
    mutation_chance = 100
    for k, v in FLAGS.items():
        if int(random.random() * mutation_chance) == 1:
            dna_out[k] = random.choice(v)
        else:
            dna_out[k] = dna[k]
    return dna_out


def crossover(dna1, dna2):
    position = int(random.random() * DNA_SIZE)
    keys = list(FLAGS.keys())
    keys = (keys[:position], keys[position:])
    dna_outs = ({}, {})
    for k in keys[0]:
        dna_outs[0][k] = dna1[k]
        dna_outs[1][k] = dna2[k]
    for k in keys[1]:
        dna_outs[0][k] = dna2[k]
        dna_outs[1][k] = dna1[k]
    return dna_outs


if __name__ == "__main__":
    population = random_population()

    for individual in population:
        prepare_model(individual)
        train_and_evaluate(individual)

    weighted_population = []
    for generation in range(GENERATIONS):
        print("Generation %s... Random sample: '%s'" % (generation, population[0]))

        # Add individuals and their respective fitness levels to the weighted
        # population list. This will be used to pull out individuals via certain
        # probabilities during the selection phase. Then, reset the population list
        # so we can repopulate it after selection.
        for individual in population:
            fitness_val = fitness(individual)
            weighted_population.append((individual, fitness_val))

        population = []

        # Select two random individuals, based on their fitness probabilites, cross
        # their genes over at a random point, mutate them, and add them back to the
        # population for the next iteration.
        for _ in range(int(POP_SIZE / 2)):
            # Selection
            dna1 = weighted_choice(weighted_population)
            dna2 = weighted_choice(weighted_population)

            # Crossover
            dna1, dna2 = crossover(dna1[1], dna2[1])

            # Mutate and add back into the population.
            INDIVIDUALS_COUNTER += 1
            ind1 = (INDIVIDUALS_COUNTER, mutate(dna1))
            INDIVIDUALS_COUNTER += 1
            ind2 = (INDIVIDUALS_COUNTER, mutate(dna2))

            prepare_model(ind1)
            train_and_evaluate(ind2)

            prepare_model(ind2)
            train_and_evaluate(ind2)

            population.append(ind1)
            population.append(ind2)

    best_individual = weighted_population[0][0]
    max_fitness = weighted_population[0][1]
    for individual, ind_fitness in weighted_population:
        if ind_fitness >= max_fitness:
            best_individual = individual
            max_fitness = ind_fitness

    print(weighted_population)
    print("Best individual: %s" % best_individual[0])
