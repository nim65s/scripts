#include <iostream>
#include <cstdio>
#include <string>
#include <cmath>
#include <assert.h>
#include "matrices.h"
#include "historique.h"
#include "tests.h"

using namespace std;

int main() {
    cout << "\t\tMini Projet" << endl;
    int a(test_conversions(true));
    int b(test_produits(true));
    int c(test_ordonnage(true));
    int d(test_fichiers(true));
    int e(test_historique(true));
    if ( a == 0 && b==0 && c==0 && d == 0 && e == 0) cout << " OK " << endl;
    else cout << " KO : a=" << a << " | b=" << b << " | c=" << c << " | d=" << d << " | e=" << e << endl;

	// Début du programme 

	int i,k(0);
    complexe lambda1, temp;
    lambda1.re = 1;
    temp.re = 2;
    double norme_x;
    matricecreuseun A(lireun("../test.mx", false));
    matricecreuseun B(A.ordonne());
    matricecreusedeux C(B.versdeux());
    vecteur q(A.m), x(A.m), u1(A.m);
    double m(A.m);
    double val(sqrt(sqrt(1/m)/2));
    for(int i(0); i<A.m; i++) {
        q.coef[i].re = val; 
        q.coef[i].im = val;
    }

	//---------------------- Algorithme de calcul ----------------------------//

    while((temp-lambda1).norme() > 0.001 && k<2000 ) {
        for (i=0;i<20;i++) {
            x = A*q;
            norme_x = x.norme() ;
            q = x/norme_x;
        }
        k += 20;

        if(norme_x>0.000001) {
            x = A*q;
            i = 0 ;
            temp = lambda1;
            for(i=0;i<q.n;i++) if (!q.coef[i].isnull()) lambda1=x.coef[i]/q.coef[i];
            u1=q*pow(lambda1/lambda1.norme(),k);
        }
        else {
            printf("Il n'y a pas de valeur propre...\n");
            k=2000 ; // TODO
        }
    }
    if (k < 2000) {
        printf("La plus grande valeur propre est ");
        lambda1.afficher();
        printf("\nUn vecteur propre associe est\n");
        u1.afficher();
    }
    else {
        printf("Il n'y a pas de valeur propre ! \n");
    }
    return 0 ;
}
