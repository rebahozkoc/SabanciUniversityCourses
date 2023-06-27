import solver

# Format is (busGraph, trainGraph, startingCity, startType, transferTimeDict)

testCases = [
    ({"Istanbul": {"Bursa": 100, "Eskisehir": float("inf")},
      "Bursa": {"Istanbul": 100, "Eskisehir": 120},
      "Eskisehir": {"Istanbul": float("inf"), "Bursa": 120}},
     {"Istanbul": {"Bursa": float("inf"), "Eskisehir": 180},
      "Bursa": {"Istanbul": float("inf"), "Eskisehir": float("inf")},
      "Eskisehir": {"Istanbul": 180, "Bursa": float("inf")}},
     "Istanbul",
     "bus",
     {"Istanbul": 30, "Eskisehir": 10, "Bursa": float("inf")}
     ),  # Test Case 0 (given example)

    ({"Istanbul": {"Bursa": 100, "Eskisehir": float("inf")},
      "Bursa": {"Istanbul": 100, "Eskisehir": 120},
      "Eskisehir": {"Istanbul": float("inf"), "Bursa": 120}},
     {"Istanbul": {"Bursa": float("inf"), "Eskisehir": 180},
      "Bursa": {"Istanbul": float("inf"), "Eskisehir": float("inf")},
      "Eskisehir": {"Istanbul": 180, "Bursa": float("inf")}},
     "Istanbul",
     "train",
     {"Istanbul": 30, "Eskisehir": 10, "Bursa": float("inf")}
     ),  # Test Case 1

    ({"Istanbul": {"Bursa": 100, "Eskisehir": float("inf")},
      "Bursa": {"Istanbul": 100, "Eskisehir": 120},
      "Eskisehir": {"Istanbul": float("inf"), "Bursa": 120}},
     {"Istanbul": {"Bursa": float("inf"), "Eskisehir": 180},
      "Bursa": {"Istanbul": float("inf"), "Eskisehir": float("inf")},
      "Eskisehir": {"Istanbul": 180, "Bursa": float("inf")}},
     "Bursa",
     "bus",
     {"Istanbul": 30, "Eskisehir": 10, "Bursa": float("inf")}
     ),  # Test Case 2

    ({"Istanbul": {"Bursa": 100, "Eskisehir": float("inf")},
      "Bursa": {"Istanbul": 100, "Eskisehir": 120},
      "Eskisehir": {"Istanbul": float("inf"), "Bursa": 120}},
     {"Istanbul": {"Bursa": float("inf"), "Eskisehir": 180},
      "Bursa": {"Istanbul": float("inf"), "Eskisehir": float("inf")},
      "Eskisehir": {"Istanbul": 180, "Bursa": float("inf")}},
     "Bursa",
     "train",
     {"Istanbul": 30, "Eskisehir": 10, "Bursa": float("inf")}
     ),  # Test Case 3

    ({"Istanbul": {"Bursa": 100, "Eskisehir": float("inf"), "Ankara": float("inf")},
      "Bursa": {"Istanbul": 100, "Eskisehir": 120, "Ankara": 80},
      "Eskisehir": {"Istanbul": float("inf"), "Bursa": 120},
      "Ankara": {"Bursa": 80, "Istanbul": float("inf")}},
     {"Istanbul": {"Bursa": float("inf"), "Eskisehir": 180, "Ankara": 500},
      "Bursa": {"Istanbul": float("inf"), "Eskisehir": float("inf"), "Ankara": float("inf")},
      "Eskisehir": {"Istanbul": 180, "Bursa": float("inf")},
      "Ankara": {"Istanbul": 500, "Bursa": float("inf")}},
     "Ankara",
     "train",
     {"Istanbul": 30, "Eskisehir": 10, "Bursa": float("inf"), "Ankara": 40}
     ),  # Test Case 4

    ({"Istanbul": {"Bursa": 100},
      "Bursa": {"Istanbul": 100}},
     {"Istanbul": {"Bursa": float("inf")},
      "Bursa": {"Istanbul": float("inf")}},
     "Istanbul",
     "bus",
     {"Istanbul": 30, "Bursa": float("inf")}
     ),  # Test Case 5

    ({"Istanbul": {"Bursa": float("inf"), "Eskisehir": float("inf"), "Ankara": float("inf")},
      "Bursa": {"Istanbul": float("inf"), "Eskisehir": float("inf"), "Ankara": float("inf")},
      "Eskisehir": {"Istanbul": float("inf"), "Bursa": float("inf")},
      "Ankara": {"Bursa": float("inf"), "Istanbul": float("inf")}},
     {"Istanbul": {"Bursa": float("inf"), "Eskisehir": float("inf"), "Ankara": float("inf")},
      "Bursa": {"Istanbul": float("inf"), "Eskisehir": float("inf"), "Ankara": float("inf")},
      "Eskisehir": {"Istanbul": float("inf"), "Bursa": float("inf")},
      "Ankara": {"Istanbul": float("inf"), "Bursa": float("inf")}},
     "Ankara",
     "train",
     {"Istanbul": float("inf"), "Eskisehir": float("inf"), "Bursa": float("inf"), "Ankara": float("inf")}
     ),  # Test Case 6

    ({"Istanbul": {"Bursa": 0, "Eskisehir": 0, "Ankara": 0},
      "Bursa": {"Istanbul": 0, "Eskisehir": 0, "Ankara": 0},
      "Eskisehir": {"Istanbul": 0, "Bursa": 0},
      "Ankara": {"Bursa": 0, "Istanbul": 0}},
     {"Istanbul": {"Bursa": 0, "Eskisehir": 0, "Ankara": 0},
      "Bursa": {"Istanbul": 0, "Eskisehir": 0, "Ankara": 0},
      "Eskisehir": {"Istanbul": 0, "Bursa": 0},
      "Ankara": {"Istanbul": 0, "Bursa": 0}},
     "Ankara",
     "train",
     {"Istanbul": 0, "Eskisehir": 0, "Bursa": 0, "Ankara": 0}
     ),  # Test Case 7

    ({"Istanbul": {"Bursa": 100, "Eskisehir": float("inf"), "Ankara": float("inf")},
      "Bursa": {"Istanbul": 100, "Eskisehir": 120, "Ankara": 80},
      "Eskisehir": {"Istanbul": float("inf"), "Bursa": 120},
      "Ankara": {"Bursa": 80, "Istanbul": float("inf")}},
     {"Istanbul": {"Bursa": float("inf"), "Eskisehir": 180, "Ankara": -500},
      "Bursa": {"Istanbul": float("inf"), "Eskisehir": float("inf"), "Ankara": float("inf")},
      "Eskisehir": {"Istanbul": 180, "Bursa": float("inf")},
      "Ankara": {"Istanbul": -500, "Bursa": float("inf")}},
     "Ankara",
     "train",
     {"Istanbul": 30, "Eskisehir": 10, "Bursa": float("inf"), "Ankara": 40}
     ),  # Test Case 8

    ({"Istanbul": {"Bursa": 100, "Eskisehir": 50, "Ankara": 140, "Konya": 120},
      "Bursa": {"Istanbul": 100, "Eskisehir": 1000, "Ankara": 20, "Konya": 90},
      "Eskisehir": {"Istanbul": 50, "Bursa": 1000, "Ankara": 400, "Konya": 180},
      "Ankara": {"Bursa": 20, "Istanbul": 140, "Eskisehir": 1000, "Konya": 40},
      "Konya": {"Istanbul": 120, "Eskisehir": 180, "Ankara": 40, "Bursa": 90}},
     {"Istanbul": {"Bursa": 50, "Eskisehir": 150, "Ankara": 50, "Konya": 30},
      "Bursa": {"Istanbul": 50, "Eskisehir": 1000, "Ankara": 600, "Konya": 250},
      "Eskisehir": {"Istanbul": 150, "Bursa": 1000, "Ankara": 300, "Konya": 90},
      "Ankara": {"Bursa": 600, "Istanbul": 50, "Eskisehir": 300, "Konya": 10},
      "Konya": {"Istanbul": 30, "Eskisehir": 90, "Ankara": 10, "Bursa": 250}},
     "Bursa",
     "train",
     {"Istanbul": 33, "Eskisehir": 11, "Bursa": 44, "Ankara": 55, "Konya": 22}
     ),  # Test Case 9
]

testOracle = [
    {'Istanbul': 0, 'Bursa': 100, 'Eskisehir': 210},
    {'Istanbul': 0, 'Bursa': 130, 'Eskisehir': 180},
    {'Istanbul': 100, 'Bursa': 0, 'Eskisehir': 120},
    {'Istanbul': float("inf"), 'Bursa': 0, 'Eskisehir': float("inf")},
    {'Istanbul': 220, 'Bursa': 120, 'Eskisehir': 240, 'Ankara': 0},
    {'Istanbul': 0, 'Bursa': 100},  # Only two cities
    {'Istanbul': float("inf"), 'Bursa': float("inf"), 'Eskisehir': float("inf"), 'Ankara': 0},  # All inf
    {'Istanbul': 0, 'Bursa': 0, 'Eskisehir': 0, 'Ankara': 0},  # All zero
    "Negative cycle exists.",  # With negative cycle
    {'Istanbul': 50, 'Bursa': 0, 'Eskisehir': 133, 'Ankara': 64, 'Konya': 80}  # Five edges and complete graph
]

for index, i in enumerate(testCases):
    print("Test case", index)
    result = solver.bellmanFordSolver(*i)
    print(result)
    if result == testOracle[index]:
        print("Test case", index, "passed.\n")
    else:
        print("Test case", index, "failed.\n")
