#pragma once
#ifndef PROCESS_H
#define PROCESS_H
#include <fstream>
#include <sstream>
#include <iostream>
#include <queue>
using namespace std;

template <typename T>
std::string NumberToString(T Number){
	std::ostringstream ss;
	ss << Number;
	return ss.str();
}

class Process {
private:
	int id;
	string folderName;
	std::ifstream infile;
	queue<char> memory;

public:
	Process(int id, std::string folderName) :id(id), folderName(folderName), infile(), memory(){
		infile.open(folderName + "/p" + NumberToString(id)  +".txt");

		// Load instructions from disk to memory.
		char value;
		infile >> value;
		if (!infile.good()) {
			cout << "Process " << id << " does not exist.\n Raising exception..." << endl;
			throw std::invalid_argument("Missing process file.");
		}
		while (value != '-') {
			memory.push(value);
			infile >> value;
		}
	}
	int	getId() {
		return this->id;
	}
	char getCommand() {
		char value = memory.front();
		memory.pop();
		return value;
	}

	bool empty() {
		return memory.empty();
	}
};
#endif