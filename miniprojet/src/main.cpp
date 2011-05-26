#include <iostream>
#include <cstdio>
#include <string>
#include "matrices.h"
#include "tests.h"

using namespace std;

int main() {
    cout << "\t\tMini Projet" << endl;
    int a = test_conversions(true);
    int b = test_produits(true);
    int c = test_ordonnage(true);
    int d = test_fichiers(true);
    if ( a == 0 && b==0 && c==0 && d == 0) cout << " OK " << endl;
    else cout << " KO : a=" << a << " | b=" << b << " | c=" << c << " | d=" << d << endl;
}
