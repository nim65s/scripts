#include <iostream>
#include <cstdio>
#include <string>
#include "matrices.h"

using namespace std;

int test_conversions(bool afficher) {{{
    cout << "\tTest conversions entre matrices" << endl;
    matricepleine B(5, 5, 12);
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

    matricecreuseun C = pleineversun(B);
    if(afficher) C.afficher();
    if(afficher) cout << endl;

    matricecreusedeux D = pleineversdeux(B);
    if(afficher) D.afficher();
    if(afficher) cout << endl;

    matricecreusedeux E = unversdeux(C);
    if(afficher) E.afficher();

    if (D==E) return 0;
    return 1; 
}}}

int test_produits(bool afficher) {{{
    cout << "\tTest produit pleine*vecteur" << endl;
    matricepleine A(5, 5, 4);
    for(int i=0;i<A.m;i++) A.coef[i][i] = i; 
    if(afficher) A.afficher();
    if(afficher) cout << "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" << endl;
    vecteur v(5);
    for(int i=0;i<5;i++) v.coef[i] = i;
    if(afficher) v.afficher();
    if(afficher) cout << "==================================" << endl;
    vecteur x = A*v;
    if(afficher) x.afficher();

    cout << "\tTest produit creuseun*vecteur" << endl;
    matricecreuseun E = pleineversun(A);
    if(afficher) E.afficher();
    if(afficher) cout << "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" << endl;
    if(afficher) v.afficher();
    if(afficher) cout << "==================================" << endl;
    vecteur y = E*v;
    if(afficher) y.afficher();

    cout << "\tTest produit creusedeux*vecteur" << endl;
    matricecreusedeux F = pleineversdeux(A);
    if(afficher) F.afficher();
    if(afficher) cout << "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" << endl;
    if(afficher) v.afficher();
    if(afficher) cout << "==================================" << endl;
    vecteur z = F*v;
    if(afficher) z.afficher();

    if(x==y && x==z && !(y!=z)) return 0;
    return 1;
}}}

int test_ordonnage(bool afficher) {{{
    cout << "\tTest ordonnage" << endl;
    matricecreuseun A(5, 5, 4);
    for(int i=0;i<4;i++) {
        A.i[i] = i;
        A.j[i] = i;
        A.coef[i] = i;
    }
    if (afficher) A.afficher();
    if (estenbordel(A)) {
        if (afficher) cout << "A est en bordel..." << endl;
        return 1;
    }
    else if (afficher) cout << "A est en ordre" << endl;

    matricecreuseun B(5, 5, 2);
    B.i[0] = 4;
    B.j[0] = 2;
    B.coef[0] = 42;
    B.i[1] = 2;
    B.j[1] = 4;
    B.coef[1] = 24;
    if (afficher) B.afficher();
    if (!estenbordel(B)) {
        if (afficher) cout << "B est en ordre..." << endl;
        return 1;
    }
    else if (afficher) cout << "B est en bordel" << endl;

    B = ordonne(B);
    if (afficher) B.afficher();
    if (estenbordel(B)) {
        if (afficher) cout << "B est en bordel..." << endl;
        return 1;
    }
    else if (afficher) cout << "B est en ordre" << endl;

    return 0;
}}}

int test_fichiers(bool afficher) {{{
    matricecreuseun A = lireun("../test.mx");
    if (afficher) {
        cout << endl << "A" << endl;
        A.afficher();
    }
    matricecreuseun B = ordonne(A);
    if (afficher) {
        cout << endl << "B" << endl;
        B.afficher();
    }
    ecrire(B, "B");
    matricecreusedeux C = unversdeux(B);
    if (afficher) {
        cout << endl << "C" << endl;
        C.afficher();
    }
    ecrire(C, "C");
    matricecreusedeux D = liredeux("C");
    if (afficher) {
        cout << endl << "D" << endl;
        D.afficher();
    }
    if (D == C) return 0;
    return 1;
}}}

// vim: set foldmethod=marker:
