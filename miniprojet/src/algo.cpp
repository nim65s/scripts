#include <iostream>
#include <cstdio>
#include <string>
#include <cmath>
#include <assert.h>
#include "matrices.h"
#include "historique.h"

using namespace std;

int algo(matricecreusedeux const & A, bool const & afficher) {{{
    cout << "\tDébut de l'algorithme" << endl;
    if (afficher) {
        cout << "Matrice initiale : " << endl;
        A.afficher();
    }
	int i,k(0);
    complexe lambda1(1), temp(2);
    double norme_x;
    vecteur q(A.m), x(A.m), u1(A.m);
    double m(A.m);
    double val(sqrt(1/m));
    for (int i(0); i<A.m; i++) q.coef[i].re = val; 
    if (afficher) {
        cout << "Vecteur initial : " << endl;
        q.afficher();
    }

    // L'algorithme s'arrète si la solution a été trouvée ou si le calcul est trop long
    while ((temp-lambda1).norme() > 0.001 && k<2000 ) {
        for (i=0;i<20;i++) { // On fait 20 itérations avant de revérifier le convergence
            x = A*q;
            norme_x = x.norme() ;
            q = x/norme_x;
        }
        k += 20;

        if (afficher) {
            cout << "x : " << endl;
            x.afficher();
            cout << "q : " << endl;
            q.afficher();
        }

        if (norme_x>0.000001) { // On vérifie que norme(x) ne devient pas nulle pour ne pas diviser par 0
            x = A*q;
            temp = lambda1;
            // On cherche une composante de x exploitable au sens de l'algorithme
            for (i=0;i<q.n;i++) if (!q.coef[i].isnull()) lambda1=x.coef[i]/q.coef[i];
            u1=q*pow(lambda1/lambda1.norme(),k);
        }
        else {
            printf("Il n'y a pas de valeur propre...\n");
            k=2000;
            return 1;
        }
    }
    if (k < 2000) {
        printf("La plus grande valeur propre est :");
        lambda1.afficher();
        printf("\nUn vecteur propre associe est : ");
        u1.afficher();
    }
    else {
        printf("Il n'y a pas de valeur propre ! \n");
        return 1;
    }
    return 0;
}}}
 
