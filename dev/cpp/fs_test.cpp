#include <iostream>
#include <filesystem>

int main() {
  std::cout << "Hello, let's see if it works. What's in the current folder:" << std::endl;
  for (auto &file: std::filesystem::recursive_directory_iterator("./")) {
    std::cout << file.path() << std::endl;
  }
}
