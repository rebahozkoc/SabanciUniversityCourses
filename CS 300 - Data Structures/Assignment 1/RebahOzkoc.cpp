#include <fstream>
#include <iostream>
#include <queue>          // std::queue
#include "Process.cpp"
using namespace std;


bool check_process(queue<Process* > **queue_arr , int arr_size) {
	// return false if all queues are empty. (execution is done)
	for (int i = 0; i < arr_size; i++) {
		if (!queue_arr[i]->empty()) {
			return true;
		}
	}
	return false;
}

void cpu(queue<Process*>** & queue_arr, int i, string folderName, int QUEUE_NUM) {
	ofstream outfile;
	outfile.open(folderName + "/output.txt", std::ios_base::app);

	Process* prcs = queue_arr[i]->front();
	queue_arr[i]->pop();

	char command = prcs->getCommand();
	int prcsId = prcs->getId();

	if (command == '1') {
		// lower queue
		if (i > 0) {
			i = i - 1;
		}
	}
	if (prcs->empty()) {
		delete prcs;
		outfile << "E, " << "PC" << prcsId << ", " << "QX";
		// Write a new line if not the last process.
		if (check_process(queue_arr, QUEUE_NUM)) {
			outfile << endl;
		}
		return;
	}else {
		queue_arr[i]->push(prcs);
	}
	outfile << command << ", " << "PC" << prcsId << ", " << "Q" << i + 1 << endl;
}


void moveToTopmost(queue<Process*>**& queue_arr, int QUEUE_NUM, string folderName) {
	ofstream outfile;
	outfile.open(folderName + "/output.txt", std::ios_base::app);

	for (int i = QUEUE_NUM - 2; i >= 0; i--) {
		while (!queue_arr[i]->empty()){
			Process* prcs = queue_arr[i]->front();
			queue_arr[i]->pop();
			queue_arr[QUEUE_NUM - 1]->push(prcs);
			outfile << "B, PC" << prcs->getId() << ", Q" << QUEUE_NUM << endl;
		}
	}
}


int main() {
	char data[100];
	int QUEUE_NUM;
	int PROCESS_NUM;
	int S;
	string folderName;
	ifstream infile;
	cout << "Please enter the process folder name:";
	cin >> folderName;
	cout << "When all processes are completed, you can find execution sequence in " << folderName << "/output.txt" << endl;
	infile.open(folderName + "/configuration.txt");
	if (!infile.good()) {
		cout << folderName << " folder does not exist." << endl;
		return 0;
	}
	infile >> QUEUE_NUM; infile >> PROCESS_NUM; infile >> S;
	infile.close();
	
	// Create all queues 
	queue<Process *>** QUEUE_ARR = new queue<Process *>*[QUEUE_NUM];
	for (int i = 0; i < QUEUE_NUM; i++) {
		QUEUE_ARR[i] = new queue<Process*>();
	}

	// Create all proccesses at the topmost queue
	for (int i = 0; i < PROCESS_NUM; i++) {
		QUEUE_ARR[QUEUE_NUM - 1]->push(new Process(i+1, folderName));
	}

	int time_counter  = 0;
	// Loop until all processes end.
	while (check_process(QUEUE_ARR, QUEUE_NUM)) {
		for (int i = QUEUE_NUM-1; i >= 0; i--) {
			// Get the highest priority process.
			if (!QUEUE_ARR[i]->empty()) {
				cpu(QUEUE_ARR, i, folderName, QUEUE_NUM);
				time_counter = time_counter + 1;
				// Reset time after S times.
				if (time_counter == S) {
					moveToTopmost(QUEUE_ARR, QUEUE_NUM, folderName);
					time_counter = 0;
				}
				break;
			}
		}
	}
	return 0;
}