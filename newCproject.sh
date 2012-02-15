#!/bin/bash

if [[ -z $1 ]]
then
    echo -e " Nom du projet ? "
    read nom
else
    nom="$1"
fi

echo -e "Création des répertoires... "
mkdir -v $nom
echo -e "\t\t on va dans le répertoire $nom"
cd $nom
mkdir -v bin build src
echo -e "Création du CMakeLists.txt..."
echo -e "cmake_minimum_required(VERSION 2.6)" > CMakeLists.txt
echo -e "project($nom)" >> CMakeLists.txt
echo -e "" >> CMakeLists.txt
echo -e "file(" >> CMakeLists.txt
echo -e "\tGLOB_RECURSE" >> CMakeLists.txt
echo -e "\tsource_files" >> CMakeLists.txt
echo -e "\t../src/*" >> CMakeLists.txt
echo -e "\t)" >> CMakeLists.txt
echo -e "" >> CMakeLists.txt
echo -e "add_executable(" >> CMakeLists.txt
echo -e "\t../bin/$nom" >> CMakeLists.txt
echo -e "\t\${source_files}" >> CMakeLists.txt
echo -e "\t)" >> CMakeLists.txt
echo -e 'set(CMAKE_CXX_FLAGS "-g -Wall -pedantic -Wextra")' >> CMakeLists.txt
touch src/main.cpp
cd build
cmake .. -G "Unix Makefiles"

exit 0
