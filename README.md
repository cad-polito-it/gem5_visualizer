# Gem5 Pipeline Visualizer
## Requirements
- Qt == 6.8
- CMake >= 3.28 && CMake < 4.x
## Building
1. Clone the repository
2. Create build directory
```
cd gem5_visualizer
mkdir build
cd build
```
3. Dependacies & misc
```
sudo apt install qtwayland5
sudo apt install qtwayland5-dev-tools
sudo apt install libxcb-cursor0
```
4. Run CMake
```
export PATH="<path_to_your_qt_installation>/libexec:/<path_to_your_qt_installation>/bin:$PATH"
export QT_FRAMEWORK_BYPASS_LICENSE_CHECK=1
export LIBGL_ALWAYS_SOFTWARE=1
cmake .. -DCMAKE_BUILD_TYPE=Release -DQT_CMAKE_PREFIX_PATH=<path_to_your_qt_installation>
```
The path to Qt should point to the folder that contains the `bin/` subfolder. For instance, on a Linux system on which you have installed Qt 6.8.3 under `/opt` you should run:
```
export PATH="/opt/Qt/6.8.3/gcc_64/libexec:/opt/Qt/6.8.3/gcc_64/bin:$PATH"
cmake .. -DCMAKE_BUILD_TYPE=Release -DQT_CMAKE_PREFIX_PATH=/opt/Qt/6.8.3/gcc_64
```
5. Run Make
```
make
```
## License and Copyright
This software is licensed under the European Union Public License (EUPL) version 1.2. Copyright (C) Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025.
You may use, modify, and redistribute this software under the terms of the EUPL v1.2. The full license text  is available at https://eupl.eu/1.2/en/.
This software is provided 'as is' without any warranties. For more details, please refer to the license documentation included with this program.
