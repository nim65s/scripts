#include <iostream>
#include <cstdio>
#include <string>
#include <assert.h>
#include <math.h>
#include "matrices.h"
#include "tests.h"

using namespace std;

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

int main() {
    cout << "\t\tMini Projet" << endl;
    int a = test_conversions(false);
    int b = test_produits(false);
    int c = test_ordonnage(false);
    int d = test_fichiers(false);
    if ( a == 0 && b==0 && c==0 && d == 0) cout << " OK " << endl;
    else cout << " KO : a=" << a << " | b=" << b << " | c=" << c << " | d=" << d << endl;

	// Début du programme 

	int i,k=0;
	float lambda1=0, temp=1, norme_x ;
	vecteur q(2),x(2),u1(2) ;
	matricepleine B(2, 2, 4);;
	matricecreuseun A(2, 2, 4);
	q.coef[0] = sqrt(2);
	q.coef[1] = sqrt(2);

	//---------------------- Algorithme de calcul ----------------------------//

    while(abs(temp-lambda1) > 0.001 && k<2000 ) {
        for (i=1;i<20;i++) {
            x = A*q;
            q = x/norme(x);
            norme_x = norme(x) ;
            k++; // TODO
        }

        if(abs(norme_x)>0.000001) {
            x = A*q;
            i = 0 ;
            temp = lambda1;
            while ( i == 0 && i!=q.n ) {
                if (q.coef[i]!=0) {
                    lambda1=x.coef[i]/q.coef[i];
                    i++ ;
                }
            }
            u1=q*pow(lambda1/abs(lambda1),k);
        }
        else {
            printf("Il n'y a pas de valeur propre");
            k=2000 ; // TODO
        }
    }
    if (k < 2000) {
        printf("La plus grande valeur propre est %5.2g \n",lambda1);
        printf("Un vecteur propre associe est\n");
        u1.afficher();
    }
    else {
        printf("Il n'y a pas de valeur propre");
    }
    return 0 ;
}
