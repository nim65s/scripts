#include <iostream>
#include <cstdio>
#include "matrices.h"
#include "tests.h"

using namespace std;

int main() {
    cout << "\t\tMini Projet" << endl;
    int a = test_conversions(false);
    int b = test_produits(false);
    if ( a == 0 && b==0 ) cout << " OK " << endl;
}
