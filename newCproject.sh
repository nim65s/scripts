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
echo -e "cmake_minimum_required(VERSION 2.6)" > build/CMakeLists.txt
echo -e "project($nom)" >> build/CMakeLists.txt
echo -e "" >> build/CMakeLists.txt
echo -e "file(" >> build/CMakeLists.txt
echo -e "\tGLOB_RECURSE" >> build/CMakeLists.txt
echo -e "\tsource_files" >> build/CMakeLists.txt
echo -e "\t../src/*" >> build/CMakeLists.txt
echo -e "\t)" >> build/CMakeLists.txt
echo -e "" >> build/CMakeLists.txt
echo -e "add_executable(" >> build/CMakeLists.txt
echo -e "\t../bin/$nom" >> build/CMakeLists.txt
echo -e "\t\${source_files}" >> build/CMakeLists.txt
echo -e "\t)" >> build/CMakeLists.txt
touch src/main.cpp
cd build
cmake . -G "Unix Makefiles"

exit 0
