def bellmanFordSolver(busGraph, trainGraph, startCity, startType, transferTime):
    assert startType == "train" or startType == "bus"
    V = busGraph.keys()  # Vertex list
    assert startCity in V
    s = startCity
    assert type(transferTime) is dict
    assert transferTime.keys() == V

    # Create distance dictionaries db (bus), dt (train)
    db = dict()
    dt = dict()

    for i in V:
        db[i] = float("inf")
        dt[i] = float("inf")

    if startType == "train":
        dt[s] = 0
        db[s] = transferTime[s]
    else:
        dt[s] = transferTime[s]
        db[s] = 0

    for k in range(len(V)):
        for u in busGraph.keys():
            for v in busGraph[u].keys():
                if dt[v] > dt[u] + trainGraph[u][v]:
                    dt[v] = dt[u] + trainGraph[u][v]
                if db[v] > db[u] + busGraph[u][v]:
                    db[v] = db[u] + busGraph[u][v]
                if dt[v] > db[u] + busGraph[u][v] + transferTime[v]:
                    dt[v] = db[u] + busGraph[u][v] + transferTime[v]
                if db[v] > dt[u] + trainGraph[u][v] + transferTime[v]:
                    db[v] = dt[u] + trainGraph[u][v] + transferTime[v]

    # Check if any negative circle exist
    for u in busGraph.keys():
        for v in busGraph[u].keys():
            if dt[v] > dt[u] + trainGraph[u][v]:
                print("Negative cycle exists.")
                return "Negative cycle exists."
            if db[v] > db[u] + busGraph[u][v]:
                print("Negative cycle exists.")
                return "Negative cycle exists."
            if dt[v] > db[u] + busGraph[u][v] + transferTime[v]:
                print("Negative cycle exists.")
                return "Negative cycle exists."
            if db[v] > dt[u] + trainGraph[u][v] + transferTime[v]:
                print("Negative cycle exists.")
                return "Negative cycle exists."

    # Merge the results and find min
    resultDict = dict()
    for v in V:
        if dt[v] < db[v]:
            resultDict[v] = dt[v]
        else:
            resultDict[v] = db[v]

    return resultDict

