#ifndef MATRICES_H_INCLUDED
#define MATRICES_H_INCLUDED

#include <string>

// TODO un bool estenbordel dans matricecreuseun et manipuler que des ordonnées
// TODO mettre des assert(bool) ou des exit(int) partout

class vecteur {
    public:
        int n;
        float * coef;
        vecteur();
        vecteur(int dim);
        ~vecteur();
        void afficher();
};
bool operator==(vecteur a, vecteur b);
bool operator!=(vecteur a, vecteur b);

class matricepleine {
    public:
       int m;
       int n;
       int nz;
       //float * coef;
       float coef[10][10];
       matricepleine();
       matricepleine(int lig, int col, int nzv);
       ~matricepleine();
       void afficher();
};
bool operator==(matricepleine A, matricepleine B);
bool operator!=(matricepleine A, matricepleine B);
vecteur operator*(matricepleine A, vecteur v);

class matricecreuseun {
    public:
        int m;
        int n;
        int nz;
        int * i;
        int * j;
        float * coef;
        matricecreuseun();
        matricecreuseun(int lig, int col, int nzv);
        ~matricecreuseun();
        void afficher();
};
bool operator==(matricecreuseun A, matricecreuseun B);
bool operator!=(matricecreuseun A, matricecreuseun B);
vecteur operator*(matricecreuseun M, vecteur v);
matricecreuseun pleineversun(matricepleine A);
matricecreuseun ordonne(matricecreuseun A);
bool estenbordel(matricecreuseun A);
matricecreuseun lireun();
matricecreuseun lireun(std::string file);
int ecrire(matricecreuseun A);
int ecrire(matricecreuseun A, std::string file);

class matricecreusedeux {
    public:
        int m;
        int n;
        int nz;
        float * vals;
        int * j;
        int * II;
        matricecreusedeux();
        matricecreusedeux(int lig, int col, int nzv);
        ~matricecreusedeux();
        void afficher();
};
bool operator==(matricecreusedeux A, matricecreusedeux B);
bool operator!=(matricecreusedeux A, matricecreusedeux B);
vecteur operator*(matricecreusedeux M, vecteur v);
matricecreusedeux pleineversdeux(matricepleine A);
matricecreusedeux unversdeux(matricecreuseun A);
matricecreusedeux liredeux();
matricecreusedeux liredeux(std::string file);
int ecrire(matricecreusedeux A);
int ecrire(matricecreusedeux A, std::string file);

float abs(float x);
vecteur operator*(vecteur v, float x);
vecteur operator/(vecteur v, float x);
float norme(vecteur v);

#endif
