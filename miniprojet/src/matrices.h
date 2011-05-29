#ifndef MATRICES_H_INCLUDED
#define MATRICES_H_INCLUDED

#include <string>

// TODO un bool estenbordel dans matricecreuseun et manipuler que des ordonnées

class complexe {
    public:
        double re;
        double im;
        complexe();
        void afficher();
};
bool operator==(complexe a, complexe b);
bool operator!=(complexe a, complexe b);
bool isnull(complexe a);
complexe operator*(complexe a, complexe b);
complexe operator*(complexe a, float b);
complexe operator*(complexe a, double b);
complexe operator/(complexe a, complexe b);
complexe operator/(complexe a, float b);
complexe operator/(complexe a, double b);
complexe operator+(complexe a, complexe b);
complexe operator-(complexe a, complexe b);
double norme(complexe a);
complexe pow(complexe a, int b);

class vecteur {
    public:
        int n;
        complexe * coef;
        vecteur();
        vecteur(int dim);
        ~vecteur();
        void afficher();
};
bool operator==(vecteur a, vecteur b);
bool operator!=(vecteur a, vecteur b);
vecteur operator*(vecteur v, float x);
vecteur operator*(vecteur v, complexe a);
vecteur operator/(vecteur v, float x);
float norme(vecteur v);

class matricepleine {
    public:
       int m;
       int n;
       int nz;
       //complexe * coef;
       complexe coef[10][10];
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
        complexe * coef;
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
matricecreuseun lireun(bool comp);
matricecreuseun lireun(std::string file, bool comp);
int ecrire(matricecreuseun A);
int ecrire(matricecreuseun A, std::string file);

class matricecreusedeux {
    public:
        int m;
        int n;
        int nz;
        complexe * vals;
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
matricecreusedeux liredeux(bool comp);
matricecreusedeux liredeux(std::string file, bool comp);
int ecrire(matricecreusedeux A);
int ecrire(matricecreusedeux A, std::string file);

std::string demandernomdufichier();

float abs(float x);

#endif
