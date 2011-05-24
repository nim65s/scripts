#ifndef MATRICES_H_INCLUDED
#define MATRICES_H_INCLUDED

// TODO mettre des petites & partout :)
// TODO les templates caybonmangezen

class vecteur {
    public:
        int n;
        float * coef;
        void afficher();
};
bool operator==(vecteur a, vecteur b);
bool operator!=(vecteur a, vecteur b);

class matricepleine {
    public:
       int n;
       int m;
       float coef[100][100];
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
        int i[100];
        int j[100];
        float coef[100];
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
        float vals[100];
        int j[100];
        int II[100];
        void afficher();
};
bool operator==(matricecreusedeux A, matricecreusedeux B);
bool operator!=(matricecreusedeux A, matricecreusedeux B);
vecteur operator*(matricecreusedeux M, vecteur v);
matricecreusedeux pleineversdeux(matricepleine A);
matricecreusedeux unversdeux(matricecreuseun A);

#endif
