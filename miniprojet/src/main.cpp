#include <iostream>
#include <cstdio>
#include <string>
#include <cmath>
#include <assert.h>
#include "matrices.h"
#include "historique.h"
#include "tests.h"
#include "algo.h"

using namespace std;

int main() {
    cout << "\t\tMini Projet" << endl;
    bool afficher = true;
    int a(test_conversions(afficher));
    int b(test_produits(afficher));
    int c(test_ordonnage(afficher));
    int d(test_fichiers(afficher));
    int e(test_historique(afficher));

    int f(algo(lireun("../test.mx", false).versdeux(), afficher));
    
    if ( a == 0 && b==0 && c==0 && d == 0 && e == 0 && f == 0 ) {
        cout << " OK " << endl;
        return 0;
    }
    else {
        cout << " KO : a=" << a << " | b=" << b << " | c=" << c << " | d=" << d << " | e=" << e << " | f=" << f << endl; 
        return 1;
    }
}
