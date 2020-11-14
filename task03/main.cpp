#include <iostream>
#include <vector>
#include <string>
#include <thread>
#include <mutex>

int m = -1, n = -1, k = -1;
int nextTask = 0;
std::vector<std::string> catalog;

std::mutex mutex;

void func() {

    mutex.lock();
    int row = nextTask++;
    mutex.unlock();

    while (nextTask - 1 < m) {

        std::string record = "row " + std::to_string(row) + "\n";
        for (int i = 0; i < n; i++) {
            record += "\tbookcase " + std::to_string(i) + "\n";
            for (int j = 0; j < k; j++) {
                record += "\t\tbook " + std::to_string(j) + "\n";
            }
        }

        catalog.insert(catalog.begin() + row, record);

        mutex.lock();
        row = nextTask++;
        mutex.unlock();
    }
}

int main() {
    setlocale(LC_ALL, "Russian");

    while (m < 0) {
        std::cout << "Enter number of rows:";
        std::cin >> m;
    }
    while (n < 0) {
        std::cout << "Enter number of bookcases in one row:";
        std::cin >> n;
    }
    while (k < 0) {
        std::cout << "Enter number of books in a bookcases:";
        std::cin >> k;
    }

    catalog.resize(m);

    std::thread t1(func);
    std::thread t2(func);
    t1.join();
    t2.join();

    for (int i = 0; i < m; ++i) {
        std::cout << catalog.at(i) << std::endl;
    }
    return 0;
}
