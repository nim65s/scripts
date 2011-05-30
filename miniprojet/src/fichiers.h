#ifndef HISTORIQUE_H_INCLUDED
#define HISTORIQUE_H_INCLUDED

#include <string>

matricecreuseun lireun(bool const & comp);
matricecreuseun lireun(std::string const & file, bool const & comp);
matricecreusedeux liredeux(bool const & comp);
matricecreusedeux liredeux(std::string const & file, bool const & comp);

int ecrire(matricecreuseun const & A);
int ecrire(matricecreuseun const & A, std::string const & file);
int ecrire(matricecreusedeux const & A);
int ecrire(matricecreusedeux const & A, std::string const & file);

std::string demandernomdufichier();

#endif
