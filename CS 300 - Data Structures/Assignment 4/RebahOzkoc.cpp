#include <iostream>
#include <unordered_map>
#include <vector>
#include <fstream>
#include <sstream>

using namespace std;


string which_operation(string from, string to) {
    // Which operation should we make to create "to" from "from"
    if (from.size() > to.size()) { // Deletion
        int i;
        for (i = 0; i < to.size(); i++) {
            if (from[i] != to[i]) {
                return "(delete " + string(1, from[i]) + " at position " + to_string(i+1) + ")";
            }
        }
        return "(delete " + string(1, from[i]) + " at position " + to_string(i+1) + ")";
    }
    if (from.size() < to.size()) { // Insertion
        int i;
        for (i = 0; i < from.size(); i++) {
            if (from[i] != to[i]) {
                return "(insert " + string(1, to[i]) + " after position " + to_string(i) + ")";
            }
        }
        return "(insert " + string(1, to[i]) + " after position " + to_string(i) + ")";
    }
    if (from.size() == to.size()) { // Substitution
        int i;
        for (i = 0; i < from.size(); i++) {
            if (from[i] != to[i]) {
                return "(change " + string(1, from[i]) + " at position " + to_string(i + 1) + " to " + string(1, to[i]) + ")";
            }
        }
    }
    return "No operation available"; 
}


struct Vertex {
    std::string word;
    std::vector<std::string> adjList;
    int dist;
    bool known;
    std::string path;
    Vertex() : word(""), adjList(), dist(std::numeric_limits<int>::max()), known(false), path("NOT_VERTEX") {}
    Vertex(std::string word) : word(word), adjList(), dist(std::numeric_limits<int>::max()), known(false), path("NOT_VERTEX") {}

    // returns true if the words of the vertices are the same.
    bool operator==(const Vertex& rhs) const {
        return this->word == rhs.word;
    }
    bool operator!=(const Vertex& rhs) const {
        return !(*this == rhs);
    }
};


class Graph {
public:
    std::unordered_map<std::string, Vertex> arr;

    Graph() : arr() {}

    void addVertex(std::string word) {
        arr[word] = Vertex(word);
    }

    void addEdge(std::string src, std::string dest) {
        // No duplicates are allowed 
        if (src == dest) return;
        arr[src].adjList.push_back(dest);

    }

    void printGraph() {
        std::unordered_map<std::string, Vertex>::iterator itr;
        std::cout << "\nAll Elements : \n";
        for (itr = arr.begin(); itr != arr.end(); itr++) {
            // itr works as a pointer to pair<string, double>
            // type itr->first stores the key part  and
            // itr->second stores the value part
            for (int i = 0; i < itr->second.adjList.size(); i++) {
                std::cout << itr->second.adjList[i] << "---";
            }
            std::cout << std::endl;
        }
    }

    void unweighted(string from) {

        // Make all vertices unknown and distance infinity and reset their paths
        std::unordered_map<std::string, Vertex>::iterator itr1;
        for (itr1 = arr.begin(); itr1 != arr.end(); itr1++) {
            itr1->second.dist = std::numeric_limits<int>::max();
            itr1->second.known = false;
            itr1->second.path = "NOT_VERTEX";
        }

        arr[from].dist = 0;

        // check all possible distances
        for (int currDist = 0; currDist < arr.size(); currDist++) {
            // locate all not known vertices at the current distance
            std::unordered_map<std::string, Vertex>::iterator itr;
            for (itr = arr.begin(); itr != arr.end(); itr++) {
                if (!itr->second.known && itr->second.dist == currDist) {
                    // mark vertex as known
                    itr->second.known = true;
                    // Compute distances to neighboring vert.
                    for (int j = 0; j < itr->second.adjList.size(); j++) {

                        if (arr[itr->second.adjList[j]].dist == std::numeric_limits<int>::max()) {
                            arr[itr->second.adjList[j]].dist = currDist + 1;
                            arr[itr->second.adjList[j]].path = itr->first;
                        }
                    }
                }
            }
        }
    }

/**
* Print shortest path to v after dijkstra has run.
* Assume that the path exists.
*/
    string printPath(Vertex& v) {
        Vertex temp = v;
        string result = v.word + "\n";
        while (temp.path != "NOT_VERTEX") {
            result += arr[temp.path].word + " " + which_operation(temp.word, temp.path) + "\n";
            temp = arr[temp.path];
        }
        return result;
    }
};


int lev_distance(std::string a, std::string b) {
    // Implemented a matrix version of Levenstein Distance algorithm
    // www.en.wikipedia.org/wiki/Levenshtein_distance

    const int m = a.size();
    const int n = b.size();

    // Create the matrix
    int** matrix = new int* [m + 1];
    for (int i = 0; i <= m; i++) {
        matrix[i] = new int[n + 1];
    }

    for (int i = 0; i <= m; i++) {
        for (int j = 0; j <= n; j++) {
            if (i == 0)
                matrix[i][j] = j;

            else if (j == 0)
                matrix[i][j] = i; 

            else if (a[i - 1] == b[j - 1])
                matrix[i][j] = matrix[i - 1][j - 1];

            else
                matrix[i][j]
                = 1
                + min(matrix[i][j - 1], min(
                    matrix[i - 1][j], 
                    matrix[i - 1][j - 1])); 
        }
    }
    return matrix[m][n];
}


void mainLoop(std::vector<std::string> & words, Graph & graph) {
    string from, to;

    while (true) {
        cin >> from;
        cin >> to;
        if (from.size() == 0 || to.size() == 0) {
            cout << "Words can not be empty." << endl;
            continue;
        }
        if (from.at(0) == '*') {
            cout << "Program ended successfully." << endl;
            return;
        }
        if (std::find(words.begin(), words.end(), from) == words.end()) {
            cout << "First word is not in the words.txt" << endl;
            continue;
        }
        if (std::find(words.begin(), words.end(), to) == words.end()) {
            cout << "Second word is not in the words.txt" << endl;
            continue;
        }
        
        // Calculate path coming from all the nodes to the to vertex
        graph.unweighted(to);
        
        // If the from vertex does not have a path to to vertex
        if (graph.arr[from].path == "NOT_VERTEX") {
            cout << "There is no way to convert " << from << " to " << to << endl;
            continue;
        }

        // Print the path from from vertex to to vertex
        Vertex& v = graph.arr[from];
        cout << graph.printPath(v);
    }
}


int main(){
    
    std::vector<std::string> words;
    std::ifstream infile("words.txt");
    std::string line;
    // read words.txt file to a vector word by word.
    while (std::getline(infile, line))
    {
        std::istringstream iss(line);
        std::string word;
        if (!(iss >> word)) { break; } // error
        words.push_back(word);
    }

    // Add all words to the graph as node.
    Graph graph = Graph();
    for (int i = 0; i < words.size(); i++) {
        graph.addVertex(words[i]);
    }

    // Add edge between the nodes if the difference is 1.
    for (std::string a : words) {
        for (std::string b : words) {
            if (lev_distance(a, b) == 1) {
                graph.addEdge(a, b);
            }
        }
    }
    // Run loop to calculate paths between the words that given from the input
    mainLoop(words, graph);

    return 0;
}
