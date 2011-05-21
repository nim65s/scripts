#include <iostream>
#include <cstdio>
#include "matrices.h"
#include "tests.h"

using namespace std;

int main() {
    cout << "\t\tMini Projet" << endl;
    int a = test_conversions(false);
    int b = test_produits(false);
    int c = test_ordonnage(true);
    if ( a == 0 && b==0 && c==0) cout << " OK " << endl;
    else cout << " KO : a=" << a << " | b=" << b << " | c=" << c << endl;
}
