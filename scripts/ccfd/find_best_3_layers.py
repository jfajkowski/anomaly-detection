import random

FLAGS = {
    "batch_size": [4096],
    "epochs": list(range(10, 100)),
    "second_layer_units": list(range(1, 20)),
    "encoder_activation": ["relu", "sigmoid", "tanh"],
    "decoder_activation": ["relu", "sigmoid", "tanh"],
    "data_dir": ["./data/ccfd/discretized", "./data/ccfd/normalized_l2", "./data/ccfd/normalized_min_max", "./data/ccfd/raw", "./data/ccfd/scaled"],
    "metric": ["mae", "mse"]
}

POP_SIZE = 10
DNA_SIZE = len(FLAGS.items())
GENERATIONS = 10

def random_population():
  population = []
  for _ in range(POP_SIZE):
    population.append(random_dna())
  return population

def random_dna():
    dna = {}
    for k, v in FLAGS.items():
        dna[k] = random.choice(v)
    return dna

def weighted_choice(items):
  weight_total = sum((item[1] for item in items))
  n = random.uniform(0, weight_total)
  for item, weight in items:
    if n < weight:
      return item
    n = n - weight

def fitness(dna):
  fitness = 0
  for c in range(DNA_SIZE):
    fitness += abs(ord(dna[c]) - ord(OPTIMAL[c]))
  return fitness

def mutate(dna):
  dna_out = {}
  mutation_chance = 100
  for k, v in FLAGS.items():
    if int(random.random() * mutation_chance) == 1:
      dna_out += random.choice(v)
    else:
      dna_out += dna[k]
  return dna_out

def crossover(dna1, dna2):
  position = int(random.random() * DNA_SIZE)
  keys = (FLAGS.keys()[:position], FLAGS.keys()[position:])
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

  for generation in range(GENERATIONS):
    print("Generation %s... Random sample: '%s'" % (generation, population[0]))
    weighted_population = []

    # Add individuals and their respective fitness levels to the weighted
    # population list. This will be used to pull out individuals via certain
    # probabilities during the selection phase. Then, reset the population list
    # so we can repopulate it after selection.
    for individual in population:
      fitness_val = fitness(individual)

      # Generate the (individual,fitness) pair, taking in account whether or
      # not we will accidently divide by zero.
      if fitness_val == 0:
        pair = (individual, 1.0)
      else:
        pair = (individual, 1.0 / fitness_val)

      weighted_population.append(pair)

    population = []

    # Select two random individuals, based on their fitness probabilites, cross
    # their genes over at a random point, mutate them, and add them back to the
    # population for the next iteration.
    for _ in range(int(POP_SIZE / 2)):
      # Selection
      ind1 = weighted_choice(weighted_population)
      ind2 = weighted_choice(weighted_population)

      # Crossover
      ind1, ind2 = crossover(ind1, ind2)

      # Mutate and add back into the population.
      population.append(mutate(ind1))
      population.append(mutate(ind2))


  best_individual = population[0]
  minimum_fitness = fitness(population[0])

  for individual in population:
    ind_fitness = fitness(individual)
    if ind_fitness <= minimum_fitness:
      best_individual = individual
      minimum_fitness = ind_fitness

  print("Best individual: %s" % best_individual)
