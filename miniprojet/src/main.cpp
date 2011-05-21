#include <iostream>
#include <cstdio>
#include "matrices.h"
#include "tests.h"

using namespace std;

int main() {
    cout << "\t\tMini Projet" << endl;
    int a = test_conversions(true);
    int b = test_produits(true);
    if ( a == 0 && b==0 ) cout << " OK " << endl;
    else cout << " KO : a=" << a << "| b=" << b << endl;
}
