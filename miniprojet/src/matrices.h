#ifndef MATRICES_H_INCLUDED
#define MATRICES_H_INCLUDED

// TODO les templates caybonmangezen
// TODO un bool estenbordel dans matricecreuseun
// ASK faut vraiment dynamiser les pleines ?
// ASK ça vaut le coup de passer par des références ?

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
       float coef[100][100];
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

#endif
