#include <iostream>
#include <cstdio>
#include "matrices.h"

using namespace std;

void vecteur::afficher() {
    cout << "[";
    for(int i=0;i<n;i++) {
        printf("%5.2g",coef[i]);
        cout << " ";
    }
    cout << "  ]" << endl;
}

void matricepleine::afficher() {
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
}

void matricecreuseun::afficher() {
    cout << "  i  | ";
    for(int k=0;k<o;k++) printf("%5d ",i[k]+1);
    cout << endl << "  j  | ";
    for(int k=0;k<o;k++) printf("%5d ",j[k]+1);
    cout << endl << "coef | ";
    for(int k=0;k<o;k++) printf("%5.4g ",coef[k]);
    cout << endl;
}

void matricecreusedeux::afficher() {
    cout << "vals | ";
    for(int k=0;k<o;k++) printf("%5.4g ",vals[k]);
    cout << endl << "  j  | ";
    for(int k=0;k<o;k++) printf("%5d ",j[k]+1);
    cout << endl << " II  | ";
    for(int k=0;k<p;k++) printf("%5d ",II[k]);
    cout << endl;
}

/****************************************************************
 *                       Égalités de matrices                   *
 ****************************************************************/

bool operator==(vecteur a, vecteur b) {
    if (a.n != b.n) return false;
    for(int i=0;i<a.n;i++) if (a.coef[i] != b.coef[i]) return false;
    return true;
}

bool operator!=(vecteur a, vecteur b) {
    if (a.n != b.n) return true;
    for(int i=0;i<a.n;i++) if (a.coef[i] != b.coef[i]) return true;
    return false;
}

bool operator==(matricepleine A, matricepleine B) {
    if( A.n != B.n || A.m != B.m) return false;
    for(int i=0;i<A.n;i++) for(int j=0;j<A.m;j++) if (A.coef[i][j] != B.coef[i][j]) return false;
    return true;
}

bool operator!=(matricepleine A, matricepleine B) {
    if( A.n != B.n || A.m != B.m) return true;
    for(int i=0;i<A.n;i++) for(int j=0;j<A.m;j++) if (A.coef[i][j] != B.coef[i][j]) return true;
    return false;
}

bool operator==(matricecreuseun A, matricecreuseun B) {
    if (A.m != B.m || A.n != B.n || A.o != B.o) return false;
    for(int k=0;k<A.n;k++) if(A.i[k] != B.i[k] || A.j[k] != B.j[k] || A.coef[k] != B.coef[k]) return false; // TODO Faux positifs monstrueux T-T
    /* L'idée serait de faire ce test là, et s'il ne passe pas, mettre les données de B de coté, et réessayer avec les suivantes
     * Mais c'est un poil tendu et peut être pas si pertinent que ça à coder...
     */
    return true;
}

bool operator!=(matricecreuseun A, matricecreuseun B) {
    if (A.m != B.m || A.n != B.n || A.o != B.o) return true;
    for(int k=0;k<A.n;k++) if(A.i[k] != B.i[k] || A.j[k] != B.j[k] || A.coef[k] != B.coef[k]) return true; // TODO Faux positifs monstrueux T-T
    /* L'idée serait de faire ce test là, et s'il ne passe pas, mettre les données de B de coté, et réessayer avec les suivantes
     * Mais c'est un poil tendu et peut être pas si pertinent que ça à coder...
     */
    return false;
}

bool operator==(matricecreusedeux A, matricecreusedeux B) {
    if (A.m != B.m || A.n != B.n || A.o != B.o || A.p != B.p) return false;
    for (int k=0;k<A.o;k++) if (A.vals[k] != B.vals[k] || A.j[k] != B.j[k]) return false;
    for (int k=0;k<=A.p;k++) if (A.II[k] != B.II[k]) return false;
    return true;
}

bool operator!=(matricecreusedeux A, matricecreusedeux B) {
    if (A.m != B.m || A.n != B.n || A.o != B.o || A.p != B.p) return true;
    for (int k=0;k<A.o;k++) if (A.vals[k] != B.vals[k] || A.j[k] != B.j[k]) return true;
    for (int k=0;k<=A.p;k++) if (A.II[k] != B.II[k]) return true;
    return false;
}

/****************************************************************
 *                   Multiplications de matrices                *
 ****************************************************************/

vecteur operator*(matricepleine M, vecteur v) {
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
}

vecteur operator*(matricecreuseun M, vecteur v) {
    if (M.m != v.n) {
        cout << "On ne peut pas multiplier cette matrice et ce vecteur pour des raisons de dimension." << endl;
        cout << "Le vecteur retourné par cette multiplication est le vecteur initial !" << endl;
        return v;
    }
    vecteur w;
    w.n = M.n;
    for(int i=0;i<w.n;i++) w.coef[i] = 0;
    for(int k=0;k<M.o;k++) w.coef[M.i[k]] += M.coef[k]*v.coef[M.j[k]];
    return w;
}

vecteur operator*(matricecreusedeux M, vecteur v) {
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
}

/****************************************************************
 *                       Conversion de matrices                 *
 ****************************************************************/

matricecreuseun pleineversun(matricepleine A) {
    matricecreuseun B;
    B.m = A.m;
    B.n = A.n;
    B.o = 0;
    for(int i=0;i<A.m;i++) {
        for(int j=0;j<A.n;j++) {
            if (A.coef[i][j] != 0) {
                B.i[B.o] = i;
                B.j[B.o] = j;
                B.coef[B.o] = A.coef[i][j];
                B.o++;
            }
        }
    }
    return B;
}

matricecreusedeux pleineversdeux(matricepleine A) {
    matricecreusedeux B;
    B.m = A.m;
    B.n = A.n;
    B.o = 0;
    B.p = 0;
    int cmpt = 0;
    for (int i=0;i<A.m;i++) {
        bool yadejaqqchsurlaligne = false;
        for(int j=0;j<A.n;j++) {
            if(A.coef[i][j] != 0) {
                B.vals[B.o] = A.coef[i][j];
                B.j[B.o++] = j;
                cmpt++; // TODO décalage vu qu'un tableau commence à 0 ?
                if (!yadejaqqchsurlaligne) {
                    yadejaqqchsurlaligne = true;
                    B.II[B.p++] = cmpt;
                }
            }
        }
        if (!yadejaqqchsurlaligne) B.II[B.p++] = 0;
    }
    B.II[B.p++] = B.II[0]+B.o;// TODO faudra qu'on m'explique à quoi il sert lui... 
    return B;
}

// vim: set foldmarker={,} foldmethod=marker:
