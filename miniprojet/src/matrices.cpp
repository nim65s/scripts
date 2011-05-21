#include <iostream>
#include <cstdio>
#include "matrices.h"

using namespace std;

void vecteur::afficher() {{{
    cout << "[";
    for(int i=0;i<n;i++) {
        printf("%5.2g",coef[i]);
        cout << " ";
    }
    cout << "  ]" << endl;
}}}

void matricepleine::afficher() {{{
    cout << "⎡";
    for(int j=0;j<m;j++) printf("%5.4g ",coef[0][j]);
    cout << "  ⎤" << endl;
    for(int i=1;i<n-1;i++) {
        cout << "⎢";
        for(int j=0;j<m;j++) printf("%5.4g ",coef[i][j]);
        cout << "  ⎥" << endl;
    }
    cout << "⎣";
    for(int j=0;j<m;j++) printf("%5.4g ",coef[n-1][j]);
    cout << "  ⎦" << endl;
}}}

void matricecreuseun::afficher() {{{
    cout << "  i  | ";
    for(int k=0;k<nz;k++) printf("%5d ",i[k]+1);
    cout << endl << "  j  | ";
    for(int k=0;k<nz;k++) printf("%5d ",j[k]+1);
    cout << endl << "coef | ";
    for(int k=0;k<nz;k++) printf("%5.4g ",coef[k]);
    cout << endl;
}}}

void matricecreusedeux::afficher() {{{
    cout << "vals | ";
    for(int k=0;k<nz;k++) printf("%5.4g ",vals[k]);
    cout << endl << "  j  | ";
    for(int k=0;k<nz;k++) printf("%5d ",j[k]+1);
    cout << endl << " II  | ";
    for(int k=0;k<=m;k++) printf("%5d ",II[k]);
    cout << endl;
}}}

/****************************************************************
 *                       Égalités de matrices                   *
 ****************************************************************/

bool operator==(vecteur a, vecteur b) {{{
    if (a.n != b.n) return false;
    for(int i=0;i<a.n;i++) if (a.coef[i] != b.coef[i]) return false;
    return true;
}}}

bool operator!=(vecteur a, vecteur b) {{{
    if (a.n != b.n) return true;
    for(int i=0;i<a.n;i++) if (a.coef[i] != b.coef[i]) return true;
    return false;
}}}

bool operator==(matricepleine A, matricepleine B) {{{
    if( A.n != B.n || A.m != B.m) return false;
    for(int i=0;i<A.n;i++) for(int j=0;j<A.m;j++) if (A.coef[i][j] != B.coef[i][j]) return false;
    return true;
}}}

bool operator!=(matricepleine A, matricepleine B) {{{
    if( A.n != B.n || A.m != B.m) return true;
    for(int i=0;i<A.n;i++) for(int j=0;j<A.m;j++) if (A.coef[i][j] != B.coef[i][j]) return true;
    return false;
}}}

bool operator==(matricecreuseun A, matricecreuseun B) {{{
    if (A.m != B.m || A.n != B.n || A.nz != B.nz) return false;
    for(int k=0;k<A.n;k++) if(A.i[k] != B.i[k] || A.j[k] != B.j[k] || A.coef[k] != B.coef[k]) return false; // TODO Faux positifs monstrueux T-T
    /* L'idée serait de faire ce test là, et s'il ne passe pas, mettre les données de B de coté, et réessayer avec les suivantes
     * Mais c'est un poil tendu et peut être pas si pertinent que ça à coder...
     */
    return true;
}}}

bool operator!=(matricecreuseun A, matricecreuseun B) {{{
    if (A.m != B.m || A.n != B.n || A.nz != B.nz) return true;
    for(int k=0;k<A.n;k++) if(A.i[k] != B.i[k] || A.j[k] != B.j[k] || A.coef[k] != B.coef[k]) return true; // TODO Faux positifs monstrueux T-T
    /* L'idée serait de faire ce test là, et s'il ne passe pas, mettre les données de B de coté, et réessayer avec les suivantes
     * Mais c'est un poil tendu et peut être pas si pertinent que ça à coder...
     */
    return false;
}}}

bool operator==(matricecreusedeux A, matricecreusedeux B) {{{
    if (A.m != B.m || A.n != B.n || A.nz != B.nz) return false;
    for (int k=0;k<A.nz;k++) if (A.vals[k] != B.vals[k] || A.j[k] != B.j[k]) return false;
    for (int k=0;k<=A.m;k++) if (A.II[k] != B.II[k]) return false;
    return true;
}}}

bool operator!=(matricecreusedeux A, matricecreusedeux B) {{{
    if (A.m != B.m || A.n != B.n || A.nz != B.nz) return true;
    for (int k=0;k<A.nz;k++) if (A.vals[k] != B.vals[k] || A.j[k] != B.j[k]) return true;
    for (int k=0;k<=A.m;k++) if (A.II[k] != B.II[k]) return true;
    return false;
}}}

/****************************************************************
 *                   Multiplications de matrices                *
 ****************************************************************/

vecteur operator*(matricepleine M, vecteur v) {{{
    if (M.m != v.n) {
        cout << "On ne peut pas multiplier cette matrice et ce vecteur pour des raisons de dimension." << endl;
        cout << "Le vecteur retourné par cette multiplication est le vecteur initial !" << endl;
        return v;
    }
    vecteur w;
    w.n = M.n;
    for(int i=0;i<M.n;i++) {
        w.coef[i] = 0;
        for(int j=0;j<M.m;j++) w.coef[i] += v.coef[j]*M.coef[i][j];
    }
    return w;
}}}

vecteur operator*(matricecreuseun M, vecteur v) {{{
    if (M.m != v.n) {
        cout << "On ne peut pas multiplier cette matrice et ce vecteur pour des raisons de dimension." << endl;
        cout << "Le vecteur retourné par cette multiplication est le vecteur initial !" << endl;
        return v;
    }
    vecteur w;
    w.n = M.n;
    for(int i=0;i<w.n;i++) w.coef[i] = 0;
    for(int k=0;k<M.nz;k++) w.coef[M.i[k]] += M.coef[k]*v.coef[M.j[k]];
    return w;
}}}

vecteur operator*(matricecreusedeux M, vecteur v) {{{
    if (M.m != v.n) {
        cout << "On ne peut pas multiplier cette matrice et ce vecteur pour des raisons de dimension." << endl;
        cout << "Le vecteur retourné par cette multiplication est le vecteur initial !" << endl;
        return v;
    }
    vecteur w;
    w.n = M.n;
    for(int i=0;i<w.n;i++) w.coef[i] = 0;
    int a=0;
    for(int b=0;b<M.n;b++) while(a<M.II[b]) w.coef[b] += M.vals[a]*v.coef[M.j[a++]]; // TODO Le compilateur me fait remarquer qu'il incrémentera mon a quand bon lui semblera...
    return w;
}}}

/****************************************************************
 *                       Conversion de matrices                 *
 ****************************************************************/

matricecreuseun pleineversun(matricepleine A) {{{
    matricecreuseun B;
    B.m = A.m;
    B.n = A.n;
    B.nz = 0;
    for(int i=0;i<A.m;i++) {
        for(int j=0;j<A.n;j++) {
            if (A.coef[i][j] != 0) {
                B.i[B.nz] = i;
                B.j[B.nz] = j;
                B.coef[B.nz] = A.coef[i][j];
                B.nz++;
            }
        }
    }
    return B;
}}}

matricecreusedeux pleineversdeux(matricepleine A) {{{
    matricecreusedeux B;
    B.n = A.n;
    B.m = 0;
    B.nz = 0;
    for (int i=0;i<A.m;i++) {
        bool yadejaqqchsurlaligne = false;
        for(int j=0;j<A.n;j++) {
            if(A.coef[i][j] != 0) {
                B.vals[B.nz] = A.coef[i][j];
                B.j[B.nz++] = j;
                if (!yadejaqqchsurlaligne) {
                    yadejaqqchsurlaligne = true;
                    B.II[B.m++] = B.nz;
                }
            }
        }
        if (!yadejaqqchsurlaligne) B.II[B.m++] = 0;
    }
    B.II[B.m] = B.II[0]+B.nz;
    return B;
}}}

matricecreusedeux unversdeux(matricecreuseun A) {{{
    matricecreusedeux B;
    B.n = A.n;
    B.nz = A.nz;
    B.m = -1;
    for(int i=0;i<B.nz;i++) {
        B.vals[i] = A.coef[i];
        B.j[i] = A.j[i];
        if (A.i[i] != B.m) {
            if (A.i[i] == B.m+1) B.II[++B.m] = i+1;
            else B.II[++B.m] = 0; // TODO il faut aussi rajouter la suite ...
        }
    }
    B.II[++B.m] = B.II[0]+B.nz;
    return B;
}}}


/****************************************************************
 *                       Ordonage de matrices                   *
 ****************************************************************/

//matricecreuseun ordonne(matricecreuseun A) {{{

//bool estenbordel(matricecreuseun A) {{{


// vim: set foldmethod=marker:
