import solver

# Format is (busGraph, trainGraph, startingCity, startType, transferTimeDict)

testCases = [
    ({"A": {"B": 20, "E": float("inf")},
      "B": {"A": 20, "C": 20, "E": float("inf"), "F": 40},
      "C": {"B": 20, "D": 15},
      "D": {"C": 15, "G": 10},
      "E": {"A": float("inf"), "B": float("inf"), "F": float("inf")},
      "F": {"B": 40, "E": float("inf"), "G": 10},
      "G": {"D": 10, "F": 10}},

     {"A": {"B": 10, "E": 20},
      "B": {"A": 10, "C": float("inf"), "E": 5, "F": float("inf")},
      "C": {"B": float("inf"), "D": float("inf")},
      "D": {"C": float("inf"), "G": float("inf")},
      "E": {"A": 20, "B": 5, "F": 10},
      "F": {"B": float("inf"), "E": 10, "G": 30},
      "G": {"D": float("inf"), "F": 30}},
     "A",
     "bus",
     {"A": 5, "B": 10, "C": float("inf"), "D": float("inf"), "E": float("inf"), "F": 10, "G": 5}
     ),  # Test Case 1

    ({"A": {"B": 40, "C": float("inf")},
      "B": {"A": 40, "C": 5, "D": float("inf")},
      "C": {"A": float("inf"), "B": 5, "E": 5, "D": float("inf")},
      "D": {"B": float("inf"), "C": float("inf"), "F": float("inf")},
      "E": {"C": 5, "F": 5},
      "F": {"D": float("inf"), "E": 5}},

     {"A": {"B": float("inf"), "C": 10},
      "B": {"A": float("inf"), "C": float("inf"), "D": 5},
      "C": {"A": 10, "B": float("inf"), "E": float("inf"), "D": 5},
      "D": {"B": 5, "C": 5, "F": 40},
      "E": {"C": float("inf"), "F": float("inf")},
      "F": {"D": 40, "E": float("inf")}},
     "A",
     "bus",
     {"A": 5, "B": 5, "C": 25, "D": float("inf"), "E": float("inf"), "F": 10}
     ),  # Test Case 2

    ({"A": {"B": 30, "C": 30, "E": float("inf")},
      "B": {"A": 30, "C": 20, "D": 22},
      "C": {"A": 30, "B": 20, "E": float("inf"), "D": 20},
      "D": {"B": 22, "C": 20},
      "E": {"A": float("inf"), "C": float("inf")},
      },

     {"A": {"B": float("inf"), "C": float("inf"), "E": 40},
      "B": {"A": float("inf"), "C": float("inf"), "D": float("inf")},
      "C": {"A": 20, "B": float("inf"), "E": 40, "D": float("inf")},
      "D": {"B": float("inf"), "C": float("inf")},
      "E": {"A": 75, "C": 40},
      },
     "A",
     "bus",
     {"A": 5, "B": float("inf"), "C": 10, "D": float("inf"), "E": float("inf")}
     ),  # Test Case 3

    ({"A": {"C": 23, "D": 27},  # D, C
      "B": {"C": 18, "D": 13, "F": float("inf")},  # d, c, f
      "C": {"A": 23, "B": 18, "E": 17},  # A, E, B
      "D": {"A": 27, "B": 13, "E": 20, "F": float("inf")},  # A, B, E, F
      "E": {"C": 17, "D": 20, "F": float("inf")},  # C, D, F
      "F": {"B": float("inf"), "D": float("inf")}  # D, B
      },

     {"A": {"C": float("inf"), "D": float("inf")},  # D, C
      "B": {"C": float("inf"), "D": float("inf"), "F": 11},  # d, c, f
      "C": {"A": float("inf"), "B": float("inf"), "E": float("inf")},  # A, E, B
      "D": {"A": float("inf"), "B": float("inf"), "E": 12, "F": 22},  # A, B, E, F
      "E": {"C": float("inf"), "D": 12, "F": 17},  # C, D, F
      "F": {"B": 11, "D": 22}  # D, B
      },
     "A",
     "bus",
     {"A": float("inf"), "B": 4, "C": float("inf"), "D": 7, "E": 8, "F": float("inf")}
     ),  # Test Case 4

]

for index, i in enumerate(testCases):
    print("Test case", index + 1)
    result = solver.bellmanFordSolver(*i)
    print(result)
