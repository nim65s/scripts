#include <iostream>
#include <cstdio>
#include <string>
#include <cmath>
#include <assert.h>
#include "matrices.h"
#include "historique.h"

using namespace std;

int algo(matricecreuseun const & A, bool const & afficher) {{{
    cout << "\tDébut de l'algorithme" << endl;
    assert(!A.estenbordel());
    matricecreusedeux B(A.versdeux());
	int i,k(0);
    complexe lambda1(1), temp1(2),lambda2(1), temp2(2);
    vecteur q1(A.m), x1(A.m), u1(A.m),q2(B.m), x2(A.m), u2(B.m);
    q1.coef[0].re = 1; 
    q2.coef[0].re = 1; 
    if (afficher) {
        cout << "Matrice initiale 1 : " << endl;
        A.afficher();
        cout << "Matrice initiale 2 : " << endl;
        B.afficher();
        cout << "Vecteur initial 1 : " << endl;
        q1.afficher();
        cout << "Vecteur initial 2 : " << endl;
        q2.afficher();
        cout << endl;
    }

    // L'algorithme s'arrète si la solution a été trouvée ou si le calcul est trop long
    //while ((temp1-lambda1).norme() > 1e-42 && (temp2-lambda2).norme() > 1e-42  && k<2000 ) {
    for (int var(0); var<3; var++) {
        //for (i=0;i<20;i++) { // On fait 20 itérations avant de revérifier le convergence
            x1 = A*q1;
            x2 = B*q2;
            q1 = x1/x1.norme();
            q2 = x2/x2.norme();
        //}
        //k += 20;
        k++;

        if (afficher) {
            cout << endl << "x : " << endl;
            x1.afficher();
            x2.afficher();
            cout << "q : " << endl;
            q1.afficher();
            q2.afficher();
            if (x1 != x2) cout << "X1 différent de X2" << endl;
            else cout << "X1 égal à X2" << endl;
            if (q1 != q2) cout << "Q1 différent de Q2" << endl;
            else cout << "Q1 égal à Q2" << endl;
        }
    }
    if (k < 2000) {
        assert (x1.norme()>0.000001 && x2.norme()>0.000001); // On vérifie que norme(x) ne devient pas nulle pour ne pas diviser par 0
        // On cherche une composante de x exploitable au sens de l'algorithme
        for (i=0;i<q1.n;i++) if (!q1.coef[i].isnull()) {
            lambda1=x1.coef[i]/q1.coef[i];
            i = q1.n;
        }
        for (i=0;i<q2.n;i++) if (!q2.coef[i].isnull()) {
            lambda2=x2.coef[i]/q2.coef[i];
            i = q2.n;
        }
        u1=q1*pow(lambda1/lambda1.norme(),k);
        u2=q2*pow(lambda2/lambda2.norme(),k);
        printf("\nLa plus grande valeur propre 1 est :");
        lambda1.afficher();
        printf("\nLa plus grande valeur propre 2 est :");
        lambda2.afficher();
        printf("\nUn vecteur propre 1 associe est : ");
        u1.afficher();
        printf("\nUn vecteur propre 2 associe est : ");
        u2.afficher();
    }
    else {
        printf("Il n'y a pas de valeur propre ! \n");
        return 1;
    }
    return 0;
}}}

int algo(matricepleine const & A, bool const & afficher) {{{
    return algo(A.versun(), afficher);
}}}

int algo(matricecreusedeux const & A, bool const & afficher) {{{
    return algo(versun(A), afficher);
}}}


