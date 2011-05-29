#include <iostream>
#include <cstdio>
#include <string>
#include <assert.h>
#include <math.h>
#include "matrices.h"
#include "tests.h"

using namespace std;

/*
void entrer_matrice(matricecreuseun A) {{{
	printf("Entrez les coefficients de la matrice");
	for (int k=0; k<A.nz; k++) {
	    printf("Coefficient n°%d",k+1);
        cin >> A.coef[k];
	    printf("Ligne du coefficient n°%d",k+1);
        cin >> A.i[k];
	    printf("Colonne du coefficient n°%d",k+1);
        cin >> A.coef[k];
	}
}}}
*/

int main() {
    cout << "\t\tMini Projet" << endl;
    int a = test_conversions(true);
    int b = test_produits(true);
    int c = test_ordonnage(true);
    int d = test_fichiers(true);
    if ( a == 0 && b==0 && c==0 && d == 0) cout << " OK " << endl;
    else cout << " KO : a=" << a << " | b=" << b << " | c=" << c << " | d=" << d << endl;

	// Début du programme 
    /*

	int i,k=0;
    complexe lambda1, temp;
    double norme_x;
    matricecreuseun A = lireun("../test.mx", false);
    matricecreuseun B = ordonne(A);
    matricecreusedeux C = unversdeux(B);
    vecteur q(A.m), x(A.m), u1(A.m);
    double val = sqrt(sqrt(1/A.m)/2);
    for(int i=0; i<A.m; i++) {
        q.coef[i].re = val; 
        q.coef[i].im = val;
    }

	//---------------------- Algorithme de calcul ----------------------------//

    while(norme(temp-lambda1) > 0.001 && k<2000 ) {
        for (i=0;i<20;i++) {
            x = A*q;
            norme_x = norme(x) ;
            q = x/norme_x;
        }
        k += 20;

        if(abs(norme_x)>0.000001) {
            x = A*q;
            i = 0 ;
            temp = lambda1;
            for(i=0;i<q.n;i++) if (!isnull(q.coef[i])) lambda1=x.coef[i]/q.coef[i];
            u1=q*pow(lambda1/norme(lambda1),k);
        }
        else {
            printf("Il n'y a pas de valeur propre");
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
        printf("Il n'y a pas de valeur propre");
    }
    */
    return 0 ;
}
