#include <iostream>
#include <queue>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <chrono>
#include <string>

int flowerCount = 40;
int gardenerCount = 2;
int gardenerSleepMs = 500;
int flowerWitherIntervalMs = 1000;
int maxFlowerWithers = 10;

std::mutex globalMutex;
std::condition_variable condition;
std::vector<std::thread> threads;

std::queue<int> witheredFlowers;
int witherCount = 0;
int randomSeed = 102;

auto start = std::chrono::system_clock::now();

void log(const std::string& message) {
    std::chrono::duration<double> elapsed = std::chrono::system_clock::now() - start;
    std::cout << elapsed.count() << "s: " << message << std::endl;
}

void gardenerFunction(int id) {
    // If flowerWitherIntervalMs is less than gardenerSleepMs
    // using !witheredFlowers.empty() we prevent program from finishing
    // before all withered flowers are watered
    while (witherCount < maxFlowerWithers || !witheredFlowers.empty()) {
        int flower;
        {
            std::unique_lock<std::mutex> lock(globalMutex);

            while (witheredFlowers.empty()) {
                // To handle notify_all() for finishing thread
                if (witherCount >= maxFlowerWithers) {
                    log("Gardener " + std::to_string(id) + " finished his work");
                    return;
                }
                condition.wait(lock);
            }

            flower = witheredFlowers.front();
            witheredFlowers.pop();

            log("Gardener " + std::to_string(id) + " watered flower " + std::to_string(flower));
            log("Gardener " + std::to_string(id) + " will be sleeping for " +
                std::to_string(gardenerSleepMs) + "ms");
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(gardenerSleepMs));
    }
    log("Gardener " + std::to_string(id) + " finished his work");
}

int main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
        std::string errorMsg = "Argument format: <flowerCount> <gardenerCount> <gardenerSleepMs> <flowerWitherIntervalMs> <maxFlowerWithers>"
                               "\nEvery argument must be greater than or equal 1";

        if (std::stoi(argv[i]) < 1) {
            std::cout << errorMsg << std::endl;
            return -1;
        }
        switch (i) {
            case 1:
                flowerCount = std::stoi(argv[i]);
                break;
            case 2:
                gardenerCount = std::stoi(argv[i]);
                break;
            case 3:
                gardenerSleepMs = std::stoi(argv[i]);
                break;
            case 4:
                flowerWitherIntervalMs = std::stoi(argv[i]);
                break;
            case 5:
                maxFlowerWithers = std::stoi(argv[i]);
                break;
            default:
                std::cout << "To many arguments" << std::endl;
                std::cout << errorMsg << std::endl;
                return -1;
        }
    }

    srand(randomSeed);

    for (int i = 0; i < gardenerCount; ++i) {
        threads.push_back(std::thread(gardenerFunction, i));
    }

    while (witherCount < maxFlowerWithers) {
        {
            std::unique_lock<std::mutex> lock(globalMutex);
            int witheredFlower = rand() % flowerCount + 1;
            witherCount++;
            witheredFlowers.push(witheredFlower);
            log( "Flower " + std::to_string(witheredFlower) + " withered");
        }

        condition.notify_one();
        std::this_thread::sleep_for(std::chrono::milliseconds(flowerWitherIntervalMs));
    }

    // To finish waiting threads
    condition.notify_all();

    for (auto& t : threads) {
        t.join();
    }

    threads.clear();

    return 0;
}