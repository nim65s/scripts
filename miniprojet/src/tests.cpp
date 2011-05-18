#include <iostream>
#include <cstdio>
#include "matrices.h"

using namespace std;

int test_conversions(bool afficher) {
    cout << "\tTest conversions pleine => creuse 1 & 2" << endl;
    matricepleine B;
    B.m = 5;
    B.n = 5;
    B.coef[0][0] = 1.1;
    B.coef[0][3] = 4;
    B.coef[1][0] = 5;
    B.coef[1][1] = 2.2;
    B.coef[1][3] = 7;
    B.coef[2][0] = 6;
    B.coef[2][2] = 3.3;
    B.coef[2][3] = 8;
    B.coef[2][4] = 9;
    B.coef[3][2] = 11;
    B.coef[3][3] = 10.1;
    B.coef[4][4] = 12.7;
    if(afficher) B.afficher();
    if(afficher) cout << endl;

    matricecreuseun C;
    C = pleineversun(B);
    if(afficher) C.afficher();
    if(afficher) cout << endl;

    matricecreusedeux D;
    D = pleineversdeux(B);
    if(afficher) D.afficher();

    return 0; // Tu parles d'un test XD
}

int test_produits(bool afficher) {
    cout << "\tTest produit pleine*vecteur" << endl;
    matricepleine A;
    A.m = 5;
    A.n = 5;
    for(int i=0;i<5;i++) for(int j=0;j<5;j++) A.coef[i][j] = 0;
    for(int i=0;i<5;i++) A.coef[i][i] = i;
    if(afficher) A.afficher();
    if(afficher) cout << "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" << endl;
    vecteur v;
    v.n = 5;
    for(int i=0;i<5;i++) v.coef[i] = i;
    if(afficher) v.afficher();
    if(afficher) cout << "==================================" << endl;
    vecteur x;
    x = A*v;
    if(afficher) x.afficher();

    cout << "\tTest produit creuseun*vecteur" << endl;
    matricecreuseun E;
    E = pleineversun(A);
    if(afficher) E.afficher();
    if(afficher) cout << "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" << endl;
    if(afficher) v.afficher();
    if(afficher) cout << "==================================" << endl;
    vecteur y;
    y = E*v;
    if(afficher) y.afficher();

    cout << "\tTest produit creusedeux*vecteur" << endl;
    matricecreusedeux F;
    F = pleineversdeux(A);
    if(afficher) F.afficher();
    if(afficher) cout << "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" << endl;
    if(afficher) v.afficher();
    if(afficher) cout << "==================================" << endl;
    vecteur z;
    z = F*v;
    if(afficher) z.afficher();

    if(x==y && x==z && !(y!=z)) return 0;
    return 1;
}
