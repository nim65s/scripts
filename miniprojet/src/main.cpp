#include <iostream>
#include <cstdio>
#include "matrices.h"

using namespace std;

int main() {
    cout << "\t\tMini Projet" << endl;
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
    B.afficher();
    cout << endl;

    matricecreuseun C;
    C = pleineversun(B);
    C.afficher();
    cout << endl;

    matricecreusedeux D;
    D = pleineversdeux(B);
    D.afficher();

    cout << "\tTest produit pleine*vecteur" << endl;
    matricepleine A;
    A.m = 5;
    A.n = 5;
    for(int i=0;i<5;i++) A.coef[i][i] = i;
    A.afficher();
    cout << "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" << endl;
    vecteur v;
    v.n = 5;
    for(int i=0;i<5;i++) v.coef[i] = i;
    v.afficher();
    cout << "==================================" << endl;
    vecteur x;
    x = A*v;
    x.afficher();

    cout << "\tTest produit creuseun*vecteur" << endl;
    matricecreuseun E;
    E = pleineversun(A);
    E.afficher();
    cout << "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" << endl;
    v.afficher();
    cout << "==================================" << endl;
    vecteur y;
    y = E*v;
    y.afficher();

    cout << "\tTest produit creusedeux*vecteur" << endl;
    matricecreusedeux F;
    F = pleineversdeux(A);
    F.afficher();
    cout << "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" << endl;
    v.afficher();
    cout << "==================================" << endl;
    vecteur z;
    z = F*v;
    z.afficher();

    if(x==y && x==z && !(y!=z)) cout << "X==Y && X==Z && !(Y!=Z)" << endl;
}
