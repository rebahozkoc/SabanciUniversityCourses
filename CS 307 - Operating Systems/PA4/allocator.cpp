#include <iostream>
#include <list>
#include <iterator>
using namespace std;

class Node{
    public:
        int size;
        int id;
        int index;

        Node(int Size, int Index): size(Size), id(-1), index(Index){}
        Node(int Size, int Index, int ID): size(Size), id(ID), index(Index){}

        bool isFree(){
            return id == -1;
        }
};

class HeapManager{
    private:
        std::list<Node> heapList;
        pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;


    public:
        HeapManager(): heapList(){}
        int initHeap(int size){
            // Always initializes correctly and returns 1.
            heapList.push_back(Node(size, 0));
            print();
            return 1;
        }

        int myMalloc(int ID, int size){
            pthread_mutex_lock(&mutex);
            std::list <Node> :: iterator it;
            it = heapList.begin();
            // iterate until a big enough place is found
            for(int i = 0 ; i < heapList.size(); i++){
                if ((*it).id == -1 && (*it).size >= size){
                    int tempIndex = (*it).index;
                    int tempSize = (*it).size;
                    (*it).size = size;
                    (*it).id = ID;
                    heapList.insert(++it, Node(tempSize-size, tempIndex + size, -1));
                    cout << "Allocated for thread " << ID << endl; 
                    print();
                    pthread_mutex_unlock(&mutex);
                    return tempIndex;
                }
                else{
                    it++;
                }
            }
            cout << "Can not allocate, requested size " << size << " for thread " << ID << " is bigger than remaining size" << endl;
            print();
            pthread_mutex_unlock(&mutex);
            return -1;
        }

        int myFree(int ID, int index){
            pthread_mutex_lock(&mutex);
            std::list <Node> :: iterator it;

            it = heapList.begin(); 
            // Iterate until the end or the specified Node is found.
            while(it != heapList.end()){

                if ((*it).id == ID && (*it).index == index){
                    // Free the Node
                    (*it).id = -1;
                    
                    // Merge if the preciding or succeeding element is also free
                    mergeNodes();
                    mergeNodes();
                    
                    cout << "Freed for thread "<< ID << endl;
                    print();
                    pthread_mutex_unlock(&mutex);
                    return 1;
                }
                it++;
            }
            cout << "Failed to free" << endl;
            print();
            pthread_mutex_unlock(&mutex);
            return -1;
        }

        void print(){
            std::list <Node> :: iterator it;
            it = heapList.begin();
            cout << "[" << (*it).id  << "]" << "[" << (*it).size  << "]" << "[" << (*it).index  << "]";
            it++;
            for(; it != heapList.end(); ++it)
                cout << "---" << "[" << (*it).id  << "]" << "[" << (*it).size  << "]" << "[" << (*it).index  << "]";
            cout << '\n';
        }

        void mergeNodes(){
            std::list <Node> :: iterator it;
            it = heapList.begin(); 
            

            while(it != heapList.end()){
                // If the Node is free check if the also free
                if ((*it).id == -1 && it != heapList.end()){
                    it++;
                    // If the next node is free copy the size of the next node to the current node and delete next node
                    if(it != heapList.end() && (*it).id == -1){
                        int tempSize = it->size;
                        it--;
                        (*it).size += tempSize;
                        it++;
                        it = heapList.erase(it);
                        return;
                    }
                }
                else{
                    it++;
                }

                
            }
        }
};